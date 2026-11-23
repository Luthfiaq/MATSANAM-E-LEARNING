import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/siswa_learning_service.dart';
import '../../../utils/constants.dart';
import '../pengaturan/profil_siswa_screen.dart';

class SiswaNilaiMapelScreen extends StatefulWidget {
  final int mapelId;
  final String? namaMapel;
  final String? namaGuru;
  final double? rataRataAwal;

  const SiswaNilaiMapelScreen({
    super.key,
    required this.mapelId,
    this.namaMapel,
    this.namaGuru,
    this.rataRataAwal,
  });

  @override
  State<SiswaNilaiMapelScreen> createState() => _SiswaNilaiMapelScreenState();
}

class _SiswaNilaiMapelScreenState extends State<SiswaNilaiMapelScreen> {
  final _service = SiswaLearningService();
  Map<String, dynamic> _data = {};
  bool _loading = true;
  String? _error;
  String _tabKategori = 'semua';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final value = await _service.nilaiMapel(widget.mapelId);
      if (mounted) {
        setState(() {
          _data = value;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  String _predikatFromScore(double? score) {
    if (score == null) return '-';
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    return 'D';
  }

  String _labelPredikat(String predikat) {
    return switch (predikat) {
      'A' => 'Sangat Baik',
      'B' => 'Baik',
      'C' => 'Cukup',
      'D' => 'Perlu Bimbingan',
      _ => '-',
    };
  }

  List<Map<String, dynamic>> _filterHasil(List<Map<String, dynamic>> list) {
    if (_tabKategori == 'semua') return list;
    return list.where((item) {
      final jenis = (item['jenis'] ?? '').toString().toLowerCase();
      if (_tabKategori == 'ujian') {
        return jenis.contains('ujian') ||
            jenis.contains('quiz') ||
            jenis.contains('kuis') ||
            jenis.contains('uts') ||
            jenis.contains('uas');
      }
      return !(jenis.contains('ujian') ||
          jenis.contains('quiz') ||
          jenis.contains('kuis') ||
          jenis.contains('uts') ||
          jenis.contains('uas'));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mapel = _data['mapel'] is Map
        ? Map<String, dynamic>.from(_data['mapel'])
        : <String, dynamic>{};
    final semuaHasil = _data['hasil'] is List<dynamic>
      ? (_data['hasil'] as List<dynamic>)
        .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
      : <Map<String, dynamic>>[];

    final hasilTampil = _filterHasil(semuaHasil);
    final rataRata =
        (_data['rata_rata'] as num?)?.toDouble() ?? widget.rataRataAwal;
    final kkm = (_mapelKkm(mapel) ?? 75).toDouble();
    final lulusKkm = rataRata != null && rataRata >= kkm;
    final predikat =
        (_data['predikat'] ?? _predikatFromScore(rataRata)).toString();
    final namaMapel =
        (mapel['nama'] ?? widget.namaMapel ?? 'Detail Nilai').toString();
    final namaGuru =
        (mapel['guru'] ?? widget.namaGuru ?? 'Guru Mata Pelajaran').toString();
    final kelasLabel =
        (mapel['kelas'] ?? _data['kelas'] ?? 'Kelas Aktif').toString();
    final semesterLabel =
        (mapel['semester'] ?? _data['semester'] ?? 'Semester Berjalan')
            .toString();
    final catatanGuru =
        (_data['catatan_guru'] ?? mapel['catatan_guru'] ?? '').toString().trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
        ),
        title: const Text(
          'Detail Nilai Mapel & Rapor',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tidak ada notifikasi baru.')),
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF1E293B),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ProfilSiswaScreen()),
              ),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  kelasLabel.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '• $semesterLabel',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Σ',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1D4ED8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            namaMapel,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.school_outlined,
                                  size: 16,
                                  color: Color(0xFF2563EB),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Guru: $namaGuru',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'NILAI RAPOR BERJALAN',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white70,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            rataRata == null
                                                ? '-'
                                                : rataRata.toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            '/ 100',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            lulusKkm
                                                ? Icons.verified_rounded
                                                : Icons.info_outline_rounded,
                                            size: 15,
                                            color: const Color(0xFF6EE7B7),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '${lulusKkm ? "Tuntas" : "Pantau"} KKM (${kkm.toStringAsFixed(0)})',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFFA7F3D0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'PREDIKAT',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        predikat,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        _labelPredikat(predikat),
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _SegmentTab(
                              label: 'Semua (${semuaHasil.length})',
                              active: _tabKategori == 'semua',
                              onTap: () =>
                                  setState(() => _tabKategori = 'semua'),
                            ),
                          ),
                          Expanded(
                            child: _SegmentTab(
                              label: 'Tugas & PR',
                              active: _tabKategori == 'tugas',
                              onTap: () =>
                                  setState(() => _tabKategori = 'tugas'),
                            ),
                          ),
                          Expanded(
                            child: _SegmentTab(
                              label: 'Ujian & Quiz',
                              active: _tabKategori == 'ujian',
                              onTap: () =>
                                  setState(() => _tabKategori = 'ujian'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (hasilTampil.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'Belum ada data penilaian pada kategori ini.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ...hasilTampil.map((item) {
                        final score = (item['nilai'] as num?)?.toDouble();
                        final status = item['status_ketuntasan']?.toString() ??
                            'menunggu_penilaian';
                        final isTuntas = status == 'tuntas';
                        final bobot = item['bobot'];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.assignment_outlined,
                                      size: 20,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item['judul_tugas'] ?? '-'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_date(item['tanggal_penilaian'])}${bobot != null ? ' • Bobot $bobot%' : ''}',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        score == null
                                            ? '-'
                                            : score.toStringAsFixed(0),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: score == null
                                              ? AppColors.warning
                                              : const Color(0xFF1D4ED8),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      _Pill(
                                        label: score == null
                                            ? 'Menunggu'
                                            : isTuntas
                                                ? 'Tuntas'
                                                : 'Belum Tuntas',
                                        color: score == null
                                            ? AppColors.warning
                                            : isTuntas
                                                ? AppColors.success
                                                : AppColors.error,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if ((item['catatan'] ?? '')
                                  .toString()
                                  .trim()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Catatan: ${item['catatan']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Rata - Rata',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                rataRata == null
                                    ? '- / 100'
                                    : '${rataRata.toStringAsFixed(1)} / 100',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: rataRata == null
                                  ? 0
                                  : (rataRata / 100).clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor: const Color(0xFFE2E8F0),
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                          if (catatanGuru.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Catatan Guru Pengampu:',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '"$catatanGuru"',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF334155),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Unduh rincian nilai mapel PDF sedang disiapkan.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                        label: const Text(
                          'Unduh Rincian Nilai Mapel PDF',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  num? _mapelKkm(Map<String, dynamic> mapel) {
    final v = mapel['kkm'] ?? _data['kkm'];
    return v is num ? v : num.tryParse(v?.toString() ?? '');
  }

  String _date(dynamic value) {
    final d = DateTime.tryParse(value?.toString() ?? '');
    return d == null
        ? 'Belum dinilai'
        : DateFormat('dd MMM yyyy', 'id_ID').format(d.toLocal());
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: active ? const Color(0xFF2563EB) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 10.5,
          ),
        ),
      );
}