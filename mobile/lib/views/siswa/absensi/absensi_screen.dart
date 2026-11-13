import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../services/siswa_learning_service.dart';
import '../../../utils/constants.dart';
import 'rekap_absensi_screen.dart';
import 'status_pengajuan_screen.dart';
import 'upload_surat_screen.dart';

class AbsensiScreen extends StatefulWidget {
  const AbsensiScreen({super.key});

  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  final SiswaLearningService _service = SiswaLearningService();

  bool _processing = false;
  bool _success = false;
  String? _message;
  Map<String, dynamic>? _attendance;

  @override
  void dispose() {
    unawaited(_scannerController.dispose());
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing || _success) return;

    String? rawValue;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) {
        rawValue = value;
        break;
      }
    }
    if (rawValue == null) return;

    // Only QR payloads issued by the Guru session are accepted.
    dynamic decoded;
    try {
      decoded = jsonDecode(rawValue);
    } catch (_) {
      return;
    }
    if (decoded is! Map ||
        decoded['sesi_id'] == null ||
        decoded['qr_token'] == null) {
      return;
    }

    setState(() {
      _processing = true;
      _message = 'Memvalidasi QR dan lokasi perangkat…';
    });
    await _scannerController.stop();

    try {
      final position = await _getCurrentPosition();
      final response = await _service.scanQr(
        qrData: rawValue,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
      final data = response['data'] is Map
          ? Map<String, dynamic>.from(response['data'] as Map)
          : <String, dynamic>{};
      if (!mounted) return;
      setState(() {
        _attendance = data;
        _success = true;
        _processing = false;
        _message =
            response['message']?.toString() ?? 'Presensi berhasil dicatat.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _success = false;
        _processing = false;
        _message = _cleanError(error);
      });
    }
  }

  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw StateError(
        'Aktifkan layanan lokasi/GPS perangkat sebelum melakukan presensi.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw StateError(
        'Izin lokasi belum diberikan. Izinkan lokasi untuk memvalidasi presensi.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw StateError(
        'Izin lokasi diblokir. Ubah izin lokasi aplikasi atau situs melalui pengaturan perangkat/browser.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 25),
      ),
    );
  }

  String _cleanError(Object error) => error
      .toString()
      .replaceFirst('Bad state: ', '')
      .replaceFirst('Exception: ', '');

  Future<void> _scanAgain() async {
    setState(() {
      _processing = false;
      _success = false;
      _message = null;
      _attendance = null;
    });
    try {
      await _scannerController.start();
    } catch (error) {
      if (mounted)
        setState(
          () => _message = 'Kamera tidak dapat dimulai: ${_cleanError(error)}',
        );
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _scannerController.toggleTorch();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flash tidak tersedia pada kamera ini.'),
          ),
        );
      }
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _scannerController.switchCamera();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kamera depan/belakang tidak dapat diganti.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Presensi QR')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: .55),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan QR dari Guru',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Arahkan kamera ke QR sesi yang sedang aktif. Aplikasi akan memeriksa token, kelas, masa berlaku, dan lokasi sesuai radius yang ditetapkan Guru.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.4,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 390,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (!_success)
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: _onDetect,
                      )
                    else
                      Container(color: const Color(0xFF0F172A)),
                    if (!_success)
                      IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 3),
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                      ),
                    if (_processing)
                      Container(
                        color: Colors.black.withValues(alpha: .62),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 14),
                              Text(
                                'Memvalidasi presensi…',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (_success)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 62,
                                color: Color(0xFF34D399),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Presensi Berhasil',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_attendance?['mapel'] ?? 'Mata pelajaran'}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                'Waktu: ${_attendance?['waktu_absen'] ?? '-'}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (!_success && !_processing)
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .68),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: _toggleTorch,
                                color: Colors.white,
                                tooltip: 'Flash',
                                icon: const Icon(Icons.flash_on_rounded),
                              ),
                              const Text(
                                'Kamera QR aktif',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              IconButton(
                                onPressed: _switchCamera,
                                color: Colors.white,
                                tooltip: 'Ganti kamera',
                                icon: const Icon(Icons.cameraswitch_rounded),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: _success
                      ? AppColors.successLight
                      : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _success ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            if (_message != null && !_processing && !_success) ...[
              const SizedBox(height: 9),
              OutlinedButton.icon(
                onPressed: _scanAgain,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Scan Lagi'),
              ),
            ],
            if (_success) ...[
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Selesai'),
              ),
            ],
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadSuratScreen()),
              ),
              icon: const Icon(Icons.description_outlined),
              label: const Text('Ajukan Izin / Sakit'),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StatusPengajuanScreen(),
                ),
              ),
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Lihat Status Pengajuan'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RekapAbsensiScreen()),
              ),
              icon: const Icon(Icons.history_rounded),
              label: const Text('Lihat Riwayat Absensi'),
            ),
            const SizedBox(height: 5),
            const Text(
              'Catatan: izin kamera dan lokasi diperlukan. Di Chrome, izinkan keduanya untuk localhost atau gunakan HTTPS saat menguji melalui alamat jaringan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
