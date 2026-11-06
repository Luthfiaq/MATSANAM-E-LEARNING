<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use App\Models\Guru;
use App\Models\Kelas;
use App\Models\Siswa;
use App\Models\PeriodeAkademik;
use App\Models\MataPelajaran;
use App\Models\JadwalPelajaran;
use App\Models\PengumpulanTugas;
use App\Models\Penugasan;
use App\Models\Nilai;
use App\Models\SuratAbsensi;
use App\Models\AbsensiHarian;
use App\Models\Materi;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Admin
        User::create([
            'name' => 'Admin',
            'email' => 'admin@matsanam.sch.id',
            'password' => Hash::make('admin123'),
            'role' => 'admin',
        ]);

        // 2. Guru (44 guru)
        $guruData = [
            ['Ahmad Ulinuha, S.Pd., M.E.', '198109072005011002'],
            ['Senthot Sugiyono, S.Pd.', '196709011994121003'],
            ['Sti Syamsiatin, S.Pd.', '197008091998032001'],
            ['Siswoyo, S.Pd.', '197008052000031002'],
            ['Imam Kolik, S.Pd.', '197104152005011003'],
            ['Wakidatul Mardiyah, S.Pd.', '197108212005012003'],
            ['Maria Ulfah, M.Pd.I.', '197105292005012001'],
            ['Gijanto, S.Pd.', '196707182005011002'],
            ['Yuli Marlina, S.Pd.', '197507312005012003'],
            ['Akhmad Agus Alim, S.Pd.', '197108252005011005'],
            ['Margiani Firitami, S.Pd.', '196902062006042001'],
            ['Fathimatuz Zahrok, S.Ag.', '197212182997012022'],
            ['Ratna Rohmah Ermawati, S.Pd.', '197512042007102001'],
            ['Nuril Istikhomah, S.Pd.', '197808102007012009'],
            ['Mohamad Imam Bakri, S.Pd.', '196906062007011046'],
            ['Siti Romdiyah, S.Pd.', '197210232007012016'],
            ["Emmy Rif'atus Sholihah, S.Ag.", '197511062007012016'],
            ['Titin Suswati, S.Pd.', '197203032007012034'],
            ['Moch Syaiful Jihad, S.Pd.', '197704102005011004'],
            ['Siti Nurkholipah, S.E.', '198108142009012006'],
            ['Mohamad Asnan, S.Ag.', '196704242007011031'],
            ["Dra. Siti Ma'unati", '196910042007012024'],
            ['Mohamad Syaiful Haris Wibowo, S.Ag.', '197507152007101005'],
            ['Rukan, S.Ag., S.Pd.I.', '197405011014121002'],
            ['Jilik Asmaur Rosyidah, S.Ag.', '197711262014122001'],
            ['Atik Kusniatin, S.Pd.', '198002222014112001'],
            ['Agus Sutriono, S.Pd.', '198005152014121000'],
            ['Niswatul Ummah, S.Pd.', '198110242022212021'],
            ['Unun Hidayat, S.S.', '198404182023212033'],
            ['Sri Handayani, S.Pd.I.', '197908182023212008'],
            ['Bustanul Arifin, S.Pd.', '198401172023211008'],
            ['Salimah Nurhayati, S.Kom.', '198607232023212040'],
            ['Muhamad Najib, S.Pd.I.', '198510242024211008'],
            ['Hari Setyawan, S.E.', '198304282025211002'],
            ['Sunekono, S.Pd.', '197902072025211005'],
            ['Endah Masrurin, S.Pd.', '198304032025212016'],
            // NIP sementara: nomor asli tidak terbaca pada foto.
            ['Mohamad Yusup, S.Pd.', '199101012026012001'],
            ['M. Ayyub Mubtadik, S.Pd.I.', '199210052025211005'],
            ['Rifki Bagawara Utamas, S.Pd.', '200003032025051003'],
            ['Rudy Setiawan, S.Pd.', '199101302025211005'],
            // NIP sementara: nomor asli tidak terbaca pada foto.
            ["Siti Wasl'atur Rofiah, S.Pd.", '199202022026012002'],
            // NIP sementara: nomor asli tidak terbaca pada foto.
            ['Ika Puspitasari, S.Pd.', '199303032026012003'],
            // NIP sementara: nomor asli tidak terbaca pada foto.
            ['Virna Arumning Diah, S.Pd.', '199404042026012004'],
            // NIP sementara: nomor asli tidak terbaca pada foto.
            ['Roihana Fitri, S.Pd.I.', '199505052026012005'],
        ];

        $guruIds = [];
        foreach ($guruData as $idx => $data) {
            $user = User::create([
                'name' => $data[0],
                'email' => 'guru' . ($idx + 1) . '@matsanam.sch.id',
                'password' => Hash::make('guru123'),
                'role' => 'guru',
            ]);

            $guru = Guru::create([
                'user_id' => $user->id,
                'nip' => $data[1],
                'nama_lengkap' => $data[0],
                'jenis_kelamin' => ($idx % 2 == 0) ? 'L' : 'P',
                'telepon' => '08123456' . str_pad($idx, 4, '0', STR_PAD_LEFT),
            ]);

            $guruIds[] = $guru->id;
        }

        // 3. Kelas (9 kelas: VII A-C, VIII A-C, IX A-C)
        $kelasNames = ['VII A', 'VII B', 'VII C', 'VIII A', 'VIII B', 'VIII C', 'IX A', 'IX B', 'IX C'];
        $kelasIds = [];
        foreach ($kelasNames as $idx => $nama) {
            $tingkat = (int)substr($nama, 0, strpos($nama, ' '));
            $tingkatMap = ['VII' => 7, 'VIII' => 8, 'IX' => 9];
            
            $kelas = Kelas::create([
                'nama_kelas' => $nama,
                'tingkat' => $tingkatMap[explode(' ', $nama)[0]],
                'wali_kelas_id' => $guruIds[$idx],
                'kapasitas' => 35,
            ]);

            $kelasIds[] = $kelas->id;
        }

        // 4. Siswa (312 siswa, ~35 per kelas)
        $siswaCount = 0;
        foreach ($kelasIds as $kelasId) {
            for ($i = 1; $i <= 35; $i++) {
                $siswaCount++;
                $jenisKelamin = ($siswaCount % 2 == 0) ? 'L' : 'P';
                // Dua akun pertama sengaja dibuat mudah dikenali untuk demo:
                // siswa1 mengumpulkan tugas, sedangkan siswa2 belum mengumpulkan.
                if ($siswaCount === 1) {
                    $nama = 'Ayu Lestari';
                } elseif ($siswaCount === 2) {
                    $nama = 'Budi Pratama';
                } elseif ($siswaCount === 3) {
                    $nama = 'Dewi Wulandari';
                } elseif ($siswaCount === 4) {
                    $nama = 'Dani Setiawan';
                } else {
                    $nama = $jenisKelamin == 'L'
                        ? ['Ahmad', 'Budi', 'Dani', 'Eko', 'Fajar', 'Galih', 'Hadi', 'Indra', 'Joko'][rand(0, 8)] . ' ' . ['Pratama', 'Santoso', 'Wijaya', 'Setiawan'][rand(0, 3)]
                        : ['Ayu', 'Dewi', 'Eka', 'Fitri', 'Gita', 'Hana', 'Indah', 'Jihan'][rand(0, 7)] . ' ' . ['Lestari', 'Wulandari', 'Putri', 'Sari'][rand(0, 3)];
                }

                $user = User::create([
                    'name' => $nama,
                    'email' => 'siswa' . $siswaCount . '@matsanam.sch.id',
                    'password' => Hash::make('siswa123'),
                    'role' => 'siswa',
                ]);

                Siswa::create([
                    'user_id' => $user->id,
                    'nis' => '2024' . str_pad($siswaCount, 4, '0', STR_PAD_LEFT),
                    'nisn' => '000' . str_pad($siswaCount, 7, '0', STR_PAD_LEFT),
                    'nama_lengkap' => $nama,
                    'jenis_kelamin' => $jenisKelamin,
                    'tanggal_lahir' => '2010-01-01',
                    'tempat_lahir' => 'Nganjuk',
                    'kelas_id' => $kelasId,
                    'nama_wali' => 'Wali ' . $nama,
                    'telepon_wali' => '08129999' . str_pad($siswaCount, 4, '0', STR_PAD_LEFT),
                ]);
            }
        }

        // 5. Periode Akademik
        $periode = PeriodeAkademik::create([
            'nama' => 'Ganjil 2026/2027',
            'tahun_ajaran' => '2026/2027',
            'semester' => 'ganjil',
            'tanggal_mulai' => '2026-07-15',
            'tanggal_selesai' => '2026-12-20',
            'is_active' => true,
        ]);

        // 6. Mata Pelajaran
        $mapelData = [
            ['MTK', 'Matematika'],
            ['IPA', 'Ilmu Pengetahuan Alam'],
            ['IPS', 'Ilmu Pengetahuan Sosial'],
            ['BHS', 'Bahasa Indonesia'],
            ['ENG', 'Bahasa Inggris'],
            ['PKN', 'Pendidikan Kewarganegaraan'],
            ['AGM', 'Pendidikan Agama Islam'],
            ['SBD', 'Seni Budaya'],
            ['PJOK', 'Pendidikan Jasmani'],
        ];

        $mapelIds = [];
        foreach ($mapelData as $data) {
            $mapel = MataPelajaran::create([
                'kode' => $data[0],
                'nama' => $data[1],
                'kkm' => 75,
            ]);
            $mapelIds[] = $mapel->id;
        }

        // 7. Jadwal Pelajaran (sederhana, 1 jadwal per kelas per mapel)
        $hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
        foreach ($kelasIds as $kelasId) {
            foreach ($mapelIds as $idx => $mapelId) {
                JadwalPelajaran::create([
                    'periode_id' => $periode->id,
                    'kelas_id' => $kelasId,
                    'mapel_id' => $mapelId,
                    'guru_id' => $guruIds[$idx % count($guruIds)],
                    'hari' => $hari[$idx % 6],
                    'jam_mulai' => '07:30:00',
                    'jam_selesai' => '09:00:00',
                    'ruangan' => 'R' . ($kelasId),
                ]);
            }
        }

        // 8. Dummy Materi untuk variasi PDF, video, dan tautan.
        $jadwalFirst = JadwalPelajaran::first();
        foreach ([
            [
                'judul' => 'Modul Persamaan Linear',
                'deskripsi' => 'Ringkasan konsep, contoh penyelesaian, dan latihan persamaan linear.',
                'tipe' => 'pdf',
                'file_path' => null,
                'link' => null,
            ],
            [
                'judul' => 'Video Pembelajaran Aljabar',
                'deskripsi' => 'Video pengantar operasi aljabar dan penerapannya.',
                'tipe' => 'video',
                'file_path' => null,
                'link' => 'https://example.com/video-aljabar',
            ],
            [
                'judul' => 'Referensi Latihan Matematika',
                'deskripsi' => 'Tautan referensi tambahan untuk latihan mandiri.',
                'tipe' => 'link',
                'file_path' => null,
                'link' => 'https://example.com/latihan-matematika',
            ],
        ] as $materiData) {
            Materi::create(array_merge($materiData, [
                'jadwal_id' => $jadwalFirst->id,
                'guru_id' => $jadwalFirst->guru_id,
            ]));
        }

        // 9. Dummy Penugasan untuk testing
        $dummyPenugasan = Penugasan::create([
            'jadwal_id' => $jadwalFirst->id,
            'guru_id' => $jadwalFirst->guru_id,
            'judul' => 'Trigonometri Dasar',
            'deskripsi' => 'Soal latihan trigonometri untuk kelas VII',
            'jenis' => 'tugas',
            'deadline' => now()->addDays(7),
            'bobot' => 100,
        ]);

        // Tambahan tugas untuk mata pelajaran lain
        $jadwalMatematika = JadwalPelajaran::where('mapel_id', MataPelajaran::where('kode', 'MTK')->first()->id)->first();
        Penugasan::create([
            'jadwal_id' => $jadwalMatematika->id,
            'guru_id' => $jadwalMatematika->guru_id,
            'judul' => 'Persamaan Linier',
            'deskripsi' => 'Latihan persamaan linier satu variabel',
            'jenis' => 'tugas',
            'deadline' => now()->addDays(5),
            'bobot' => 80,
        ]);

        $jadwalIPA = JadwalPelajaran::where('mapel_id', MataPelajaran::where('kode', 'IPA')->first()->id)->first();
        Penugasan::create([
            'jadwal_id' => $jadwalIPA->id,
            'guru_id' => $jadwalIPA->guru_id,
            'judul' => 'Fotosintesis',
            'deskripsi' => 'Tugas tentang proses fotosintesis pada tumbuhan',
            'jenis' => 'quiz',
            'deadline' => now()->addDays(3),
            'bobot' => 50,
        ]);

        $jadwalIPS = JadwalPelajaran::where('mapel_id', MataPelajaran::where('kode', 'IPS')->first()->id)->first();
        Penugasan::create([
            'jadwal_id' => $jadwalIPS->id,
            'guru_id' => $jadwalIPS->guru_id,
            'judul' => 'Geografi Indonesia',
            'deskripsi' => 'Tugas makalah geografi fisik Indonesia',
            'jenis' => 'tugas',
            'deadline' => now()->addDays(10),
            'bobot' => 100,
        ]);

        $jadwalBhs = JadwalPelajaran::where('mapel_id', MataPelajaran::where('kode', 'BHS')->first()->id)->first();
        Penugasan::create([
            'jadwal_id' => $jadwalBhs->id,
            'guru_id' => $jadwalBhs->guru_id,
            'judul' => 'Puisi & Sajak',
            'deskripsi' => 'Membuat puisi bertema alam',
            'jenis' => 'tugas',
            'deadline' => now()->addDays(7),
            'bobot' => 75,
        ]);

        // 9. Surat Absensi Pending (8 surat untuk dashboard)
        $siswaList = Siswa::limit(8)->get();
        foreach ($siswaList as $idx => $siswa) {
            SuratAbsensi::create([
                'siswa_id' => $siswa->id,
                'tanggal_mulai' => '2026-10-04',
                'tanggal_selesai' => '2026-10-04',
                'jenis' => ($idx % 2 == 0) ? 'sakit' : 'izin',
                'alasan' => ($idx % 2 == 0) ? 'Demam tinggi' : 'Keperluan keluarga',
                'status_verifikasi' => 'pending',
            ]);
        }

        // 10. Dummy pengumpulan & nilai yang deterministik untuk alur demo.
        // Untuk setiap tugas: siswa1 mengumpulkan dan sudah dinilai,
        // siswa2 belum mengumpulkan, siswa3 mengumpulkan tetapi belum dinilai,
        // siswa4 mengumpulkan terlambat.
        $tugasList = Penugasan::with('jadwal')->take(5)->get();
        foreach ($tugasList as $tugas) {
            $siswaKelas = Siswa::where('kelas_id', $tugas->jadwal->kelas_id)
                ->orderBy('id')
                ->take(4)
                ->get();

            foreach ($siswaKelas as $index => $siswa) {
                if ($index === 1) {
                    continue; // siswa2 tetap belum mengumpulkan.
                }

                $submission = PengumpulanTugas::create([
                    'penugasan_id' => $tugas->id,
                    'siswa_id' => $siswa->id,
                    'jawaban' => 'Jawaban demo untuk tugas ' . $tugas->judul,
                    'file_jawaban' => null,
                    'waktu_pengumpulan' => now()->subHours(4 - $index),
                    'status' => $index === 3 ? 'terlambat' : 'tepat_waktu',
                ]);

                if ($index === 0) {
                    Nilai::create([
                        'pengumpulan_id' => $submission->id,
                        'nilai' => min(86, $tugas->bobot),
                        'catatan' => 'Jawaban sudah diperiksa dan memenuhi indikator.',
                        'guru_id' => $tugas->jadwal->guru_id,
                        'tanggal_penilaian' => now(),
                    ]);
                }
            }
        }
        // end dummy submission

        $jadwalFirst = JadwalPelajaran::first();
        $siswaAll = Siswa::limit(100)->get();
        $dates = ['2026-09-30', '2026-10-01', '2026-10-02', '2026-10-03', '2026-10-04', '2026-10-05'];
        $statusData = [
            ['hadir' => 92, 'izin' => 3, 'sakit' => 2, 'alpa' => 3],
            ['hadir' => 95, 'izin' => 2, 'sakit' => 1, 'alpa' => 2],
            ['hadir' => 94, 'izin' => 2, 'sakit' => 2, 'alpa' => 2],
            ['hadir' => 96, 'izin' => 2, 'sakit' => 1, 'alpa' => 1],
            ['hadir' => 93, 'izin' => 3, 'sakit' => 2, 'alpa' => 2],
            ['hadir' => 90, 'izin' => 5, 'sakit' => 3, 'alpa' => 2],
        ];

        foreach ($dates as $idx => $date) {
            $data = $statusData[$idx];
            $count = 0;
            foreach (['hadir', 'izin', 'sakit', 'alpa'] as $status) {
                for ($i = 0; $i < $data[$status]; $i++) {
                    if ($count >= $siswaAll->count()) break;
                    AbsensiHarian::create([
                        'siswa_id' => $siswaAll[$count]->id,
                        'jadwal_id' => $jadwalFirst->id,
                        'tanggal' => $date,
                        'status' => $status,
                        'waktu_absen' => '07:30:00',
                        'metode' => 'manual',
                    ]);
                    $count++;
                }
            }
        }

        // 10. Surat Absensi dengan berbagai status (untuk verifikasi)
        $siswaAll = Siswa::get();
        $statuses = ['pending', 'disetujui', 'ditolak'];
        foreach ($siswaAll as $idx => $siswa) {
            $status = $statuses[$idx % 3];
            $jadwal = JadwalPelajaran::where('kelas_id', $siswa->kelas_id)->first();
            SuratAbsensi::create([
                'siswa_id' => $siswa->id,
                'tanggal_mulai' => now()->subDays(rand(1, 10))->toDateString(),
                'tanggal_selesai' => now()->addDays(rand(1, 5))->toDateString(),
                'jenis' => ['sakit', 'izin'][rand(0, 1)],
                'alasan' => 'Alasan pengajuan dummy untuk testing',
                'status_verifikasi' => $status,
                'catatan_verifikasi' => $status === 'ditolak' ? 'Tidak memenuhi syarat' : null,
                'verifikator_id' => $status !== 'pending' ? Guru::first()->id : null,
                'tanggal_verifikasi' => $status !== 'pending' ? now() : null,
            ]);
        }

        // 11. Absensi Harian untuk beberapa jadwal/kelas (untuk rekap presensi)
        $allJadwal = JadwalPelajaran::take(5)->get();
        $tanggalRange = [
            now()->subDays(3)->toDateString(),
            now()->subDays(2)->toDateString(),
            now()->subDays(1)->toDateString(),
            now()->toDateString(),
        ];
        foreach ($allJadwal as $jadwal) {
            $siswaKelas = Siswa::where('kelas_id', $jadwal->kelas_id)->take(20)->get();
            foreach ($tanggalRange as $tanggal) {
                foreach ($siswaKelas as $idx => $siswa) {
                    $status = ['hadir', 'hadir', 'hadir', 'izin', 'sakit', 'alpa'][rand(0, 5)];
                    AbsensiHarian::create([
                        'siswa_id' => $siswa->id,
                        'jadwal_id' => $jadwal->id,
                        'tanggal' => $tanggal,
                        'status' => $status,
                        'waktu_absen' => '07:30:00',
                        'metode' => 'qr_code',
                    ]);
                }
            }
        }
    }
}
