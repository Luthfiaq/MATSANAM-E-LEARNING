import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/api_config.dart';
import '../../../utils/constants.dart';
import '../../../utils/theme_helpers.dart';
import '../../../widgets/common/notification_bell_button.dart';
import '../notifikasi/guru_notifikasi_screen.dart';

class DaftarMateriScreen extends StatefulWidget {
  final String? mapelFilter;
  final String? kelasFilter;
  final int? jadwalIdFilter;
  final Map<String, dynamic> scheduleContext;

  const DaftarMateriScreen({
    super.key,
    this.mapelFilter,
    this.kelasFilter,
    this.jadwalIdFilter,
    this.scheduleContext = const <String, dynamic>{},
  });

  @override
  State<DaftarMateriScreen> createState() => _DaftarMateriScreenState();
}

class _DaftarMateriScreenState extends State<DaftarMateriScreen> {
  List<Map<String, dynamic>> _materiList = [];
  bool _isLoading = true;
  String? _loadError;
  bool _didChange = false;
  String _selectedFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String _materiMapel(Map<String, dynamic> materi) {
    final jadwal = materi['jadwal'];
    if (jadwal is Map && jadwal['mata_pelajaran'] is Map) {
      return (jadwal['mata_pelajaran']['nama'] ?? '').toString();
    }
    return (materi['mapel'] ?? materi['mata_pelajaran'] ?? '').toString();
  }

  String _materiKelas(Map<String, dynamic> materi) {
    final jadwal = materi['jadwal'];
    if (jadwal is Map && jadwal['kelas'] is Map) {
      return (jadwal['kelas']['nama_kelas'] ?? '').toString();
    }
    return (materi['kelas'] ?? '').toString();
  }

  String _normalizeClass(String value) {
    final cleaned = value.trim().toUpperCase().replaceAll('KELAS ', '');
    final match = RegExp(r'^(VII|VIII|IX)\s*([A-Z])$').firstMatch(cleaned);
    if (match == null) return cleaned.replaceAll(' ', '');
    const levels = {'VII': '7', 'VIII': '8', 'IX': '9'};
    return '${levels[match.group(1)!] ?? ''}${match.group(2)}';
  }

  String _scheduleValue(String key, [String fallback = '']) {
    final value = widget.scheduleContext[key];
    if (value == null) return fallback;
    return value.toString().trim().isEmpty ? fallback : value.toString().trim();
  }

  String _formatPublishedAt(dynamic rawValue) {
    if (rawValue == null) return 'Tanggal publikasi tidak tersedia';
    final parsed = DateTime.tryParse(rawValue.toString());
    if (parsed == null) return 'Tanggal publikasi tidak tersedia';
    return DateFormat('dd MMM yyyy • HH:mm', 'id_ID').format(parsed.toLocal());
  }

  String _resourceLabel(Map<String, dynamic> materi) {
    final type = (materi['tipe'] ?? 'pdf').toString().toLowerCase();
    if (type == 'link') return 'Tautan materi';
    return type == 'video' ? 'File video' : 'File PDF';
  }

  List<Map<String, dynamic>> get _filteredMateri {
    return _materiList.where((materi) {
      final type = (materi['tipe'] ?? 'pdf').toString().toUpperCase();
      final mapel = _materiMapel(materi);
      final kelas = _materiKelas(materi);
      final matchesType =
          _selectedFilter == 'Semua' || type == _selectedFilter.toUpperCase();
      final matchesMapel =
          widget.mapelFilter == null || mapel == widget.mapelFilter;
      final matchesKelas =
          widget.kelasFilter == null ||
          _normalizeClass(kelas) == _normalizeClass(widget.kelasFilter!);
      final scheduleId =
          materi['jadwal_id'] ??
          (materi['jadwal'] is Map ? materi['jadwal']['id'] : null);
      final matchesSchedule =
          widget.jadwalIdFilter == null ||
          scheduleId?.toString() == widget.jadwalIdFilter.toString();
      final searchText =
          '${materi['judul'] ?? ''} ${materi['deskripsi'] ?? ''} $mapel $kelas'
              .toLowerCase();
      return matchesType &&
          matchesMapel &&
          matchesKelas &&
          matchesSchedule &&
          searchText.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() => _searchQuery = _searchController.text.trim());
    });
    _loadMateri();
  }

  Future<void> _loadMateri() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/guru/materi'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        dynamic errorPayload;
        try {
          errorPayload = json.decode(response.body);
        } catch (_) {
          errorPayload = null;
        }
        final message = errorPayload is Map
            ? errorPayload['message']?.toString()
            : null;
        throw Exception(
          message ?? 'Gagal memuat materi (HTTP ${response.statusCode}).',
        );
      }
      final data = json.decode(response.body);
      if (data is! Map || data['success'] != true) {
        throw Exception(
          data is Map
              ? data['message']?.toString() ?? 'Respons API tidak valid.'
              : 'Respons API tidak valid.',
        );
      }
      final rows = (data['data'] as List? ?? [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      if (!mounted) return;
      setState(() {
        _materiList = rows;
        _loadError = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = error.toString().replaceFirst('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Coba Lagi',
            textColor: Colors.white,
            onPressed: _loadMateri,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.matsanamPage,
      appBar: AppBar(
        backgroundColor: context.matsanamPage,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, _didChange),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Detail Mapel',
          style: TextStyle(
            color: context.matsanamText,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          NotificationBellButton(
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const GuruNotifikasiScreen(),
                ),
              );
            },
            tooltip: 'Notifikasi Guru',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pushNamed(context, '/pengaturan'),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: SizedBox(width: double.infinity, child: _buildContent()),
              ),
            ),
    );
  }

  Widget _buildContent() {
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 52,
                color: context.matsanamTextSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                'Materi gagal dimuat',
                style: TextStyle(
                  color: context.matsanamText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.matsanamTextSecondary),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _loadMateri,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final rows = _filteredMateri;
    return RefreshIndicator(
      onRefresh: _loadMateri,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _subjectBanner(),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: FilledButton.icon(
              onPressed: _openTambahMateri,
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Tambah Materi Baru'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildFilterBar(),
          const SizedBox(height: 14),
          if (rows.isEmpty)
            _emptyMaterials()
          else
            ...rows.map(_buildMateriCard),
        ],
      ),
    );
  }

  Widget _subjectBanner() {
    final subject = widget.mapelFilter ?? 'Mata Pelajaran';
    final className = widget.kelasFilter ?? _scheduleValue('kelas', 'Kelas terpilih');
    final studentCount = widget.scheduleContext['jumlah_siswa'];
    final year = _scheduleValue('tahun_ajaran');
    final classText = className.startsWith('Kelas') ? className : 'Kelas $className';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF174FCB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .18),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _bannerPill(
                  icon: Icons.groups_2_outlined,
                  label: classText,
                ),
              ),
              const SizedBox(width: 8),
              if (year.isNotEmpty)
                _bannerPill(
                  icon: Icons.calendar_month_outlined,
                  label: year,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            subject,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              height: 1.12,
              fontWeight: FontWeight.w800,
              letterSpacing: -.35,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              const Icon(Icons.people_alt_outlined, color: Colors.white70, size: 15),
              const SizedBox(width: 6),
              Text(
                studentCount is num
                    ? '$classText • Total ${studentCount.toInt()} siswa'
                    : classText,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bannerPill({required IconData icon, required String label}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .16),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white.withValues(alpha: .14)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 12),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildFilterBar() {
    return Column(
      children: [
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: context.matsanamSoftSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: context.matsanamTextSecondary, size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: context.matsanamText, fontSize: 13),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Cari bab, topik, atau kata kunci materi...',
                    hintStyle: TextStyle(
                      color: context.matsanamTextSecondary,
                      fontSize: 12,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                IconButton(
                  onPressed: _searchController.clear,
                  icon: Icon(Icons.close_rounded, size: 17, color: context.matsanamTextSecondary),
                  tooltip: 'Hapus pencarian',
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Semua', 'PDF', 'Video', 'Link'].map((filter) {
              final selected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 7),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                  selectedColor: AppColors.primary,
                  backgroundColor: context.matsanamSurface,
                  side: BorderSide(
                    color: selected ? AppColors.primary : context.matsanamBorder,
                  ),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : context.matsanamText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _emptyMaterials() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: context.matsanamSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.matsanamBorder),
    ),
    child: Column(
      children: [
        Icon(Icons.menu_book_outlined, size: 38, color: context.matsanamTextSecondary),
        const SizedBox(height: 10),
        Text(
          _materiList.isEmpty ? 'Belum ada materi' : 'Materi tidak ditemukan',
          style: TextStyle(
            color: context.matsanamText,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _materiList.isEmpty
              ? 'Tambahkan materi pertama untuk jadwal ini.'
              : 'Ubah kata kunci pencarian atau filter jenis materi.',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.matsanamTextSecondary, fontSize: 12),
        ),
      ],
    ),
  );

  Future<void> _openTambahMateri() async {
    final result = await Navigator.pushNamed(
      context,
      '/guru/tambah-materi',
      arguments: {
        if (widget.jadwalIdFilter != null) 'jadwal_id': widget.jadwalIdFilter,
        if (widget.mapelFilter != null) 'mapel': widget.mapelFilter,
        if (widget.kelasFilter != null) 'kelas': widget.kelasFilter,
        if (_scheduleValue('tahun_ajaran').isNotEmpty)
          'tahun_ajaran': _scheduleValue('tahun_ajaran'),
      },
    );
    if (result == true && mounted) {
      _didChange = true;
      await _loadMateri();
    }
  }

  Future<void> _openMateriResource(Map<String, dynamic> materi) async {
    final type = materi['tipe']?.toString() ?? 'pdf';
    if (type == 'link') {
      final rawLink = materi['link']?.toString() ?? '';
      final uri = Uri.tryParse(rawLink);
      if (uri == null ||
          !uri.hasScheme ||
          !['http', 'https'].contains(uri.scheme)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tautan materi tidak valid.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      try {
        final opened = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!opened && mounted) {
          throw Exception('Tautan tidak dapat dibuka pada perangkat ini.');
        }
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final id = int.tryParse(materi['id']?.toString() ?? '');
    final storedPath = materi['file_path']?.toString() ?? '';
    if (id == null || storedPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File materi tidak tersedia.')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }
      final response = await http
          .get(
            Uri.parse('${ApiConfig.guruMateri}/$id/file'),
            headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'},
          )
          .timeout(ApiConfig.timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        var message =
            'File materi gagal diunduh (HTTP ${response.statusCode}).';
        try {
          final payload = jsonDecode(utf8.decode(response.bodyBytes));
          if (payload is Map && payload['message'] != null) {
            message = payload['message'].toString();
          }
        } catch (_) {
          // Keep the HTTP fallback when the server returns a non-JSON error page.
        }
        throw Exception(message);
      }

      await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan materi',
        fileName: storedPath.split('/').last,
        bytes: response.bodyBytes,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteMateri(Map<String, dynamic> materi) async {
    final id = int.tryParse(materi['id']?.toString() ?? '');
    if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Hapus materi?'),
        content: Text(
          'Materi "${materi['judul'] ?? 'Tanpa judul'}" akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.guruMateri}/$id'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.timeout);
      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded is! Map ||
          decoded['success'] != true) {
        var message = 'Materi gagal dihapus (HTTP ${response.statusCode}).';
        if (decoded is Map) {
          final errors = decoded['errors'];
          if (errors is Map &&
              errors.isNotEmpty &&
              errors.values.first is List &&
              (errors.values.first as List).isNotEmpty) {
            message = (errors.values.first as List).first.toString();
          } else {
            message = decoded['message']?.toString() ?? message;
          }
        }
        throw Exception(message);
      }
      if (!mounted) return;
      setState(() {
        _didChange = true;
        _materiList.removeWhere(
          (item) => item['id'].toString() == id.toString(),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            decoded['message']?.toString() ?? 'Materi berhasil dihapus.',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _editMateri(Map<String, dynamic> materi) async {
    final jadwal = materi['jadwal'] is Map
        ? Map<String, dynamic>.from(materi['jadwal'])
        : <String, dynamic>{};
    final mapel = jadwal['mata_pelajaran'] is Map
        ? Map<String, dynamic>.from(jadwal['mata_pelajaran'])
        : <String, dynamic>{};
    final kelas = jadwal['kelas'] is Map
        ? Map<String, dynamic>.from(jadwal['kelas'])
        : <String, dynamic>{};

    final result = await Navigator.pushNamed(
      context,
      '/guru/materi/${materi['id']}/edit',
      arguments: {
        ...materi,
        'mata_pelajaran': mapel['nama'] ?? materi['mata_pelajaran'],
        'kelas': kelas['nama_kelas'] ?? materi['kelas'],
        'tipe': materi['tipe'] ?? 'pdf',
        'jadwal_id': materi['jadwal_id'] ?? jadwal['id'],
        if (_scheduleValue('tahun_ajaran').isNotEmpty)
          'tahun_ajaran': _scheduleValue('tahun_ajaran'),
      },
    );
    if (result == true && mounted) {
      _didChange = true;
      await _loadMateri();
    }
  }

  Widget _buildMateriCard(Map<String, dynamic> materi) {
    final type = (materi['tipe'] ?? 'pdf').toString().toLowerCase();
    final typeIcon = type == 'video'
        ? Icons.play_circle_outline_rounded
        : (type == 'link' ? Icons.link_rounded : Icons.picture_as_pdf_outlined);
    final description = (materi['deskripsi'] ?? '').toString().trim();
    final statusLabel = (materi['status'] ?? materi['status_publikasi'] ?? '')
        .toString()
        .trim();
    final hasResource = type == 'link'
        ? (materi['link']?.toString().isNotEmpty ?? false)
        : (materi['file_path']?.toString().isNotEmpty ?? false);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.matsanamSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.matsanamBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.matsanamSoftPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(typeIcon, color: AppColors.primary, size: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        _metaBadge(type.toUpperCase(), context.matsanamSoftPrimary, AppColors.primary),
                        _metaBadge(_materiKelas(materi), context.matsanamSoftSurface, context.matsanamTextSecondary),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      (materi['judul'] ?? 'Judul Materi').toString(),
                      style: TextStyle(
                        color: context.matsanamText,
                        fontSize: 15,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (statusLabel.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: context.matsanamSoftSuccess,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: context.matsanamSuccess,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.matsanamTextSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 11),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: context.matsanamSoftSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, color: context.matsanamTextSecondary, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Ditambahkan ${_formatPublishedAt(materi['created_at'])}',
                        style: TextStyle(color: context.matsanamTextSecondary, fontSize: 10.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: hasResource ? () => _openMateriResource(materi) : null,
                  borderRadius: BorderRadius.circular(7),
                  child: Row(
                    children: [
                      Icon(
                        type == 'link' ? Icons.link_rounded : Icons.attach_file_rounded,
                        color: context.matsanamTextSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _resourceLabel(materi),
                          style: TextStyle(
                            color: hasResource ? context.matsanamText : context.matsanamTextSecondary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (hasResource)
                        Icon(
                          type == 'link' ? Icons.open_in_new_rounded : Icons.download_rounded,
                          color: AppColors.primary,
                          size: 14,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _editMateri(materi),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.matsanamSoftPrimary,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: context.matsanamSoftError,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: IconButton(
                  tooltip: 'Hapus materi',
                  onPressed: () => _deleteMateri(materi),
                  icon: Icon(Icons.delete_outline_rounded, color: context.matsanamError, size: 19),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaBadge(String label, Color background, Color foreground) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: foreground,
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

}
