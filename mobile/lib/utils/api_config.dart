/// Konfigurasi koneksi ke Laravel web-admin.
///
/// Jalankan Laravel dengan:  php artisan serve --host=0.0.0.0 --port=8000
///  - Emulator Android  : http://10.0.2.2:8000/api   (default di bawah)
///  - HP asli (satu wifi): http://IP-LAPTOP-KAMU:8000/api
///  - Web/Desktop/iOS sim: http://127.0.0.1:8000/api
///
/// Bisa juga diubah tanpa edit kode:
///  flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static const Duration timeout = Duration(seconds: 15);

  static Map<String, String> headers([String? token]) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
}
