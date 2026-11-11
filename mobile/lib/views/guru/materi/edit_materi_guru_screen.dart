import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class EditMateriGuruScreen extends StatefulWidget {
  final Map<String, String> material;
  final String mapel;
  final String kelas;

  const EditMateriGuruScreen({
    super.key,
    required this.material,
    this.mapel = 'Matematika',
    this.kelas = 'Kelas 9 Semester Ganjil',
  });

  @override
  State<EditMateriGuruScreen> createState() => _EditMateriGuruScreenState();
}

class _EditMateriGuruScreenState extends State<EditMateriGuruScreen> {
  late final TextEditingController _judul;
  late final TextEditingController _deskripsi;

  final Map<String, int> _kelas = {'9A': 32, '9B': 30, '9C': 31};
  final Set<String> _kelasDipilih = {'9A', '9B', '9C'};
  final List<PlatformFile> _berkas = [];
  bool _publikasi = true;

  @override
  void initState() {
    super.initState();
    _judul = TextEditingController(text: widget.material['title'] ?? '');
    _deskripsi =
        TextEditingController(text: widget.material['description'] ?? '');
  }

  @override
  void dispose() {
    _judul.dispose();
    _deskripsi.dispose();
    super.dispose();
  }

  Future<void> _pilihBerkas() async {
    final hasil = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (hasil == null) return;
    setState(() => _berkas.addAll(hasil.files));
  }

  String _ukuran(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }

  String _jenisMateri() {
    final lama = widget.material['type'] ?? 'PDF';
    if (_berkas.isEmpty) return lama;
    final ext = (_berkas.first.extension ?? '').toLowerCase();
    if (ext == 'pdf') return 'PDF';
    if (['mp4', 'mov', 'mkv', 'avi'].contains(ext)) return 'Video';
    return 'Dokumen';
  }

  void _pesan(String teks) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(teks),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1F2937),
      ),
    );
  }

  void _simpan() {
    if (_judul.text.trim().isEmpty) {
      _pesan('Judul materi wajib diisi');
      return;
    }
    if (_deskripsi.text.trim().isEmpty) {
      _pesan('Deskripsi pembelajaran wajib diisi');
      return;
    }
    if (_kelasDipilih.isEmpty) {
      _pesan('Pilih minimal satu kelas');
      return;
    }
    // TODO: sambungkan ke API di sini nanti.
    Navigator.pop(context, <String, String>{
      'title': _judul.text.trim(),
      'description': _deskripsi.text.trim(),
      'type': _jenisMateri(),
      'date': widget.material['date'] ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => Navigator.maybePop(context),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back,
                  color: AppColors.textPrimary, size: 22),
            ),
          ),
        ),
        leadingWidth: 56,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MATSANAM GURU',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              'Detail Materi',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.help_outline,
                color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'MG',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                children: [
                  _kartuBreadcrumb(),
                  const SizedBox(height: 14),
                  _kartuJudul(),
                  const SizedBox(height: 14),
                  _kartuDeskripsi(),
                  const SizedBox(height: 14),
                  _kartuBerkas(),
                  const SizedBox(height: 14),
                  _kartuTargetKelas(),
                  const SizedBox(height: 14),
                  _kartuPublikasi(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => Navigator.maybePop(context),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Batal',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _simpan,
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Simpan Perubahan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Komponen ----------

  Widget _kartu({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: child,
    );
  }

  Widget _label(String teks, {String? hitung, bool wajib = true}) {
    return Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              text: teks,
              children: [
                if (wajib)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.error),
                  ),
              ],
            ),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (hitung != null)
          Text(hitung,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _kartuBreadcrumb() {
    return _kartu(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Materi',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const Icon(Icons.chevron_right,
                        size: 16, color: AppColors.textSecondary),
                    Expanded(
                      child: Text(
                        widget.material['title'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${widget.mapel} \u2022 ${widget.kelas}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 7, color: AppColors.success),
                SizedBox(width: 5),
                Text('Terbit',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuJudul() {
    return _kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Judul Materi', hitung: '${_judul.text.length}/60'),
          const SizedBox(height: 12),
          TextField(
            controller: _judul,
            maxLength: 60,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              counterText: '',
              prefixIcon: const Icon(Icons.edit_note_rounded,
                  color: AppColors.textSecondary, size: 22),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuDeskripsi() {
    return _kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Deskripsi Pembelajaran'),
          const SizedBox(height: 12),
          TextField(
            controller: _deskripsi,
            maxLines: 5,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14, height: 1.5),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline,
                  size: 15, color: AppColors.primary),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Sertakan instruksi pengerjaan & ringkasan kompetensi dasar.',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kartuBerkas() {
    return _kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Berkas Materi\nPembelajaran',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6EEFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBFD3FF)),
                ),
                child: Text(
                  '${_berkas.length} Berkas\nTerlampir',
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.folder_open_outlined,
                  color: AppColors.textSecondary, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEDEFF3)),
          const SizedBox(height: 12),
          ..._berkas.asMap().entries.map((e) => _itemBerkas(e.key, e.value)),
          InkWell(
            onTap: _pilihBerkas,
            borderRadius: BorderRadius.circular(10),
            child: CustomPaint(
              painter: _DashedBorderPainter(),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFE6EEFF),
                      child: Icon(Icons.cloud_upload_outlined,
                          color: AppColors.primary, size: 22),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '+ Tambah Berkas Lainnya (Bisa pilih banyak berkas)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Format didukung: PDF, PPTX, MP4, DOCX (Maks. 50 MB per berkas)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemBerkas(int index, PlatformFile f) {
    final ext = (f.extension ?? '').toLowerCase();
    final video = ['mp4', 'mov', 'mkv', 'avi'].contains(ext);
    final pdf = ext == 'pdf';
    final latar = pdf
        ? const Color(0xFFFEE2E2)
        : video
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFE5E7EB);
    final warna = pdf
        ? AppColors.error
        : video
            ? AppColors.warning
            : AppColors.textSecondary;
    final ikon = pdf
        ? Icons.picture_as_pdf_outlined
        : video
            ? Icons.play_circle_outline
            : Icons.insert_drive_file_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: latar,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(ikon, color: warna, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${index + 1}. ${f.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Text(
                        'Siap Diunduh Siswa',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _ukuran(f.size),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => setState(() => _berkas.removeAt(index)),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.delete_outline,
                  color: AppColors.textSecondary, size: 19),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuTargetKelas() {
    return _kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Target Kelas',
              hitung: '${_kelasDipilih.length} Kelas Terpilih'),
          const SizedBox(height: 12),
          Row(
            children: _kelas.entries.map((e) {
              final aktif = _kelasDipilih.contains(e.key);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: e.key == _kelas.keys.last ? 0 : 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() {
                      aktif
                          ? _kelasDipilih.remove(e.key)
                          : _kelasDipilih.add(e.key);
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: aktif
                            ? const Color(0xFFEFF4FF)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: aktif
                              ? const Color(0xFFBFD3FF)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kelas ${e.key}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${e.value} Siswa',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: aktif
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: aktif
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: aktif
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 16)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _kartuPublikasi() {
    return _kartu(
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Publikasikan Sekarang',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Materi langsung dapat diakses & dipelajari siswa',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 11.5),
                ),
              ],
            ),
          ),
          Switch(
            value: _publikasi,
            onChanged: (v) => setState(() => _publikasi = v),
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC7D2FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(10),
      ));
    for (final metric in path.computeMetrics()) {
      double jarak = 0;
      while (jarak < metric.length) {
        canvas.drawPath(metric.extractPath(jarak, jarak + 6), paint);
        jarak += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}