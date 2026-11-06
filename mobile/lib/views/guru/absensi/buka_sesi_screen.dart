import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/api_config.dart';
import '../../../utils/constants.dart';
import '../../../widgets/common/qr_code_widget.dart';
import '../../../widgets/common/status_badge.dart';
import '../../../widgets/common/progress_bar_with_label.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../widgets/common/custom_app_bar.dart';

class BukaSesiScreen extends StatefulWidget {
  final Map<String, dynamic> jadwal;
  const BukaSesiScreen({super.key, this.jadwal = const {}});

  @override
  State<BukaSesiScreen> createState() => _BukaSesiScreenState();
}

class _BukaSesiScreenState extends State<BukaSesiScreen> {
  final _location = {'latitude': -6.200000, 'longitude': 106.816666};
  int _radius = 150;
  bool _toleransi = false;
  bool _loading = false;
  bool _startingSession = false;
  bool _sessionActive = false;
  String? _qrData;
  String? _sessionId;
  DateTime? _expiredAt;
  Timer? _refreshTimer;
  Timer? _attendanceTimer;
  
  // Real-time attendance data
  int _totalStudents = 0;
  int _presentStudents = 0;
  List<Map<String, dynamic>> _recentScans = [];

  @override
  void initState() {
    super.initState();
    _totalStudents = (widget.jadwal['jumlah_siswa'] as num?)?.toInt() ?? 0;
    final existingId = widget.jadwal['sesi_id'];
    final hasActiveSession = widget.jadwal['status_absensi'] == 'aktif' && existingId != null;
    if (hasActiveSession) {
      _sessionActive = true;
      _sessionId = existingId.toString();
      _loading = true;
      _loadActiveSession();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _attendanceTimer?.cancel();
    super.dispose();
  }

  Future<String?> _refreshQR() async {
    final id = _sessionId;
    if (id == null || id.isEmpty || !_sessionActive) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('Sesi login tidak ditemukan. Silakan masuk kembali.');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/guru/absensi/session/$id/regenerate-qr'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);

      final decoded = json.decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300 ||
          decoded is! Map || decoded['success'] != true || decoded['data'] is! Map) {
        final message = decoded is Map ? decoded['message'] : null;
        throw Exception(message?.toString() ?? 'QR Code gagal diperbarui.');
      }

      final data = Map<String, dynamic>.from(decoded['data']);
      final qrData = data['qr_data']?.toString();
      if (qrData == null || qrData.isEmpty) {
        throw Exception('Server tidak mengirim data QR yang valid.');
      }

      if (!mounted) return null;
      _qrData = qrData;
      _expiredAt = DateTime.tryParse(data['expired_at']?.toString() ?? '') ?? _expiredAt;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Code berhasil dibuat ulang.'),
          duration: Duration(seconds: 2),
        ),
      );
      return qrData;
    } catch (error) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
      return null;
    }
  }

  void _startAutoRefresh() {
    // Sinkronkan payload QR yang disimpan backend; jangan membuat QR lokal baru
    // karena QR lokal tidak dikenal oleh server.
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted && _sessionActive) _loadActiveSession(silent: true);
    });
  }

  Future<void> _loadActiveSession({bool silent = false}) async {
    final id = _sessionId;
    if (id == null || id.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) throw Exception('Sesi login tidak ditemukan.');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/guru/absensi/session/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);
      if (response.statusCode != 200) {
        throw Exception('Sesi tidak dapat dimuat (HTTP ${response.statusCode}).');
      }
      final decoded = json.decode(response.body);
      final data = decoded is Map && decoded['data'] is Map
          ? Map<String, dynamic>.from(decoded['data'])
          : <String, dynamic>{};
      if (decoded['success'] != true || data.isEmpty) {
        throw Exception('Data sesi absensi tidak tersedia.');
      }
      if (!mounted) return;
      final nextActive = data['status'] == 'aktif';
      final nextId = (data['sesi_id'] ?? data['id'] ?? id).toString();
      final nextQr = data['qr_data']?.toString();
      final nextExpiry = DateTime.tryParse(data['expired_at']?.toString() ?? '');
      final nextTotal = (data['total_students'] as num?)?.toInt() ?? _totalStudents;
      final changed = _sessionActive != nextActive || _sessionId != nextId ||
          _qrData != nextQr || _expiredAt != nextExpiry || _totalStudents != nextTotal || _loading;
      if (changed) {
        setState(() {
          _sessionActive = nextActive;
          _sessionId = nextId;
          _qrData = nextQr;
          _expiredAt = nextExpiry;
          _totalStudents = nextTotal;
          _loading = false;
        });
      }
      if (_sessionActive) {
        _startAutoRefresh();
        _startAttendancePolling();
      } else {
        _refreshTimer?.cancel();
        _attendanceTimer?.cancel();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  void _startAttendancePolling() {
    // Hindari timer polling ganda ketika detail sesi dimuat ulang.
    _attendanceTimer?.cancel();
    _attendanceTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (mounted && _sessionActive) {
        await _fetchAttendanceData();
      }
    });
  }

  Future<void> _fetchAttendanceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/guru/absensi/session/$_sessionId/attendance'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && mounted) {
          final nextPresent = (data['data']['present_count'] as num?)?.toInt() ?? 0;
          final nextTotal = (data['data']['total_students'] as num?)?.toInt() ?? _totalStudents;
          final nextScans = List<Map<String, dynamic>>.from(data['data']['recent_scans'] ?? []).take(5).toList();
          if (nextPresent != _presentStudents || nextTotal != _totalStudents ||
              json.encode(nextScans) != json.encode(_recentScans)) {
            setState(() {
              _presentStudents = nextPresent;
              _totalStudents = nextTotal;
              _recentScans = nextScans;
            });
          }
        }
      }
    } catch (e) {
      // Silent fail for polling
      print('Polling error: $e');
    }
  }

  Future<void> _startAbsensi() async {
    if (_startingSession || !mounted) return;
    setState(() => _startingSession = true);

    try {
      final scheduleId = widget.jadwal['jadwal_id'] ?? widget.jadwal['id'];
      if (scheduleId == null || int.tryParse(scheduleId.toString()) == null) {
        throw Exception('Jadwal kelas tidak valid. Kembali ke daftar mapel dan pilih kelas lagi.');
      }
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) throw Exception('Sesi login tidak ditemukan.');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/guru/absensi/start-session'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'jadwal_id': int.parse(scheduleId.toString()),
          'mata_pelajaran': widget.jadwal['mata_pelajaran'] ?? 'Matematika',
          'kelas': widget.jadwal['kelas'] ?? '9A',
          'session_id': _sessionId,
          'qr_data': _qrData,
          'lokasi_latitude': _location['latitude'],
          'lokasi_longitude': _location['longitude'],
          'radius_meter': _radius,
          'toleransi_keterlambatan': _toleransi,
          'expired_at': _expiredAt?.toIso8601String(),
        }),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 409) {
        final conflictBody = json.decode(response.body);
        final conflictData = conflictBody is Map && conflictBody['data'] is Map
            ? Map<String, dynamic>.from(conflictBody['data'])
            : <String, dynamic>{};
        final activeId = conflictData['sesi_id']?.toString();
        if (activeId != null && activeId.isNotEmpty && mounted) {
          setState(() {
            _sessionActive = true;
            _sessionId = activeId;
          });
          await _loadActiveSession();
          return;
        }
        throw Exception(conflictBody is Map
            ? conflictBody['message']?.toString() ?? 'Sesi absensi sudah aktif.'
            : 'Sesi absensi sudah aktif.');
      }

      if (response.statusCode == 200) {
        String cleanBody = response.body.trim();
        int jsonStart = cleanBody.indexOf('{');
        if (jsonStart > 0) cleanBody = cleanBody.substring(jsonStart);
        
        final data = json.decode(cleanBody);
        if (data['success'] == true && mounted) {
          final sessionData = data['data'] is Map
              ? Map<String, dynamic>.from(data['data'])
              : <String, dynamic>{};
          setState(() {
            _sessionActive = true;
            _sessionId = sessionData['sesi_id']?.toString() ?? _sessionId;
            _qrData = sessionData['qr_data']?.toString() ?? _qrData;
            final expires = sessionData['expired_at']?.toString();
            _expiredAt = expires == null ? _expiredAt : DateTime.tryParse(expires);
          });
          _startAutoRefresh();
          _startAttendancePolling();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Sesi absensi berhasil dibuka'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _startingSession = false);
    }
  }

  Future<void> _closeSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutup Sesi Absensi?'),
        content: const Text('Siswa tidak akan bisa absen setelah sesi ditutup.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Tutup Sesi'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/guru/absensi/close-session/$_sessionId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ).timeout(ApiConfig.timeout);
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('Gagal menutup sesi (HTTP ${response.statusCode}).');
        }

        if (mounted) {
          Navigator.pop(context, {
            'session_id': _sessionId,
            'total_present': _presentStudents,
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.jadwal['mata_pelajaran']?.toString() ?? 'Absensi',
        subtitle: widget.jadwal['kelas']?.toString() ?? '',
        statusBadgeText: _sessionActive ? 'SESI AKTIF' : 'BELUM DIMULAI',
        statusBadgeType: _sessionActive ? BadgeType.success : BadgeType.neutral,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: AppDimens.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session Info Card
          _buildSessionInfoCard(),
          const SizedBox(height: AppDimens.spacingLarge),
          
          // QR Code
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Kode QR Interaktif', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _sessionActive ? AppColors.successLight : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _sessionActive ? 'Live Sync' : 'Belum Aktif',
                        style: TextStyle(color: _sessionActive ? AppColors.success : AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: QRCodeWidget(
                    data: _qrData ?? '',
                    size: 268,
                    showRefreshButton: _sessionActive,
                    onRefresh: _refreshQR,
                    instructionText: _sessionActive
                        ? 'Pindai QR Code ini untuk melakukan presensi.'
                        : 'QR akan aktif setelah sesi presensi dimulai.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spacingLarge),
          
          // Attendance Counter (only if active)
          if (_sessionActive) ...[
            _buildAttendanceCounter(),
            const SizedBox(height: AppDimens.spacingLarge),
            _buildRecentScans(),
            const SizedBox(height: AppDimens.spacingLarge),
          ],
          
          // Location Settings (only before start)
          if (!_sessionActive) ...[
            _buildLocationSection(),
            const SizedBox(height: AppDimens.spacingLarge),
            _buildToleransiSection(),
            const SizedBox(height: AppDimens.spacingXLarge),
          ],
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSessionInfoCard() {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    return Container(
      padding: AppDimens.paddingLarge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
              ),
              const SizedBox(width: AppDimens.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sesi Absensi',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '$dateStr • $timeStr WIB',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              if (_sessionId != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.spacingSmall,
                    vertical: AppDimens.spacingXSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  ),
                  child: Text(
                    '#$_sessionId',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (_expiredAt != null) ...[
            const SizedBox(height: AppDimens.spacingMedium),
            Container(
              padding: const EdgeInsets.all(AppDimens.spacingSmall),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, color: Colors.white70, size: 16),
                  const SizedBox(width: AppDimens.spacingXSmall),
                  Text(
                    'Expired: ${_expiredAt!.hour.toString().padLeft(2, '0')}:${_expiredAt!.minute.toString().padLeft(2, '0')} WIB',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceCounter() {
    final progress = _totalStudents > 0 ? _presentStudents / _totalStudents : 0.0;
    final percentage = (progress * 100).toInt();
    
    return Container(
      padding: AppDimens.paddingLarge,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kehadiran Real-time',
                style: AppTypography.labelLarge.copyWith(fontSize: 16),
              ),
              StatusBadge(
                text: '$_presentStudents/$_totalStudents',
                type: BadgeType.primary,
                size: BadgeSize.large,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          ProgressBarWithLabel(
            value: progress,
            label: 'Progress Absensi',
            subLabel: '$_presentStudents dari $_totalStudents siswa ($percentage%)',
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScans() {
    if (_recentScans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: AppDimens.paddingLarge,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: AppDimens.spacingSmall),
              Text(
                'Scan Terbaru',
                style: AppTypography.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          ..._recentScans.map((scan) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.spacingSmall),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: AppColors.success, size: 18),
                ),
                const SizedBox(width: AppDimens.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan['nama'] ?? 'Siswa',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        scan['waktu'] ?? 'Baru saja',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  text: 'Hadir',
                  type: BadgeType.success,
                  size: BadgeSize.small,
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: AppDimens.paddingLarge,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppDimens.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lokasi Absensi',
                      style: AppTypography.labelLarge,
                    ),
                    Text(
                      'MTsN Matsanam',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusBadge(text: 'Aktif', type: BadgeType.success),
            ],
          ),
          const SizedBox(height: AppDimens.spacingLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Radius', style: AppTypography.labelLarge),
              Text(
                '$_radius meter',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spacingSmall),
          Slider(
            value: _radius.toDouble(),
            min: 50,
            max: 500,
            divisions: 9,
            activeColor: AppColors.primary,
            label: '$_radius m',
            onChanged: (value) => setState(() => _radius = value.toInt()),
          ),
        ],
      ),
    );
  }

  Widget _buildToleransiSection() {
    return Container(
      padding: AppDimens.paddingLarge,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toleransi Keterlambatan',
                  style: AppTypography.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tambahan 15 menit untuk absen',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: _toleransi,
            onChanged: (value) => setState(() => _toleransi = value),
            activeColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_sessionActive) {
      return Column(
        children: [
          PrimaryButton(
            text: 'Tutup Sesi Absensi',
            icon: Icons.stop_rounded,
            variant: ButtonVariant.danger,
            onPressed: _closeSession,
          ),
          const SizedBox(height: AppDimens.spacingSmall),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali ke Dashboard'),
          ),
        ],
      );
    }

    return PrimaryButton(
      text: _startingSession ? 'Mengaktifkan Sesi...' : 'Mulai Sesi Absensi',
      icon: Icons.play_arrow_rounded,
      onPressed: _startingSession ? null : _startAbsensi,
      isLoading: _startingSession,
    );
  }
}
