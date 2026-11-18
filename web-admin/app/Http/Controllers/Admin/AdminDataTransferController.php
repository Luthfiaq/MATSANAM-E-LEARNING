<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Guru;
use App\Models\Kelas;
use App\Models\Siswa;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\StreamedResponse;

class AdminDataTransferController extends Controller
{
    private const MAX_ROWS = 2000;
    private const MAX_FILE_KB = 5120;

    public function index(Request $request): View
    {
        $this->cleanupTemporaryFiles($request);
        $pending = $request->session()->get($this->pendingSessionKey($request));
        if (is_array($pending) && (! isset($pending['path']) || ! Storage::disk('local')->exists($pending['path']))) {
            $request->session()->forget($this->pendingSessionKey($request));
            $pending = null;
        }
        $credentialPath = $request->session()->get($this->credentialsSessionKey($request));
        $credentialsAvailable = is_string($credentialPath) && Storage::disk('local')->exists($credentialPath);
        if (! $credentialsAvailable) $request->session()->forget($this->credentialsSessionKey($request));

        return view('admin.data-transfer.index', [
            'classes' => Kelas::orderBy('tingkat')->orderBy('nama_kelas')->get(['id', 'nama_kelas', 'tingkat']),
            'pending' => $pending,
            'credentialsAvailable' => $credentialsAvailable,
            'guruCount' => User::where('role', 'guru')->count(),
            'siswaCount' => User::where('role', 'siswa')->count(),
        ]);
    }

    public function template(string $role): StreamedResponse
    {
        $this->assertRole($role);
        $headers = $this->headersFor($role);

        return response()->streamDownload(function () use ($headers) {
            $output = fopen('php://output', 'w');
            fwrite($output, "\xEF\xBB\xBF");
            fputcsv($output, $headers);
            fclose($output);
        }, 'template-' . $role . '-matsanam.csv', ['Content-Type' => 'text/csv; charset=UTF-8']);
    }

    public function export(string $role): StreamedResponse
    {
        $this->assertRole($role);

        return response()->streamDownload(function () use ($role) {
            $output = fopen('php://output', 'w');
            fwrite($output, "\xEF\xBB\xBF");

            if ($role === 'guru') {
                fputcsv($output, ['nip', 'nama_lengkap', 'email', 'jenis_kelamin', 'telepon', 'alamat', 'is_active']);
                Guru::with('user')->orderBy('nama_lengkap')->chunk(300, function ($gurus) use ($output) {
                    foreach ($gurus as $guru) {
                        fputcsv($output, [
                            $this->safeCsv($guru->nip), $this->safeCsv($guru->nama_lengkap), $this->safeCsv($guru->user?->email),
                            $this->safeCsv($guru->jenis_kelamin), $this->safeCsv($guru->telepon), $this->safeCsv($guru->alamat),
                            $guru->user?->is_active ? 1 : 0,
                        ]);
                    }
                });
            } else {
                fputcsv($output, ['nis', 'nisn', 'nama_lengkap', 'email', 'jenis_kelamin', 'tanggal_lahir', 'tempat_lahir', 'kelas_id', 'nama_kelas', 'nama_wali', 'telepon_wali', 'alamat', 'is_active']);
                Siswa::with(['user', 'kelas'])->orderBy('nama_lengkap')->chunk(300, function ($students) use ($output) {
                    foreach ($students as $student) {
                        fputcsv($output, [
                            $this->safeCsv($student->nis), $this->safeCsv($student->nisn), $this->safeCsv($student->nama_lengkap),
                            $this->safeCsv($student->user?->email), $this->safeCsv($student->jenis_kelamin),
                            $student->tanggal_lahir?->format('Y-m-d'), $this->safeCsv($student->tempat_lahir),
                            $student->kelas_id, $this->safeCsv($student->kelas?->nama_kelas),
                            $this->safeCsv($student->nama_wali), $this->safeCsv($student->telepon_wali),
                            $this->safeCsv($student->alamat), $student->user?->is_active ? 1 : 0,
                        ]);
                    }
                });
            }

            fclose($output);
        }, 'data-' . $role . '-matsanam-' . now()->format('Ymd-His') . '.csv', [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Cache-Control' => 'no-store, no-cache, must-revalidate',
        ]);
    }

    public function preview(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'role' => ['required', Rule::in(['guru', 'siswa'])],
            'file' => ['required', 'file', 'max:' . self::MAX_FILE_KB],
        ]);

        $file = $request->file('file');
        if (strtolower($file->getClientOriginalExtension()) !== 'csv') {
            throw ValidationException::withMessages(['file' => 'Gunakan file CSV. File XLSX belum didukung oleh importer ini.']);
        }

        $sessionKey = $this->pendingSessionKey($request);
        $old = $request->session()->get($sessionKey);
        if (is_array($old) && ! empty($old['path'])) {
            Storage::disk('local')->delete($old['path']);
        }

        $filename = Str::uuid() . '.csv';
        $directory = 'admin-imports/' . $request->user()->id;
        $path = $file->storeAs($directory, $filename, 'local');

        try {
            $analysis = $this->analyzeCsv(Storage::disk('local')->path($path), $validated['role']);
        } catch (\Throwable $exception) {
            Storage::disk('local')->delete($path);
            throw $exception;
        }

        $token = Str::random(48);
        $request->session()->put($sessionKey, [
            'token' => $token,
            'role' => $validated['role'],
            'path' => $path,
            'rows' => $analysis['rows'],
            'valid' => $analysis['valid'],
            'invalid' => $analysis['invalid'],
            'preview' => $analysis['preview'],
            'errors' => $analysis['errors'],
            'headers' => $analysis['headers'],
        ]);

        if ($analysis['invalid'] > 0) {
            return redirect()->route('admin.data-transfer.index')
                ->with('warning', 'Preview menemukan baris yang perlu diperbaiki. Tidak ada data yang diimpor.');
        }

        return redirect()->route('admin.data-transfer.index')
            ->with('success', 'Preview valid. Periksa kembali ringkasan sebelum menekan Impor Data.');
    }

    public function import(Request $request): RedirectResponse
    {
        $pending = $request->session()->get($this->pendingSessionKey($request));
        abort_unless(is_array($pending) && ! empty($pending['path']) && ! empty($pending['token']), 404, 'Tidak ada preview impor aktif.');

        $validated = $request->validate(['import_token' => ['required', 'string', 'size:48']]);
        abort_unless(hash_equals($pending['token'], $validated['import_token']), 403);

        $path = $pending['path'];
        abort_unless(Storage::disk('local')->exists($path), 404, 'File preview sudah kedaluwarsa. Unggah ulang file CSV.');

        $analysis = $this->analyzeCsv(Storage::disk('local')->path($path), $pending['role']);
        if ($analysis['invalid'] > 0 || $analysis['valid'] < 1) {
            return redirect()->route('admin.data-transfer.index')
                ->with('warning', 'Impor dibatalkan karena terdapat baris tidak valid. Perbaiki file dan buat preview baru.');
        }

        $credentials = [];
        $credentialPath = null;
        try {
            DB::transaction(function () use ($analysis, $pending, &$credentials, &$credentialPath, $request) {
                foreach ($analysis['valid_rows'] as $row) {
                    $temporaryPassword = Str::random(20);
                    $user = User::create([
                        'name' => $row['nama_lengkap'],
                        'email' => $row['email'],
                        'password' => $temporaryPassword,
                        'role' => $pending['role'],
                        'is_active' => $row['is_active'],
                        'must_change_password' => true,
                    ]);

                    if ($pending['role'] === 'guru') {
                        Guru::create([
                            'user_id' => $user->id,
                            'nip' => $row['nip'],
                            'nama_lengkap' => $row['nama_lengkap'],
                            'jenis_kelamin' => $row['jenis_kelamin'],
                            'telepon' => $row['telepon'] ?? null,
                            'alamat' => $row['alamat'] ?? null,
                        ]);
                    } else {
                        Siswa::create([
                            'user_id' => $user->id,
                            'nis' => $row['nis'],
                            'nisn' => $row['nisn'],
                            'nama_lengkap' => $row['nama_lengkap'],
                            'jenis_kelamin' => $row['jenis_kelamin'],
                            'tanggal_lahir' => $row['tanggal_lahir'],
                            'tempat_lahir' => $row['tempat_lahir'],
                            'kelas_id' => $row['kelas_id'],
                            'nama_wali' => $row['nama_wali'] ?? null,
                            'telepon_wali' => $row['telepon_wali'] ?? null,
                            'alamat' => $row['alamat'] ?? null,
                        ]);
                    }

                    $credentials[] = [$pending['role'], $user->name, $user->email, $temporaryPassword];
                }

                // Generate the one-time credential file inside the transaction so a disk write failure rolls back the import.
                $credentialPath = $this->writeCredentialsCsv($request, $credentials);
            });
        } catch (\Throwable $exception) {
            if (is_string($credentialPath)) Storage::disk('local')->delete($credentialPath);
            throw $exception;
        }

        $oldCredentialPath = $request->session()->get($this->credentialsSessionKey($request));
        if (is_string($oldCredentialPath)) Storage::disk('local')->delete($oldCredentialPath);
        $request->session()->put($this->credentialsSessionKey($request), $credentialPath);
        Storage::disk('local')->delete($path);
        $request->session()->forget($this->pendingSessionKey($request));

        return redirect()->route('admin.data-transfer.index')
            ->with('success', count($credentials) . ' akun ' . strtoupper($pending['role']) . ' berhasil diimpor. Password sementara wajib diganti saat login pertama.');
    }

    public function cancel(Request $request): RedirectResponse
    {
        $pending = $request->session()->get($this->pendingSessionKey($request));
        if (is_array($pending) && ! empty($pending['path'])) {
            Storage::disk('local')->delete($pending['path']);
        }
        $request->session()->forget($this->pendingSessionKey($request));

        return redirect()->route('admin.data-transfer.index')->with('success', 'Preview impor dibatalkan.');
    }

    public function downloadCredentials(Request $request)
    {
        $sessionKey = $this->credentialsSessionKey($request);
        $path = $request->session()->get($sessionKey);
        abort_unless(is_string($path) && Storage::disk('local')->exists($path), 404, 'File kredensial tidak tersedia atau sudah diunduh.');

        $absolutePath = Storage::disk('local')->path($path);
        $request->session()->forget($sessionKey);

        return response()->download($absolutePath, 'kredensial-sementara-' . now()->format('Ymd-His') . '.csv', [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Cache-Control' => 'no-store, no-cache, must-revalidate',
        ])->deleteFileAfterSend(true);
    }

    private function analyzeCsv(string $absolutePath, string $role): array
    {
        $handle = fopen($absolutePath, 'rb');
        if ($handle === false) {
            throw ValidationException::withMessages(['file' => 'File CSV tidak dapat dibaca.']);
        }

        try {
            $sample = fgets($handle);
            if ($sample === false) {
                throw ValidationException::withMessages(['file' => 'File CSV kosong.']);
            }
            $delimiter = substr_count($sample, ';') > substr_count($sample, ',') ? ';' : ',';
            rewind($handle);

            $headers = fgetcsv($handle, 0, $delimiter, '"', '\\');
            if (! is_array($headers) || $headers === []) {
                throw ValidationException::withMessages(['file' => 'Header CSV tidak ditemukan.']);
            }
            $headers[0] = preg_replace('/^\xEF\xBB\xBF/', '', (string) $headers[0]);
            $headers = array_map(fn ($header) => $this->normalizeHeader((string) $header), $headers);
            if (count($headers) !== count(array_unique($headers))) {
                throw ValidationException::withMessages(['file' => 'File CSV memiliki nama kolom duplikat. Gunakan template yang disediakan.']);
            }

            $required = $role === 'guru'
                ? ['nip', 'nama_lengkap', 'email', 'jenis_kelamin']
                : ['nis', 'nisn', 'nama_lengkap', 'email', 'jenis_kelamin', 'tanggal_lahir', 'tempat_lahir', 'kelas_id'];

            $missing = array_values(array_diff($required, $headers));
            if ($missing !== []) {
                throw ValidationException::withMessages(['file' => 'Kolom wajib tidak ditemukan: ' . implode(', ', $missing) . '. Unduh template terbaru.']);
            }

            $allowed = $this->headersFor($role);
            $unknown = array_values(array_diff($headers, $allowed));
            if ($unknown !== []) {
                throw ValidationException::withMessages(['file' => 'Kolom tidak dikenal: ' . implode(', ', $unknown) . '. Gunakan header dari template.']);
            }

            $seen = [];
            $validRows = [];
            $errors = [];
            $preview = [];
            $dataRows = 0;

            while (($values = fgetcsv($handle, 0, $delimiter, '"', '\\')) !== false) {
                if ($values === [null] || (count(array_filter($values, fn ($v) => trim((string) $v) !== '')) === 0)) {
                    continue;
                }
                $dataRows++;
                if ($dataRows > self::MAX_ROWS) {
                    throw ValidationException::withMessages(['file' => 'Maksimal ' . self::MAX_ROWS . ' baris data per impor. Pisahkan file menjadi beberapa bagian.']);
                }

                $hasExtraColumns = count($values) > count($headers);
                $values = array_pad(array_slice($values, 0, count($headers)), count($headers), null);
                $record = array_combine($headers, array_map(fn ($value) => is_string($value) ? trim($value) : $value, $values));
                $record = $this->normalizeRecord($record, $role);
                $rowErrors = $this->validateRecord($record, $role, $seen, $dataRows + 1);
                if ($hasExtraColumns) $rowErrors[] = 'Jumlah kolom melebihi header template.';

                if ($rowErrors === []) {
                    $validRows[] = $record;
                } else {
                    $errors[] = ['row' => $dataRows + 1, 'messages' => $rowErrors];
                }

                if (count($preview) < 12) {
                    $preview[] = [
                        'row' => $dataRows + 1,
                        'name' => $record['nama_lengkap'] ?? '—',
                        'identifier' => $role === 'guru' ? ($record['nip'] ?? '—') : ($record['nis'] ?? '—'),
                        'email' => $record['email'] ?? '—',
                        'valid' => $rowErrors === [],
                        'errors' => $rowErrors,
                    ];
                }
            }

            if ($dataRows === 0) {
                throw ValidationException::withMessages(['file' => 'File tidak berisi baris data.']);
            }

            return [
                'headers' => $headers,
                'rows' => $dataRows,
                'valid' => count($validRows),
                'invalid' => count($errors),
                'valid_rows' => $validRows,
                'errors' => array_slice($errors, 0, 30),
                'preview' => $preview,
            ];
        } finally {
            fclose($handle);
        }
    }

    private function normalizeRecord(array $record, string $role): array
    {
        foreach ($record as $key => $value) {
            if (is_string($value)) $record[$key] = trim($value);
        }

        $record['email'] = strtolower((string) ($record['email'] ?? ''));
        $gender = Str::lower((string) ($record['jenis_kelamin'] ?? ''));
        $record['jenis_kelamin'] = in_array($gender, ['l', 'laki-laki', 'laki laki', 'male'], true) ? 'L'
            : (in_array($gender, ['p', 'perempuan', 'female'], true) ? 'P' : strtoupper($gender));
        $active = Str::lower((string) ($record['is_active'] ?? '1'));
        if ($active === '') $active = '1';
        if (in_array($active, ['1', 'true', 'aktif', 'yes', 'ya'], true)) {
            $record['is_active'] = true;
        } elseif (in_array($active, ['0', 'false', 'nonaktif', 'inactive', 'no', 'tidak'], true)) {
            $record['is_active'] = false;
        } else {
            $record['is_active'] = 'invalid';
        }

        if ($role === 'guru') {
            $record['nip'] = (string) ($record['nip'] ?? '');
        } else {
            $record['nis'] = (string) ($record['nis'] ?? '');
            $record['nisn'] = (string) ($record['nisn'] ?? '');
            $record['kelas_id'] = (int) ($record['kelas_id'] ?? 0);
        }

        return $record;
    }

    private function validateRecord(array $record, string $role, array &$seen, int $rowNumber): array
    {
        $rules = [
            'nama_lengkap' => ['required', 'string', 'max:150'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'jenis_kelamin' => ['required', Rule::in(['L', 'P'])],
            'is_active' => ['required', 'boolean'],
        ];

        if ($role === 'guru') {
            $rules += [
                'nip' => ['required', 'string', 'max:20', 'unique:guru,nip'],
                'telepon' => ['nullable', 'string', 'max:15'],
                'alamat' => ['nullable', 'string', 'max:2000'],
            ];
        } else {
            $rules += [
                'nis' => ['required', 'string', 'max:20', 'unique:siswa,nis'],
                'nisn' => ['required', 'string', 'max:20', 'unique:siswa,nisn'],
                'tanggal_lahir' => ['required', 'date_format:Y-m-d'],
                'tempat_lahir' => ['required', 'string', 'max:100'],
                'kelas_id' => ['required', 'integer', 'exists:kelas,id'],
                'nama_wali' => ['nullable', 'string', 'max:150'],
                'telepon_wali' => ['nullable', 'string', 'max:15'],
                'alamat' => ['nullable', 'string', 'max:2000'],
            ];
        }

        $validator = Validator::make($record, $rules);
        $messages = [];
        if ($validator->fails()) {
            $messages = array_merge($messages, array_values($validator->errors()->all()));
        }

        $uniqueFields = $role === 'guru' ? ['email', 'nip'] : ['email', 'nis', 'nisn'];
        foreach ($uniqueFields as $field) {
            $value = (string) ($record[$field] ?? '');
            if ($value === '') continue;
            $key = $field . ':' . Str::lower($value);
            if (isset($seen[$key])) {
                $messages[] = strtoupper($field) . ' duplikat di dalam file (baris ' . $seen[$key] . ').';
            } else {
                $seen[$key] = $rowNumber;
            }
        }

        return array_values(array_unique($messages));
    }

    private function headersFor(string $role): array
    {
        return $role === 'guru'
            ? ['nip', 'nama_lengkap', 'email', 'jenis_kelamin', 'telepon', 'alamat', 'is_active']
            : ['nis', 'nisn', 'nama_lengkap', 'email', 'jenis_kelamin', 'tanggal_lahir', 'tempat_lahir', 'kelas_id', 'nama_kelas', 'nama_wali', 'telepon_wali', 'alamat', 'is_active'];
    }

    private function normalizeHeader(string $header): string
    {
        $header = Str::lower(trim($header));
        return preg_replace('/[^a-z0-9_]/', '', str_replace([' ', '-'], '_', $header));
    }

    private function assertRole(string $role): void
    {
        abort_unless(in_array($role, ['guru', 'siswa'], true), 404);
    }

    private function cleanupTemporaryFiles(Request $request): void
    {
        $disk = Storage::disk('local');
        $pendingDirectory = 'admin-imports/' . $request->user()->id;
        foreach ($disk->files($pendingDirectory) as $file) {
            if ($disk->lastModified($file) < now()->subHours(2)->timestamp) $disk->delete($file);
        }

        $credentialsDirectory = 'admin-import-credentials/' . $request->user()->id;
        foreach ($disk->files($credentialsDirectory) as $file) {
            if ($disk->lastModified($file) < now()->subMinutes(30)->timestamp) $disk->delete($file);
        }
    }

    private function pendingSessionKey(Request $request): string
    {
        return 'admin_data_transfer_pending_' . $request->user()->id;
    }

    private function credentialsSessionKey(Request $request): string
    {
        return 'admin_data_transfer_credentials_' . $request->user()->id;
    }

    private function writeCredentialsCsv(Request $request, array $credentials): string
    {
        $directory = 'admin-import-credentials/' . $request->user()->id;
        $name = Str::uuid() . '.csv';
        $path = $directory . '/' . $name;
        $absolute = Storage::disk('local')->path($path);
        Storage::disk('local')->makeDirectory($directory);
        $handle = fopen($absolute, 'wb');
        fwrite($handle, "\xEF\xBB\xBF");
        fputcsv($handle, ['role', 'nama_lengkap', 'email', 'password_sementara']);
        foreach ($credentials as $row) fputcsv($handle, array_map(fn ($value) => $this->safeCsv((string) $value), $row));
        fclose($handle);

        return $path;
    }

    private function safeCsv(?string $value): string
    {
        $value = (string) $value;
        return preg_match('/^[\s]*[=+\-@]/u', $value) ? "'" . $value : $value;
    }
}
