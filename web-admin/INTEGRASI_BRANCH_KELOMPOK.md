# Integrasi Web Admin Kelompok — MATSANAM

Dokumen ini mencatat penggabungan snapshot ZIP kelompok ke basis `web-admin` MATSANAM yang sudah memiliki Manajemen Akun, Materi, Tugas, Nilai, serta patch navigasi/sidebar.

## Sumber yang diperiksa

ZIP kelompok berisi tiga snapshot proyek dari branch/anggota berbeda:

- `web-admin by e41251341-ui`: master data Guru, Siswa, Kelas, Mata Pelajaran, Periode Akademik, Jadwal Pelajaran, Pengaturan, serta sebagian layar Admin.
- `web-admin by danisnuramelina24012007-source`: implementasi Absensi dan Penugasan.
- `web-admin by agustinriski0608-gif`: versi lain dari Penugasan.

ZIP tersebut tidak menyertakan direktori `.git`, sehingga riwayat commit dan hubungan antar-branch tidak dapat diverifikasi hanya dari arsip.

## Keputusan integrasi

1. Mempertahankan controller Master Data dan Penugasan dari basis MATSANAM yang sedang digunakan karena memiliki validasi yang lebih lengkap, pencatatan aktivitas, perlindungan relasi, dan pemeriksaan bentrok jadwal.
2. Mendaftarkan seluruh route CRUD Master Data yang sebelumnya belum terhubung ke `routes/web.php`.
3. Mendaftarkan halaman Pengaturan Admin dan endpoint update profil/password.
4. Mempertahankan layout/sidebar MATSANAM dan memperbaiki referensi route Nilai yang sebelumnya mengirim argumen kedua berupa string.
5. Memilih tampilan Absensi Verifikasi dan Rekap yang paling sesuai dengan fungsi kelompok dan memperbaiki kontrak data controller-view.
6. Mengubah rekap statistik agar mengikuti filter periode dan kelas. Filter status hanya memengaruhi tabel, bukan kartu ringkasan.
7. Menambahkan preview/unduh surat melalui route yang memeriksa berkas pada `storage` disk `public`.
8. Menerapkan surat sakit/izin yang disetujui ke catatan absensi berdasarkan jadwal siswa pada rentang tanggal surat. Status `dispensasi` tidak digunakan karena tidak termasuk enum status absensi pada skema aktif.
9. Menolak pemrosesan ulang surat yang sudah disetujui/ditolak.
10. Mengganti ekspor yang sebelumnya memanggil package Excel/PDF yang tidak tersedia:
    - `Excel`/`CSV` menghasilkan CSV UTF-8 yang kompatibel dengan Excel, disertai perlindungan formula injection.
    - `PDF` membuka laporan print-ready agar Admin dapat memilih Save as PDF dari browser.

## Perubahan penting

- `routes/web.php`
- `app/Http/Controllers/Admin/AbsensiController.php`
- `resources/views/admin/absensi/verifikasi.blade.php`
- `resources/views/admin/absensi/rekap.blade.php`
- `resources/views/admin/absensi/print.blade.php` (baru)
- `resources/views/layouts/partials/sidebar.blade.php`
- `resources/views/admin/guru/index.blade.php`
- `resources/views/admin/guru/create.blade.php`
- `resources/views/admin/guru/edit.blade.php`

## Validasi yang berhasil

- `php artisan route:list --json`: 120 route dapat dimuat.
- Pemeriksaan referensi route bernama pada Blade: tidak ditemukan route bernama yang hilang.
- PHP lint untuk controller, route, dan migration: lolos.
- BladeCompiler berhasil mengompilasi 51 template Blade.
- ZIP sumber diuji dengan `unzip -t`.

## Batas validasi lingkungan

PHP runtime pada lingkungan penyusunan tidak memiliki ekstensi `dom`, `mbstring`, dan `pdo_sqlite`. Karena itu `php artisan view:cache`, migrasi SQLite, PHPUnit, dan uji CRUD terhadap database nyata tidak dapat dijalankan di sini. Jalankan pengujian tersebut pada komputer pengembangan sebelum deployment.

## Langkah setelah pemasangan

Dari folder `web-admin`:

```powershell
php artisan optimize:clear
php artisan route:list
php artisan migrate --pretend
```

Jika daftar migrasi sudah diperiksa dan aman, jalankan migrasi yang memang belum diterapkan:

```powershell
php artisan migrate
```

Lalu uji login Admin dan alur berikut:

- CRUD Guru, Siswa, Kelas, Mata Pelajaran, Periode Akademik, dan Jadwal Pelajaran.
- Buat/edit/hapus penugasan dan pastikan validasi bentrok jadwal bekerja.
- Verifikasi surat sakit/izin, cek catatan absensi yang terbentuk, dan pastikan surat yang sudah diproses tidak bisa diproses ulang.
- Rekap absensi dengan filter bulan dan kelas.
- Ekspor CSV dan cetak laporan ke PDF dari browser.

Jangan jalankan `migrate:fresh` pada database yang berisi data penting.
