import 'package:flutter/material.dart';

import '../../../utils/constants.dart';

class RekapAbsensiScreen extends StatefulWidget {
  const RekapAbsensiScreen({
    super.key,
  });

  @override
  State<RekapAbsensiScreen> createState() =>
      _RekapAbsensiScreenState();
}

class _RekapAbsensiScreenState extends State<RekapAbsensiScreen> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,

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
          'Rekap Histori Presensi',
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
            margin: const EdgeInsets.only(
              right: 16,
            ),
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
            16,
            24,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodSelector(),

              const SizedBox(height: 16),

              _buildAttendanceSummary(),

              const SizedBox(height: 16),

              _buildFilterTabs(),

              const SizedBox(height: 16),

              _buildAttendanceList(),

              const SizedBox(height: 20),

              _buildDownloadButton(),

              const SizedBox(height: 12),

              _buildSyncText(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PERIOD SELECTOR
  // ============================================================

  Widget _buildPeriodSelector() {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Bulan
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.primary,
                  size: 17,
                ),

                const SizedBox(width: 8),

                const Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bulan',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'September 2026',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),

          Container(
            width: 1,
            height: 36,
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            color: AppColors.border,
          ),

          // Semester
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.school_outlined,
                  color: AppColors.success,
                  size: 18,
                ),

                const SizedBox(width: 8),

                const Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Semester',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Ganjil 26/27',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ATTENDANCE SUMMARY
  // ============================================================

  Widget _buildAttendanceSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration:
                              const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: 7),

                        const Text(
                          'TINGKAT KEHADIRAN',
                          style: TextStyle(
                            color:
                                AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '96.2%',
                          style: TextStyle(
                            color:
                                AppColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.successLight,
                            borderRadius:
                                BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Sangat Baik',
                            style: TextStyle(
                              color:
                                  AppColors.success,
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: AppColors.success,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Predikat Disiplin',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Minimum requirement
          Row(
            children: [
              const Text(
                'Syarat Minimum (85%)',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),

              const Spacer(),

              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.success,
                size: 15,
              ),

              const SizedBox(width: 4),

              const Text(
                'Aman',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          // Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(
                    color: AppColors.primaryLight,
                  ),

                  FractionallySizedBox(
                    widthFactor: 0.962,
                    child: Container(
                      color: AppColors.success,
                    ),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    child: Row(
                      children: [
                        const Spacer(
                          flex: 85,
                        ),
                        Container(
                          width: 2,
                          height: 8,
                          color: AppColors.textSecondary
                              .withOpacity(0.45),
                        ),
                        const Spacer(
                          flex: 15,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatisticCard(
                  title: 'Hadir',
                  value: '25',
                  subtitle: 'Hari',
                  valueColor: AppColors.textPrimary,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildStatisticCard(
                  title: 'Sakit',
                  value: '1',
                  subtitle: 'Surat',
                  valueColor: AppColors.warning,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildStatisticCard(
                  title: 'Izin',
                  value: '0',
                  subtitle: 'Hari',
                  valueColor: AppColors.textPrimary,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildStatisticCard(
                  title: 'Alfa',
                  value: '0',
                  subtitle: 'Hari',
                  valueColor: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATISTIC CARD
  // ============================================================

  Widget _buildStatisticCard({
    required String title,
    required String value,
    required String subtitle,
    required Color valueColor,
  }) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 1),

          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Widget _buildFilterTabs() {
    return Row(
      children: [
        _buildFilterButton(
          label: 'Semua (26)',
          value: 'Semua',
        ),

        const SizedBox(width: 8),

        _buildFilterButton(
          label: 'Hadir (25)',
          value: 'Hadir',
        ),

        const SizedBox(width: 8),

        _buildFilterButton(
          label: 'Sakit / Izin (1)',
          value: 'Sakit / Izin',
        ),
      ],
    );
  }

  Widget _buildFilterButton({
    required String label,
    required String value,
  }) {
    final bool selected =
        _selectedFilter == value;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
        },
        child: Container(
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: selected
                ? null
                : Border.all(
                    color: AppColors.border,
                  ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : AppColors.textPrimary,
              fontSize: 11,
              fontWeight: selected
                  ? FontWeight.w600
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ATTENDANCE LIST
  // ============================================================

  Widget _buildAttendanceList() {
    if (_selectedFilter == 'Hadir') {
      return Column(
        children: [
          _buildAttendanceItem(
            date: 'Sabtu, 20 Sep 2026',
            subject: 'Upacara & Bimbingan',
            time: '07:05 WIB',
            status: 'Hadir',
            isPresent: true,
          ),
          const SizedBox(height: 8),
          _buildAttendanceItem(
            date: 'Jumat, 19 Sep 2026',
            subject: 'PAI & Fiqih',
            time: '07:30 WIB',
            status: 'Hadir',
            isPresent: true,
          ),
          const SizedBox(height: 8),
          _buildAttendanceItem(
            date: 'Kamis, 18 Sep 2026',
            subject: 'Bahasa Inggris',
            time: '09:45 WIB',
            status: 'Hadir',
            isPresent: true,
          ),
          const SizedBox(height: 8),
          _buildAttendanceItem(
            date: 'Selasa, 16 Sep 2026',
            subject: 'IPA Terpadu',
            time: '08:00 WIB',
            status: 'Hadir',
            isPresent: true,
          ),
        ],
      );
    }

    if (_selectedFilter == 'Sakit / Izin') {
      return _buildAttendanceItem(
        date: 'Rabu, 17 Sep 2026',
        subject: 'Matematika',
        time: '',
        status: 'Sakit',
        isPresent: false,
        showLetter: true,
      );
    }

    return Column(
      children: [
        _buildAttendanceItem(
          date: 'Sabtu, 20 Sep 2026',
          subject: 'Upacara & Bimbingan',
          time: '07:05 WIB',
          status: 'Hadir',
          isPresent: true,
        ),

        const SizedBox(height: 8),

        _buildAttendanceItem(
          date: 'Jumat, 19 Sep 2026',
          subject: 'PAI & Fiqih',
          time: '07:30 WIB',
          status: 'Hadir',
          isPresent: true,
        ),

        const SizedBox(height: 8),

        _buildAttendanceItem(
          date: 'Kamis, 18 Sep 2026',
          subject: 'Bahasa Inggris',
          time: '09:45 WIB',
          status: 'Hadir',
          isPresent: true,
        ),

        const SizedBox(height: 8),

        _buildAttendanceItem(
          date: 'Rabu, 17 Sep 2026',
          subject: 'Matematika',
          time: '',
          status: 'Sakit',
          isPresent: false,
          showLetter: true,
        ),

        const SizedBox(height: 8),

        _buildAttendanceItem(
          date: 'Selasa, 16 Sep 2026',
          subject: 'IPA Terpadu',
          time: '08:00 WIB',
          status: 'Hadir',
          isPresent: true,
        ),
      ],
    );
  }

  // ============================================================
  // ATTENDANCE ITEM
  // ============================================================

  Widget _buildAttendanceItem({
    required String date,
    required String subject,
    required String time,
    required String status,
    required bool isPresent,
    bool showLetter = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              14,
              14,
              14,
              12,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isPresent
                        ? AppColors.successLight
                        : AppColors.warningLight,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isPresent
                        ? Icons.check_rounded
                        : Icons.medical_services_outlined,
                    color: isPresent
                        ? AppColors.success
                        : AppColors.warning,
                    size: 19,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          color:
                              AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              subject,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors
                                    .textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ),

                          if (isPresent) ...[
                            const Padding(
                              padding:
                                  EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: Text(
                                '•',
                                style: TextStyle(
                                  color: AppColors
                                      .textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ),

                            const Icon(
                              Icons.qr_code_2_rounded,
                              color:
                                  AppColors.textSecondary,
                              size: 13,
                            ),

                            const SizedBox(width: 3),

                            const Text(
                              'QR Code',
                              style: TextStyle(
                                color: AppColors
                                    .textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPresent
                            ? AppColors.successLight
                            : AppColors.warningLight,
                        borderRadius:
                            BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isPresent
                              ? AppColors.success
                              : AppColors.warning,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),

                    if (time.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          color:
                              AppColors.textSecondary,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          if (showLetter)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),

                  const SizedBox(width: 6),

                  const Expanded(
                    child: Text(
                      'Surat Dokter (Disetujui)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      _showLetterDialog();
                    },
                    child: const Text(
                      'Lihat Surat',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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

  // ============================================================
  // DOWNLOAD BUTTON
  // ============================================================

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          _showDownloadMessage();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_outlined,
              size: 19,
            ),
            SizedBox(width: 8),
            Text(
              'Unduh Rekap Presensi PDF',
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

  // ============================================================
  // SYNC TEXT
  // ============================================================

  Widget _buildSyncText() {
    return const Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sync_rounded,
            color: Color(0xFF94A3B8),
            size: 14,
          ),

          SizedBox(width: 5),

          Text(
            'Tersinkronisasi dengan Sistem Absensi Digital Kemenag RI',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIALOGS
  // ============================================================

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Rekap Presensi',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Halaman ini menampilkan riwayat kehadiran siswa berdasarkan bulan dan semester yang dipilih.',
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

  void _showLetterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Surat Dokter',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Surat dokter untuk ketidakhadiran pada Rabu, 17 September 2026 telah disetujui.',
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

  void _showDownloadMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Fitur unduh PDF akan dihubungkan ke API.',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }
}