import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import 'rekap_absensi_screen.dart';
import 'upload_surat_screen.dart';

class AbsensiScreen extends StatefulWidget {
  const AbsensiScreen({super.key});

  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  bool _flashOn = false;
  bool _autoMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),

        title: const Text(
          'Scan Qr Presensi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              _showHelpDialog();
            },
            icon: const Icon(
              Icons.help_outline_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),

          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            12,
            24,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // INFORMASI SESI
              // =====================================================

              _buildSessionCard(),

              const SizedBox(height: 12),

              // =====================================================
              // QR SCANNER
              // =====================================================

              _buildScanner(),

              const SizedBox(height: 14),

              // =====================================================
              // GPS STATUS
              // =====================================================

              _buildGpsStatus(),

              const SizedBox(height: 18),

              // =====================================================
              // AJUKAN IZIN / SAKIT
              // =====================================================

              _buildPermissionButton(),

              const SizedBox(height: 8),

              // =====================================================
              // LIHAT REKAP
              // =====================================================

              _buildHistoryButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // SESSION CARD
  // ===============================================================

  Widget _buildSessionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        0,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          // Active session
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 7),

              const Text(
                'SESI AKTIF',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),

              const Spacer(),

              InkWell(
                onTap: () {
                  _showChangeSessionDialog();
                },
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Ganti Sesi',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.sync_rounded,
                        color: AppColors.textSecondary,
                        size: 13,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // Subject
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 15),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Matematika 9A (Jam Ke-3)',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Dra. Hj. Siti Rahmah • Ruang 204',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            height: 1,
            color: AppColors.border,
          ),

          // Time
          SizedBox(
            height: 44,
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: AppColors.textSecondary,
                  size: 16,
                ),

                const SizedBox(width: 7),

                const Text(
                  '08:45 – 09:30 WIB',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Presensi Masuk',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SCANNER
  // ===============================================================

  Widget _buildScanner() {
    return Container(
      width: double.infinity,
      height: 394,
      decoration: BoxDecoration(
        color: const Color(0xFF3D4446),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ---------------------------------------------------------
          // CAMERA BACKGROUND
          // ---------------------------------------------------------

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF5E6667),
                  Color(0xFF303536),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Simulasi dinding
                Positioned(
                  top: 55,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 145,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4D2C9),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),

                // Simulasi papan/proyektor
                Positioned(
                  top: 75,
                  right: 28,
                  child: Container(
                    width: 145,
                    height: 105,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        color: Color(0xFF20252A),
                        size: 72,
                      ),
                    ),
                  ),
                ),

                // Meja
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    color: const Color(0xFF6A4832),
                  ),
                ),

                // Overlay kamera
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.08),
                  ),
                ),
              ],
            ),
          ),

          // ---------------------------------------------------------
          // INSTRUCTION
          // ---------------------------------------------------------

          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 15,
                  ),

                  SizedBox(width: 7),

                  Text(
                    'Arahkan kamera ke QR Code di layar proyektor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------------------------------------------------------
          // SCAN FRAME
          // ---------------------------------------------------------

          Center(
            child: SizedBox(
              width: 190,
              height: 190,
              child: Stack(
                children: [
                  // Top left
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _buildCorner(
                      top: true,
                      left: true,
                    ),
                  ),

                  // Top right
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _buildCorner(
                      top: true,
                      left: false,
                    ),
                  ),

                  // Bottom left
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _buildCorner(
                      top: false,
                      left: true,
                    ),
                  ),

                  // Bottom right
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _buildCorner(
                      top: false,
                      left: false,
                    ),
                  ),

                  // Scan line
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 95,
                    child: Container(
                      height: 2,
                      color: const Color(0xFF22D3EE),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------------------------------------------------------
          // CAMERA CONTROLS
          // ---------------------------------------------------------

          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _flashOn = !_flashOn;
                        });
                      },
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            _flashOn
                                ? Icons.flash_on_rounded
                                : Icons.flash_off_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Kilat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 22,
                    color: Colors.white24,
                  ),

                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _autoMode = !_autoMode;
                        });
                      },
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.center_focus_strong_rounded,
                            color: _autoMode
                                ? const Color(0xFF22D3EE)
                                : Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Auto',
                            style: TextStyle(
                              color: _autoMode
                                  ? const Color(0xFF22D3EE)
                                  : Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 22,
                    color: Colors.white24,
                  ),

                  const Expanded(
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Kamera',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SCAN FRAME CORNER
  // ===============================================================

  Widget _buildCorner({
    required bool top,
    required bool left,
  }) {
    const double size = 22;
    const double thickness = 2;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            top: top ? 0 : null,
            bottom: top ? null : 0,
            left: left ? 0 : null,
            right: left ? null : 0,
            child: Container(
              width: size,
              height: thickness,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: top ? 0 : null,
            bottom: top ? null : 0,
            left: left ? 0 : null,
            right: left ? null : 0,
            child: Container(
              width: thickness,
              height: size,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // GPS STATUS
  // ===============================================================

  Widget _buildGpsStatus() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 8),

        const Text(
          'GPS Terdeteksi:',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(width: 5),

        const Text(
          'MTSN Matsanam • 12m dari Ruang 204',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),

        const Spacer(),

        const Icon(
          Icons.check_circle_outline_rounded,
          color: AppColors.success,
          size: 16,
        ),
      ],
    );
  }

  // ===============================================================
  // BUTTON AJUKAN IZIN / SAKIT
  // ===============================================================

  Widget _buildPermissionButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const UploadSuratScreen(),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          side: const BorderSide(
            color: AppColors.primary,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 19,
            ),
            SizedBox(width: 8),
            Text(
              'Ajukan Izin / Sakit',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // BUTTON REKAP ABSENSI
  // ===============================================================

  Widget _buildHistoryButton() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const RekapAbsensiScreen(),
            ),
          );
        },
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 17,
            ),
            SizedBox(width: 6),
            Text(
              'Lihat Rekap Absensi',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // HELP DIALOG
  // ===============================================================

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Cara Presensi',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Arahkan kamera ke QR Code presensi yang ditampilkan pada layar proyektor kelas. Pastikan GPS aktif dan berada di area madrasah.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Mengerti',
                style: TextStyle(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===============================================================
  // GANTI SESI
  // ===============================================================

  void _showChangeSessionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Ganti Sesi',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Fitur pemilihan sesi akan menampilkan jadwal presensi yang tersedia untuk siswa.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}