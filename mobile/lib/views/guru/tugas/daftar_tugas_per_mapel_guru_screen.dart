import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'edit_tugas_guru_screen.dart';
import 'tambah_tugas_guru_screen.dart';

class DaftarTugasPerMapelGuruScreen extends StatefulWidget {
  final String mapel;
  final String kelas;
  const DaftarTugasPerMapelGuruScreen({
    super.key,
    this.mapel = 'Matematika',
    this.kelas = 'Kelas 9A & 9B',
  });

  @override
  State<DaftarTugasPerMapelGuruScreen> createState() => _DaftarTugasPerMapelGuruScreenState();
}

class _DaftarTugasPerMapelGuruScreenState extends State<DaftarTugasPerMapelGuruScreen> {
  final _cari = TextEditingController();
  String _filter = 'Semua';
  String _query = '';

  // Data contoh sesuai Figma. Ganti dengan data API nanti.
  final List<Map<String, dynamic>> _tugas = [
    {
      'no': 1,
      'title': 'Latihan SPLDV: Eliminasi & Substitusi',
      'deadline': 'Deadline: 25 Sep 2026 \u2022 23:59 WIB',
      'info': '1 Berkas Soal (PDF) \u2022 Bobot 20%',
      'status': 'Aktif',
      'kumpul': 28,
      'total': 64,
      'icon': Icons.square_foot_rounded,
    },
    {
      'no': 2,
      'title': 'PR Bab 4: Sudut Istimewa Trigonometri',
      'deadline': 'Deadline: 28 Sep 2026 \u2022 23:59 WIB',
      'info': '1 Lembar Tugas (PDF, DOCX) \u2022 Bobot 15%',
      'status': 'Aktif',
      'kumpul': 56,
      'total': 64,
      'icon': Icons.calculate_outlined,
    },
    {
      'no': 3,
      'title': 'Proyek Statistika & Penyajian Data Kelompok',
      'deadline': 'Deadline: 02 Okt 2026 \u2022 15:00 WIB',
      'info': '2 Berkas Panduan (PDF, XLSX) \u2022 Bobot 25%',
      'status': 'Aktif',
      'kumpul': 40,
      'total': 64,
      'icon': Icons.query_stats_rounded,
    },
    {
      'no': 4,
      'title': 'Kuis Teorema Pythagoras & Geometri Ruang',
      'deadline': 'Terakhir diperbarui kemarin \u2022 14:20 WIB',
      'info': '1 Berkas Draft Soal',
      'status': 'Draf',
      'kumpul': 0,
      'total': 64,
      'icon': Icons.functions_rounded,
    },
  ];

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  int _hitung(String f) => f == 'Semua'
      ? _tugas.length
      : _tugas.where((t) => t['status'] == f).length;

  List<Map<String, dynamic>> get _tampil => _tugas.where((t) {
        final cocokFilter = _filter == 'Semua' || t['status'] == _filter;
        final cocokCari = (t['title'] as String)
            .toLowerCase()
            .contains(_query.toLowerCase());
        return cocokFilter && cocokCari;
      }).toList();

  void _pesan(String t) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1F2937),
      ),
    );
  }

  Future<void> _tambah() async {
    final hasil = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahTugasGuruScreen(
            mapel: widget.mapel, kelas: widget.kelas.replaceFirst('Kelas ', 'Kelas ')),
      ),
    );
    if (hasil == null || !mounted) return;
    setState(() {
      _tugas.add({
        'no': _tugas.length + 1,
        'title': hasil['title'] ?? '',
        'deadline': 'Deadline: ${hasil['deadline'] ?? '-'}',
        'info': 'Tanpa berkas \u2022 Bobot 20%',
        'status': hasil['status'] ?? 'Aktif',
        'kumpul': 0,
        'total': 64,
        'icon': Icons.assignment_outlined,
      });
    });
    _pesan('Tugas berhasil ditambahkan');
  }

  Future<void> _edit(int index) async {
    final t = _tugas[index];
    final hasil = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditTugasGuruScreen(
          task: {
            'title': t['title'] as String,
            'description': '',
            'deadline': (t['deadline'] as String)
                .replaceFirst('Deadline: ', ''),
            'date': '',
          },
          mapel: widget.mapel,
        ),
      ),
    );
    if (hasil == null || !mounted) return;
    setState(() {
      t['title'] = hasil['title'] ?? t['title'];
      if ((hasil['deadline'] ?? '').isNotEmpty) {
        t['deadline'] = 'Deadline: ${hasil['deadline']}';
      }
    });
    _pesan('Tugas berhasil diperbarui');
  }

  Future<void> _hapus(int index) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: Text('Tugas "${_tugas[index]['title']}" akan dihapus.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Hapus',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ya != true || !mounted) return;
    setState(() => _tugas.removeAt(index));
    _pesan('Tugas berhasil dihapus');
  }

  @override
  Widget build(BuildContext context) {
    final daftar = _tampil;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Detail Tugas',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.notifications_none_rounded,
                    color: AppColors.textPrimary),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: Color(0xFFEF4444), shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_outline_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _tambah,
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: const Text('+ Tambah Tugas Baru'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        textStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _pencarian(),
                  const SizedBox(height: 12),
                  _filterChips(),
                  const SizedBox(height: 14),
                  if (daftar.isEmpty)
                    _kosong()
                  else
                    ...daftar.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _kartuTugas(t),
                        )),
                  const SizedBox(height: 4),
                  _tips(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Komponen ----------

  Widget _header() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0349C9), Color(0xFF2F6FEA)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _pil('Semester Ganjil 2026/2027', const Color(0x33FFFFFF),
                    Colors.white),
                _pil('Kurikulum Merdeka', const Color(0xFF86EFC5),
                    const Color(0xFF065F46)),
              ],
            ),
            const SizedBox(height: 10),
            Text(widget.mapel,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.groups_rounded,
                    color: Color(0xFFDCE6FF), size: 16),
                const SizedBox(width: 6),
                Text('${widget.kelas} \u2022 Total 64 Siswa',
                    style: const TextStyle(
                        color: Color(0xFFDCE6FF), fontSize: 12.5)),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x26FFFFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.fact_check_outlined,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PROGRES KOREKSI',
                            style: TextStyle(
                                color: Color(0xFFDCE6FF),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                        SizedBox(height: 2),
                        Text('3 dari 4 Tugas Dinilai',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const Text('75%',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _pil(String t, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(t,
            style: TextStyle(
                color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
      );

  Widget _pencarian() => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEDEFF3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search,
                color: AppColors.textSecondary, size: 21),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _cari,
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Cari tugas, topik, atau kata kunci...',
                  hintStyle: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _filterChips() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['Semua', 'Aktif', 'Selesai', 'Draf'].map((f) {
            final aktif = _filter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('$f (${_hitung(f)})',
                    style: TextStyle(
                        color: aktif ? Colors.white : AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                selected: aktif,
                showCheckmark: false,
                onSelected: (_) => setState(() => _filter = f),
                backgroundColor: Colors.white,
                selectedColor: AppColors.primaryDark,
                side: BorderSide(
                    color: aktif
                        ? AppColors.primaryDark
                        : const Color(0xFFEDEFF3)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            );
          }).toList(),
        ),
      );

  Widget _kartuTugas(Map<String, dynamic> t) {
    final index = _tugas.indexOf(t);
    final draf = t['status'] == 'Draf';
    final kumpul = t['kumpul'] as int;
    final total = t['total'] as int;
    final persen = total == 0 ? 0 : (kumpul * 100 / total).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(t['icon'] as IconData,
                    color: AppColors.primaryDark, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _tag('Tugas ${t['no']}'),
                        const SizedBox(width: 6),
                        _tag('Kelas 9A, 9B'),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: draf
                                ? AppColors.warningLight
                                : AppColors.successLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(t['status'] as String,
                              style: TextStyle(
                                  color: draf
                                      ? AppColors.warning
                                      : AppColors.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(t['title'] as String,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            height: 1.25)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.schedule,
                  size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(t['deadline'] as String,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.attach_file,
                  size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(t['info'] as String,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (draf)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: AppColors.warning),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tugas belum dipublikasikan ke siswa kelas 9A & 9B.',
                      style: TextStyle(
                          color: Color(0xFF92400E), fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F2FC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Pengumpulan Siswa',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600)),
                      ),
                      Text('$kumpul / $total Siswa ($persen%)',
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : kumpul / total,
                      minHeight: 7,
                      backgroundColor: const Color(0xFFDDE3F5),
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: _tombolSekunder(
                  draf ? Icons.edit_note : Icons.edit_outlined,
                  draf ? 'Lanjutkan Edit' : 'Edit',
                  () => _edit(index),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => _pesan(draf
                        ? 'Tugas dipublikasikan (demo)'
                        : 'Halaman Periksa Siswa belum tersedia'),
                    icon: Icon(
                        draf ? Icons.send_outlined : Icons.visibility_outlined,
                        size: 17),
                    label: Text(draf ? 'Publikasikan' : 'Periksa Siswa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      textStyle: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _hapus(index),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE9EA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F2FC),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(t,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w700)),
      );

  Widget _tombolSekunder(IconData ikon, String teks, VoidCallback onTap) =>
      SizedBox(
        height: 40,
        child: TextButton.icon(
          onPressed: onTap,
          icon: Icon(ikon, size: 17),
          label: Text(teks),
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFEEF0FB),
            foregroundColor: AppColors.textPrimary,
            textStyle:
                const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );

  Widget _kosong() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF3)),
        ),
        child: const Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: 38, color: AppColors.textSecondary),
            SizedBox(height: 10),
            Text('Tugas tidak ditemukan',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _tips() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF0FB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lightbulb_outline,
                  color: AppColors.warning, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tips Guru',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 3),
                  Text(
                    'Berikan instruksi pengerjaan yang jelas dan unggah lembar soal dalam format PDF agar mudah dibuka di gawai siswa.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}