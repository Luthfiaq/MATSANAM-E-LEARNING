import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/api_config.dart';
import '../../../utils/constants.dart';

class DaftarMateriScreen extends StatefulWidget {
  final String? mapelFilter;
  final String? kelasFilter;
  final int? jadwalIdFilter;

  const DaftarMateriScreen({super.key, this.mapelFilter, this.kelasFilter, this.jadwalIdFilter});

  @override
  State<DaftarMateriScreen> createState() => _DaftarMateriScreenState();
}

class _DaftarMateriScreenState extends State<DaftarMateriScreen> {
  List<Map<String, dynamic>> _materiList = [];
  bool _isLoading = true;
  bool _didChange = false;
  int _currentPage = 1;
  int _totalPages = 1;
  String _selectedFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String _safeSubstring(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength);
  }

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

  List<Map<String, dynamic>> get _filteredMateri {
    return _materiList.where((materi) {
      final type = (materi['tipe'] ?? 'pdf').toString().toUpperCase();
      final mapel = _materiMapel(materi);
      final kelas = _materiKelas(materi);
      final matchesType = _selectedFilter == 'Semua' || type == _selectedFilter.toUpperCase();
      final matchesMapel = widget.mapelFilter == null || mapel == widget.mapelFilter;
      final matchesKelas = widget.kelasFilter == null ||
          _normalizeClass(kelas) == _normalizeClass(widget.kelasFilter!);
      final scheduleId = materi['jadwal_id'] ??
          (materi['jadwal'] is Map ? materi['jadwal']['id'] : null);
      final matchesSchedule = widget.jadwalIdFilter == null ||
          scheduleId?.toString() == widget.jadwalIdFilter.toString();
      final searchText = '${materi['judul'] ?? ''} ${materi['deskripsi'] ?? ''} $mapel $kelas'.toLowerCase();
      return matchesType && matchesMapel && matchesKelas && matchesSchedule &&
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

  Future<void> _loadMateri({int? page}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/guru/materi'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode != 200) {
        throw Exception('Gagal memuat materi (HTTP ${response.statusCode}).');
      }
      final data = json.decode(response.body);
      if (data is! Map || data['success'] != true) {
        throw Exception(data is Map
            ? data['message']?.toString() ?? 'Respons API tidak valid.'
            : 'Respons API tidak valid.');
      }
      final rows = (data['data'] as List? ?? [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      if (!mounted) return;
      setState(() {
        _materiList = rows;
        _currentPage = 1;
        _totalPages = 1;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, _didChange),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          widget.mapelFilter == null ? 'Daftar Materi' : widget.mapelFilter!,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openTambahMateri,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: SizedBox(width: double.infinity, child: _buildContent()),
              ),
            ),
    );
  }

  Widget _buildContent() {
    if (_materiList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 14),
            const Text('Belum ada materi',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _openTambahMateri,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Materi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: _filteredMateri.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada materi yang cocok dengan pencarian atau filter ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredMateri.length,
                  itemBuilder: (context, index) =>
                      _buildMateriCard(_filteredMateri[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Cari judul atau deskripsi materi...',
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Semua', 'PDF', 'Video', 'Link'].map((filter) {
                final selected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTambahMateri() async {
    final result = await Navigator.pushNamed(
      context,
      '/guru/tambah-materi',
      arguments: {
        if (widget.jadwalIdFilter != null) 'jadwal_id': widget.jadwalIdFilter,
        if (widget.mapelFilter != null) 'mapel': widget.mapelFilter,
        if (widget.kelasFilter != null) 'kelas': widget.kelasFilter,
      },
    );
    if (result == true && mounted) {
      _didChange = true;
      await _loadMateri();
    }
  }

  Future<void> _deleteMateri(Map<String, dynamic> materi) async {
    final id = int.tryParse(materi['id']?.toString() ?? '');
    if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus materi?'),
        content: Text('Materi "${materi['judul'] ?? 'Tanpa judul'}" akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
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
      final response = await http.delete(
        Uri.parse('${ApiConfig.guruMateri}/$id'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      ).timeout(ApiConfig.timeout);
      final decoded = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300 ||
          decoded is! Map || decoded['success'] != true) {
        throw Exception(decoded is Map ? decoded['message']?.toString() ?? 'Materi gagal dihapus.' : 'Materi gagal dihapus.');
      }
      if (!mounted) return;
      setState(() {
        _didChange = true;
        _materiList.removeWhere((item) => item['id'].toString() == id.toString());
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(decoded['message']?.toString() ?? 'Materi berhasil dihapus.'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', '')), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
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
      },
    );
    if (result == true && mounted) {
      _didChange = true;
      await _loadMateri();
    }
  }

  Widget _buildMateriCard(Map<String, dynamic> materi) {
    final type = materi['tipe'] ?? 'pdf';
    final typeIcon = type == 'video'
        ? Icons.play_circle_outline
        : (type == 'link' ? Icons.language : Icons.picture_as_pdf);
    final typeColor = type == 'video'
        ? AppColors.accentOrange
        : (type == 'link' ? AppColors.primary : AppColors.primary);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(typeIcon, color: typeColor, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            materi['judul'] ?? 'Judul Materi',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_materiMapel(materi)} • ${_materiKelas(materi)}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.download_rounded,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${materi['downloads'] ?? 0}',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _safeSubstring((materi['deskripsi'] ?? 'Materi pembelajaran untuk topik...').toString(), 80),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              (materi['created_at']?.toString() ?? '-').split('T').first,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Aksi unduh langsung akan diaktifkan setelah URL penyimpanan file dikonfigurasi.',
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Unduh'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editMateri(materi),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.error.withOpacity(0.35)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        tooltip: 'Hapus materi',
                        onPressed: () => _deleteMateri(materi),
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Halaman $_currentPage dari $_totalPages',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 1
                    ? () => _loadMateri(page: _currentPage - 1)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                onPressed: _currentPage < _totalPages
                    ? () => _loadMateri(page: _currentPage + 1)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
