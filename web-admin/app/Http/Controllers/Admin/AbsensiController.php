<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AbsensiHarian;
use App\Models\JadwalPelajaran;
use App\Models\Kelas;
use App\Models\SuratAbsensi;
use App\Services\MatsanamNotificationService;
use App\Services\SuratAbsensiApprovalService;
use App\Services\SuratAbsensiFileService;
use Carbon\Carbon;
use Carbon\CarbonPeriod;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Illuminate\View\View;

class AbsensiController extends Controller
{
    public function verifikasiSurat(Request $request): View
    {
        $query = SuratAbsensi::with(['siswa.kelas.waliKelas', 'verifikator'])
            ->latest();

        $status = strtolower((string) $request->query('status', 'semua'));
        if ($status !== '' && $status !== 'semua') {
            $query->whereRaw('LOWER(status_verifikasi) = ?', [$status]);
        }

        if ($request->filled('siswa')) {
            $search = trim((string) $request->input('siswa'));
            $query->whereHas('siswa', function ($studentQuery) use ($search) {
                $studentQuery->where('nama_lengkap', 'like', '%' . $search . '%')
                    ->orWhere('nisn', 'like', '%' . $search . '%')
                    ->orWhere('nis', 'like', '%' . $search . '%');
            });
        }

        // View verifikasi memakai collection untuk daftar kiri dan pemilihan detail di panel kanan.
        $suratAbsensi = $query->get();

        $totalPending = SuratAbsensi::whereRaw('LOWER(status_verifikasi) = ?', ['pending'])->count();
        $totalDisetujui = SuratAbsensi::whereRaw('LOWER(status_verifikasi) = ?', ['disetujui'])->count();
        $totalDitolak = SuratAbsensi::whereRaw('LOWER(status_verifikasi) = ?', ['ditolak'])->count();

        return view('admin.absensi.verifikasi', compact(
            'suratAbsensi',
            'totalPending',
            'totalDisetujui',
            'totalDitolak'
        ));
    }

    public function fileSurat(int $id, Request $request)
    {
        $surat = SuratAbsensi::findOrFail($id);
        $path = $surat->file_surat;

        abort_if(blank($path), 404, 'Dokumen surat tidak ditemukan.');
        $files = app(SuratAbsensiFileService::class);
        abort_unless($files->diskFor($path), 404, 'Dokumen surat tidak ditemukan.');

        if ($request->boolean('download')) {
            return $files->download($path);
        }

        return $files->response($path);
    }

    public function approveSurat(Request $request, int $id): RedirectResponse
    {
        $validated = $request->validate([
            'kategori_master' => ['nullable', Rule::in(['sakit', 'izin'])],
        ]);

        $surat = SuratAbsensi::with('siswa.user')->findOrFail($id);
        if (strtolower((string) $surat->status_verifikasi) !== 'pending') {
            return back()->with('error', 'Surat ini sudah diproses sebelumnya. Muat ulang halaman untuk melihat status terbaru.');
        }

        $kategori = $validated['kategori_master'] ?? $surat->jenis;
        if (! in_array($kategori, ['sakit', 'izin'], true)) {
            return back()->with('error', 'Kategori absensi tidak valid.');
        }

        $attendanceRows = app(SuratAbsensiApprovalService::class)->approve(
            $surat,
            (int) auth()->id(),
            $kategori,
        );

        app(MatsanamNotificationService::class)->send(
            $surat->siswa?->user,
            'status_pengajuan_izin',
            'Pengajuan izin disetujui',
            'Pengajuan ' . $surat->jenis . ' untuk tanggal ' . $surat->tanggal_mulai?->format('d/m/Y') . ' sampai ' . $surat->tanggal_selesai?->format('d/m/Y') . ' telah disetujui oleh Admin.',
            ['surat_id' => $surat->id, 'status' => 'disetujui'],
        );

        return redirect()->route('admin.absensi.verifikasi', [
            'status' => 'disetujui',
            'selected' => $surat->id,
        ])->with(
            'success',
            'Surat berhasil disetujui. ' . $attendanceRows . ' catatan presensi sesuai jadwal siswa telah diperbarui.'
        );
    }

    public function rejectSurat(Request $request, int $id): RedirectResponse
    {
        $validated = $request->validate([
            'catatan' => ['required', 'string', 'max:500'],
        ]);

        $surat = DB::transaction(function () use ($id, $validated) {
            $locked = SuratAbsensi::with('siswa.user')
                ->lockForUpdate()
                ->findOrFail($id);

            abort_unless(
                strtolower((string) $locked->status_verifikasi) === 'pending',
                409,
                'Surat ini sudah diproses sebelumnya. Muat ulang halaman untuk melihat status terbaru.'
            );

            $locked->update([
                'status_verifikasi' => 'ditolak',
                'verifikator_id' => auth()->id(),
                'tanggal_verifikasi' => now(),
                'catatan_verifikasi' => $validated['catatan'],
            ]);

            return $locked;
        });

        app(MatsanamNotificationService::class)->send(
            $surat->siswa?->user,
            'status_pengajuan_izin',
            'Pengajuan izin memerlukan perbaikan',
            'Pengajuan ' . $surat->jenis . ' ditolak oleh Admin. Catatan: ' . $validated['catatan'],
            ['surat_id' => $surat->id, 'status' => 'ditolak'],
        );

        return redirect()->route('admin.absensi.verifikasi', [
            'status' => 'ditolak',
            'selected' => $surat->id,
        ])->with('success', 'Surat ditolak dan catatan penolakan berhasil disimpan.');
    }

    public function rekapPresensi(Request $request): View
    {
        $validated = $request->validate([
            'periode' => ['nullable', 'date_format:Y-m'],
            'kelas' => ['nullable', 'integer', 'exists:kelas,id'],
            'status' => ['nullable', Rule::in(['hadir', 'izin', 'sakit', 'alpa'])],
        ]);

        $periode = $validated['periode'] ?? Carbon::now('Asia/Jakarta')->format('Y-m');
        $periodDate = Carbon::createFromFormat('Y-m', $periode);

        $baseQuery = AbsensiHarian::query()
            ->with(['siswa.kelas', 'jadwal.guru', 'jadwal.mataPelajaran', 'jadwal.kelas'])
            ->whereBetween('tanggal', [
                $periodDate->copy()->startOfMonth()->toDateString(),
                $periodDate->copy()->endOfMonth()->toDateString(),
            ]);

        if (! empty($validated['kelas'])) {
            $baseQuery->whereHas('jadwal', function ($query) use ($validated) {
                $query->where('kelas_id', $validated['kelas']);
            });
        }

        // Kartu ringkasan mengikuti filter periode dan kelas, namun tidak terpengaruh filter status tabel.
        $summary = (clone $baseQuery)
            ->selectRaw('status, COUNT(*) as total')
            ->groupBy('status')
            ->pluck('total', 'status')
            ->toArray();

        $totalHadir = (int) ($summary['hadir'] ?? 0);
        $totalIzin = (int) ($summary['izin'] ?? 0);
        $totalSakit = (int) ($summary['sakit'] ?? 0);
        $totalAlpa = (int) ($summary['alpa'] ?? 0);
        $total = $totalHadir + $totalIzin + $totalSakit + $totalAlpa;
        $persentaseHadir = $total > 0 ? round(($totalHadir / $total) * 100, 2) : 0;

        $listQuery = clone $baseQuery;
        if (! empty($validated['status'])) {
            $listQuery->where('status', $validated['status']);
        }

        $absensis = $listQuery->orderByDesc('tanggal')->paginate(20)->withQueryString();
        $kelasList = Kelas::orderBy('tingkat')->orderBy('nama_kelas')->get();

        return view('admin.absensi.rekap', compact(
            'absensis',
            'summary',
            'totalHadir',
            'totalIzin',
            'totalSakit',
            'totalAlpa',
            'total',
            'persentaseHadir',
            'kelasList',
            'request'
        ));
    }

    public function historiSurat(Request $request): View
    {
        $query = SuratAbsensi::with(['siswa.kelas', 'verifikator'])->latest();

        if ($request->filled('status') && strtolower((string) $request->status) !== 'semua') {
            $query->whereRaw('LOWER(status_verifikasi) = ?', [strtolower((string) $request->status)]);
        }

        $surats = $query->paginate(15)->withQueryString();
        $totalPending = SuratAbsensi::whereRaw('LOWER(status_verifikasi) = ?', ['pending'])->count();
        $totalDisetujui = SuratAbsensi::whereRaw('LOWER(status_verifikasi) = ?', ['disetujui'])->count();
        $totalDitolak = SuratAbsensi::whereRaw('LOWER(status_verifikasi) = ?', ['ditolak'])->count();

        return view('admin.absensi.histori', compact(
            'surats',
            'totalPending',
            'totalDisetujui',
            'totalDitolak'
        ));
    }

    public function exportPresensi(Request $request)
    {
        $validated = $request->validate([
            'format' => ['required', Rule::in(['excel', 'csv', 'pdf'])],
            'periode' => ['required', 'date_format:Y-m'],
            'kelas' => ['nullable', 'integer', 'exists:kelas,id'],
        ]);

        $periodDate = Carbon::createFromFormat('Y-m', $validated['periode']);
        $query = AbsensiHarian::with(['siswa', 'jadwal.guru', 'jadwal.mataPelajaran', 'jadwal.kelas'])
            ->whereBetween('tanggal', [
                $periodDate->copy()->startOfMonth()->toDateString(),
                $periodDate->copy()->endOfMonth()->toDateString(),
            ]);

        if (! empty($validated['kelas'])) {
            $query->whereHas('jadwal', function ($builder) use ($validated) {
                $builder->where('kelas_id', $validated['kelas']);
            });
        }

        $absensis = $query->orderBy('tanggal')->get();

        if ($validated['format'] === 'excel') {
            $fileName = 'rekap_presensi_' . $validated['periode'] . '.xls';
            $kelas = ! empty($validated['kelas']) ? Kelas::find($validated['kelas']) : null;
            $headers = [
                'No', 'Nama Siswa', 'NISN', 'Kelas', 'Mata Pelajaran', 'Guru',
                'Tanggal', 'Status', 'Metode Absen', 'Waktu Absen', 'Keterangan',
            ];

            $xmlEscape = static function ($value): string {
                $value = (string) ($value ?? '-');
                // Buang karakter kontrol yang tidak diperbolehkan dalam XML 1.0.
                $value = preg_replace('/[\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F]/', '', $value) ?? '';
                return htmlspecialchars($value, ENT_QUOTES | ENT_XML1, 'UTF-8');
            };

            $makeCell = static function ($value, string $style = 'Cell', string $type = 'String') use ($xmlEscape): string {
                return '<Cell ss:StyleID="' . $style . '"><Data ss:Type="' . $type . '">' . $xmlEscape($value) . '</Data></Cell>';
            };

            $periodLabel = $periodDate->translatedFormat('F Y');
            $classLabel = $kelas?->nama_kelas ?? 'Semua Kelas';
            $lastRow = 4 + $absensis->count() + 1;
            $xml = '<?xml version="1.0" encoding="UTF-8"?>' . "\n"
                . '<?mso-application progid="Excel.Sheet"?>' . "\n"
                . '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" '
                . 'xmlns:o="urn:schemas-microsoft-com:office:office" '
                . 'xmlns:x="urn:schemas-microsoft-com:office:excel" '
                . 'xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" '
                . 'xmlns:html="http://www.w3.org/TR/REC-html40">'
                . '<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">'
                . '<Title>Rekap Presensi Siswa MTsN 6 Nganjuk</Title>'
                . '<Subject>Rekap kehadiran siswa</Subject><Author>MAT SANAM Admin</Author>'
                . '</DocumentProperties>'
                . '<Styles>'
                . '<Style ss:ID="Default" ss:Name="Normal"><Alignment ss:Vertical="Center"/>'
                . '<Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders>'
                . '<Font ss:FontName="Arial" ss:Size="10" ss:Color="#1F2937"/></Style>'
                . '<Style ss:ID="Title"><Alignment ss:Vertical="Center" ss:Horizontal="Left"/>'
                . '<Font ss:FontName="Arial" ss:Size="16" ss:Bold="1" ss:Color="#FFFFFF"/>'
                . '<Interior ss:Color="#1E3A8A" ss:Pattern="Solid"/></Style>'
                . '<Style ss:ID="Subtitle"><Alignment ss:Vertical="Center"/>'
                . '<Font ss:FontName="Arial" ss:Size="10" ss:Italic="1" ss:Color="#334155"/>'
                . '<Interior ss:Color="#EFF6FF" ss:Pattern="Solid"/></Style>'
                . '<Style ss:ID="Header"><Alignment ss:Vertical="Center" ss:Horizontal="Center" ss:WrapText="1"/>'
                . '<Font ss:FontName="Arial" ss:Size="10" ss:Bold="1" ss:Color="#FFFFFF"/>'
                . '<Interior ss:Color="#2563EB" ss:Pattern="Solid"/>'
                . '<Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#1D4ED8"/></Borders></Style>'
                . '<Style ss:ID="Cell"><Alignment ss:Vertical="Center"/></Style>'
                . '<Style ss:ID="CellAlt"><Alignment ss:Vertical="Center"/><Interior ss:Color="#F8FAFC" ss:Pattern="Solid"/></Style>'
                . '<Style ss:ID="Number"><Alignment ss:Vertical="Center" ss:Horizontal="Center"/></Style>'
                . '<Style ss:ID="StatusHadir"><Font ss:Bold="1" ss:Color="#166534"/><Interior ss:Color="#DCFCE7" ss:Pattern="Solid"/></Style>'
                . '<Style ss:ID="StatusSakit"><Font ss:Bold="1" ss:Color="#991B1B"/><Interior ss:Color="#FEE2E2" ss:Pattern="Solid"/></Style>'
                . '<Style ss:ID="StatusIzin"><Font ss:Bold="1" ss:Color="#92400E"/><Interior ss:Color="#FEF3C7" ss:Pattern="Solid"/></Style>'
                . '<Style ss:ID="StatusAlpa"><Font ss:Bold="1" ss:Color="#FFFFFF"/><Interior ss:Color="#991B1B" ss:Pattern="Solid"/></Style>'
                . '<Style ss:ID="Footer"><Font ss:Bold="1" ss:Color="#1E3A8A"/><Interior ss:Color="#DBEAFE" ss:Pattern="Solid"/></Style>'
                . '</Styles>'
                . '<Worksheet ss:Name="Rekap Presensi"><Table ss:ExpandedColumnCount="11" ss:ExpandedRowCount="' . $lastRow . '" x:FullColumns="1" x:FullRows="1">';

            $columnWidths = [38, 155, 105, 82, 145, 155, 92, 82, 105, 100, 190];
            foreach ($columnWidths as $width) {
                $xml .= '<Column ss:Width="' . $width . '"/>';
            }

            $xml .= '<Row ss:Height="32"><Cell ss:StyleID="Title" ss:MergeAcross="10"><Data ss:Type="String">REKAP PRESENSI SISWA</Data></Cell></Row>';
            $xml .= '<Row ss:Height="24"><Cell ss:StyleID="Subtitle" ss:MergeAcross="10"><Data ss:Type="String">MTsN 6 Nganjuk | Periode: '
                . $xmlEscape($periodLabel) . ' | Kelas: ' . $xmlEscape($classLabel)
                . ' | Total: ' . $absensis->count() . ' data</Data></Cell></Row>';
            $xml .= '<Row ss:Height="8"/>';
            $xml .= '<Row ss:Height="32">';
            foreach ($headers as $header) {
                $xml .= $makeCell($header, 'Header');
            }
            $xml .= '</Row>';

            foreach ($absensis as $index => $absen) {
                $status = strtolower((string) ($absen->status ?? ''));
                $statusStyle = match ($status) {
                    'hadir' => 'StatusHadir',
                    'sakit' => 'StatusSakit',
                    'izin' => 'StatusIzin',
                    'alpa' => 'StatusAlpa',
                    default => ($index % 2 === 0 ? 'Cell' : 'CellAlt'),
                };
                $baseStyle = $index % 2 === 0 ? 'Cell' : 'CellAlt';
                $values = [
                    [$index + 1, 'Number', 'Number'],
                    [$absen->siswa->nama_lengkap ?? '-', 'String', $baseStyle],
                    [$absen->siswa->nisn ?? '-', 'String', $baseStyle],
                    [$absen->jadwal->kelas->nama_kelas ?? '-', 'String', $baseStyle],
                    [$absen->jadwal->mataPelajaran->nama ?? '-', 'String', $baseStyle],
                    [$absen->jadwal->guru->nama_lengkap ?? '-', 'String', $baseStyle],
                    [optional($absen->tanggal)->format('d-m-Y') ?? '-', 'String', $baseStyle],
                    [ucfirst($status ?: '-'), 'String', $statusStyle],
                    [strtoupper($absen->metode ?? '-'), 'String', $baseStyle],
                    [$absen->waktu_absen ?? '-', 'String', $baseStyle],
                    [$absen->keterangan ?? '-', 'String', $baseStyle],
                ];

                $xml .= '<Row ss:Height="22">';
                foreach ($values as [$value, $type, $style]) {
                    $xml .= $makeCell($value, $style, $type);
                }
                $xml .= '</Row>';
            }

            $xml .= '<Row ss:Height="25"><Cell ss:StyleID="Footer" ss:MergeAcross="10"><Data ss:Type="String">Jumlah data presensi: '
                . $absensis->count() . ' | Dokumen dibuat otomatis oleh MATSANAM E-Learning</Data></Cell></Row>';
            $xml .= '</Table><WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'
                . '<FreezePanes/><FrozenNoSplit/><SplitHorizontal>4</SplitHorizontal>'
                . '<TopRowBottomPane>4</TopRowBottomPane><ActivePane>2</ActivePane>'
                . '</WorksheetOptions></Worksheet></Workbook>';

            return response($xml, 200, [
                'Content-Type' => 'application/vnd.ms-excel; charset=UTF-8',
                'Content-Disposition' => 'attachment; filename="' . $fileName . '"',
                'Cache-Control' => 'no-store, no-cache, must-revalidate',
                'Pragma' => 'no-cache',
            ]);
        }

        if ($validated['format'] === 'csv') {
            $fileName = 'rekap_presensi_' . $validated['periode'] . '.csv';

            return new StreamedResponse(function () use ($absensis) {
                $output = fopen('php://output', 'wb');
                fwrite($output, "\xEF\xBB\xBF");
                // Pemisah titik koma lebih kompatibel dengan Excel regional Indonesia.
                fputcsv($output, [
                    'No', 'Nama Siswa', 'NISN', 'Kelas', 'Mata Pelajaran', 'Guru',
                    'Tanggal', 'Status', 'Metode Absen', 'Waktu Absen', 'Keterangan',
                ], ';', '"', '\\');

                foreach ($absensis as $index => $absen) {
                    $values = [
                        $index + 1,
                        $absen->siswa->nama_lengkap ?? '-',
                        $absen->siswa->nisn ?? '-',
                        $absen->jadwal->kelas->nama_kelas ?? '-',
                        $absen->jadwal->mataPelajaran->nama ?? '-',
                        $absen->jadwal->guru->nama_lengkap ?? '-',
                        optional($absen->tanggal)->format('d-m-Y') ?? '-',
                        ucfirst($absen->status ?? '-'),
                        strtoupper($absen->metode ?? '-'),
                        $absen->waktu_absen ?? '-',
                        $absen->keterangan ?? '-',
                    ];
                    $values = array_map(static function ($value) {
                        $value = (string) $value;
                        return preg_match('/^[=+@\\-\\t\\r]/', $value) ? "'" . $value : $value;
                    }, $values);
                    fputcsv($output, $values, ';', '"', '\\');
                }

                fclose($output);
            }, 200, [
                'Content-Type' => 'text/csv; charset=UTF-8',
                'Content-Disposition' => 'attachment; filename="' . $fileName . '"',
                'Cache-Control' => 'no-store, no-cache',
            ]);
        }

        // Tanpa package PDF pihak ketiga, sediakan halaman print-ready agar Admin bisa Save as PDF dari browser.
        return response()->view('admin.absensi.print', [
            'absensis' => $absensis,
            'periode' => $validated['periode'],
            'kelas' => ! empty($validated['kelas']) ? Kelas::find($validated['kelas']) : null,
        ]);
    }
}
