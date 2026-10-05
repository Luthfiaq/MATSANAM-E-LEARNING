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
use App\Models\AbsensiHarian;
use App\Models\SuratAbsensi;

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

        // 2. Guru (24 guru)
        $guruData = [
            ['Drs. Ahmad Fauzi, M.Pd', '196501011990031001'],
            ['Siti Nurhaliza, S.Pd', '197203151995122001'],
            ['Budi Santoso, S.Pd', '198005102006041002'],
            ['Lina Marlina, S.Pd.I', '198507252010012003'],
            ['Eko Prasetyo, S.Pd', '197812202005011001'],
            ['Fatimah Azzahra, S.Pd', '199001152015032001'],
            ['Agus Setiawan, S.Pd', '197906102008011002'],
            ['Dewi Lestari, S.Pd', '198803182012022001'],
            ['Hendra Gunawan, S.Pd', '198211252009031001'],
            ['Sri Wahyuni, S.Pd', '199505102018012001'],
            ['Muhammad Ridwan, S.Pd', '197708152006041001'],
            ['Nurul Hidayah, S.Pd', '198912222014032002'],
            ['Dedi Supriadi, S.Pd', '198104102010011001'],
            ['Rina Kusuma, S.Pd', '199207182016012001'],
            ['Bambang Wicaksono, S.Pd', '197502052003121001'],
            ['Yunita Sari, S.Pd', '199110252015032001'],
            ['Firman Hakim, S.Pd', '198306152008011001'],
            ['Lilis Suryani, S.Pd', '199403202017012001'],
            ['Andi Wijaya, S.Pd', '197909102004011001'],
            ['Ratna Dewi, S.Pd', '199608152019032001'],
            ['Hendro Purnomo, S.Pd', '198001202007011001'],
            ['Ani Setiawati, S.Pd', '199212102015032001'],
            ['Rahmat Hidayat, S.Pd', '197705152002121001'],
            ['Tri Wahyuni, S.Pd', '199809252020012001'],
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
                $nama = $jenisKelamin == 'L' 
                    ? ['Ahmad', 'Budi', 'Dani', 'Eko', 'Fajar', 'Galih', 'Hadi', 'Indra', 'Joko'][rand(0, 8)] . ' ' . ['Pratama', 'Santoso', 'Wijaya', 'Setiawan'][rand(0, 3)]
                    : ['Ayu', 'Dewi', 'Eka', 'Fitri', 'Gita', 'Hana', 'Indah', 'Jihan'][rand(0, 7)] . ' ' . ['Lestari', 'Wulandari', 'Putri', 'Sari'][rand(0, 3)];

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

        // 8. Surat Absensi Pending (8 surat untuk dashboard)
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

        // 9. Absensi Harian (untuk chart mingguan)
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
    }
}
