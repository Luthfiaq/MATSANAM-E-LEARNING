# MATSANAM — Manajemen Akun Guru & Siswa

Modul ini menambahkan halaman administrasi untuk membuat, mencari, melihat, mengubah, mereset password, serta mengaktifkan/menonaktifkan akun Guru dan Siswa.

## Halaman

- `GET /admin/accounts` — semua akun, statistik, pencarian, filter role/status/kelas/mapel, dan pagination.
- `GET /admin/accounts/create/guru` — form tambah Guru.
- `GET /admin/accounts/create/siswa` — form tambah Siswa.
- `GET /admin/accounts/{user}` — detail profil, status, login terakhir, riwayat tindakan, dan modal aksi.
- `GET /admin/accounts/{user}/edit` — edit profil dan status.

Semua route web berada di bawah middleware `auth` + `EnsureUserIsAdmin`.

## Database

Migration baru: `2026_11_11_000001_add_account_management_fields.php`

Kolom tambahan pada `users`:

- `last_login_at` — waktu login terakhir dari web/API.
- `must_change_password` — flag penggantian password setelah Admin membuat/reset password.
- `last_password_reset_at` — waktu reset password terakhir.

Tabel baru `user_account_logs` mencatat pembuatan akun, perubahan profil, perubahan status, reset password, dan penggantian password oleh pengguna.

Jalankan setelah backup database:

```bash
cd web-admin
php artisan migrate
php artisan optimize:clear
php artisan route:list --path=admin/accounts
```

Jangan menjalankan `migrate:fresh` pada database yang berisi data sekolah.

## Perilaku keamanan

- Password disimpan melalui hashed cast pada model `User`; password plaintext tidak disimpan di database.
- Password sementara hanya di-flash ke halaman detail segera setelah akun dibuat atau password direset. Setelah request berikutnya, password tersebut tidak ditampilkan lagi.
- Reset password mencabut seluruh Sanctum token lama milik pengguna.
- Menonaktifkan akun juga mencabut seluruh Sanctum token dan memblokir login melalui pemeriksaan `is_active` yang sudah ada.
- Akun Admin tidak ditampilkan di daftar ini dan tidak dapat dikelola melalui controller ini. Admin yang sedang login tidak dapat menonaktifkan dirinya sendiri.
- Akun tidak dihapus secara permanen dari halaman ini agar histori akademik dan audit tetap terjaga.
- Mata pelajaran dan kelas mengajar Guru ditampilkan dari relasi jadwal/penugasan, bukan disimpan sebagai field duplikat pada profil Guru.

## Penggantian password wajib

Web-admin menyimpan flag `must_change_password` dan API login serta `/api/auth/me` mengembalikan flag tersebut pada objek user. Endpoint tersedia:

```http
POST /api/auth/change-password
Authorization: Bearer <token>
Content-Type: application/json

{
  "current_password": "password-sementara",
  "password": "password-baru-minimal-10-karakter",
  "password_confirmation": "password-baru-minimal-10-karakter"
}
```

Endpoint ini memvalidasi password saat ini, menyimpan password baru dengan hashing, menghapus flag `must_change_password`, dan mencatat audit log. Aplikasi Flutter Guru/Siswa masih perlu memeriksa flag dari respons login/`auth/me` dan menampilkan layar penggantian password wajib agar alurnya benar-benar enforced di sisi mobile.

## Catatan model data

Form Guru memakai field yang memang tersedia di tabel `guru` (`nip`, `nama_lengkap`, `jenis_kelamin`, `telepon`, `alamat`). NUPTK tidak ditampilkan karena belum ada kolom NUPTK di migration proyek saat ini. Penugasan mata pelajaran/kelas dilakukan melalui menu penugasan guru.

Form Siswa mengikuti field wajib yang ada di migration `siswa`, termasuk NIS, NISN, jenis kelamin, tanggal lahir, tempat lahir, dan kelas.

## Verifikasi yang dilakukan saat penyusunan

- PHP lint pada controller, model, migration, dan file route.
- Laravel route discovery untuk route web Manajemen Akun dan API change-password.
- Kompilasi sintaks Blade untuk lima view baru.

Eksekusi migration dan pengujian transaksi database belum dilakukan pada lingkungan penyusunan karena ekstensi PDO SQLite tidak tersedia. Jalankan migration dan uji alur CRUD di lingkungan pengembangan proyek sebelum digunakan di sekolah.
