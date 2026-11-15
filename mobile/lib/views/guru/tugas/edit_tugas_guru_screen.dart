import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class EditTugasGuruScreen extends StatefulWidget {
  final Map<String, String> task;
  final String mapel;
  final String kelas;

  const EditTugasGuruScreen({
    super.key,
    this.task = const {},
    this.mapel = 'Matematika',
    this.kelas = 'Kelas 9 Semester Ganjil',
  });

  @override
  State<EditTugasGuruScreen> createState() => _EditTugasGuruScreenState();
}

class _EditTugasGuruScreenState extends State<EditTugasGuruScreen> {
  late final TextEditingController _judul;
  late final TextEditingController _deskripsi;
  final _bobot = TextEditingController(text: '20% (KKM: 75)');

  final Map<String, int> _kelas = {'9A': 32, '9B': 32, '9C': 31};
  final Set<String> _kelasDipilih = {'9A', '9B', '9C'};
  final List<PlatformFile> _berkas = [];
  late String _deadline;
  bool _publikasi = true;

  static const _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    _judul = TextEditingController(text: widget.task['title'] ?? '');
    _deskripsi = TextEditingController(text: widget.task['description'] ?? '');
    _deadline = widget.task['deadline'] ?? '';
  }

  @override
  void dispose() {
    _judul.dispose();
    _deskripsi.dispose();
    _bobot.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final hasil = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (hasil != null) {
      setState(() =>
          _deadline = '${hasil.day} ${_bulan[hasil.month - 1]} ${hasil.year}');
    }
  }

  Future<void> _pilihBerkas() async {
    final hasil = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (hasil == null) return;
    setState(() => _berkas.addAll(hasil.files));
  }

  String _ukuran(int b) => b >= 1024 * 1024
      ? '${(b / (1024 * 1024)).toStringAsFixed(1)} MB'
      : '${(b / 1024).toStringAsFixed(0)} KB';

  void _pesan(String t) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1F2937),
      ),
    );
  }

  void _simpan() {
    if (_judul.text.trim().isEmpty) {
      _pesan('Judul tugas wajib diisi');
      return;
    }
    if (_deskripsi.text.trim().isEmpty) {
      _pesan('Deskripsi tugas wajib diisi');
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
      'deadline': _deadline,
      'date': widget.task['date'] ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Edit Tugas',
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
                children: [
                  _breadcrumb(),
                  const SizedBox(height: 12),
                  _kartuJudul(),
                  const SizedBox(height: 12),
                  _kartuDeskripsi(),
                  const SizedBox(height: 12),
                  _kartuWaktu(),
                  const SizedBox(height: 12),
                  _kartuBerkas(),
                  const SizedBox(height: 12),
                  _kartuKelas(),
                  const SizedBox(height: 12),
                  _kartuPublikasi(),
                  const SizedBox(height: 12),
                  _rujukan(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 52,
                          child: TextButton(
                            onPressed: () => Navigator.maybePop(context),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFEEF0FB),
                              foregroundColor: AppColors.textPrimary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Batal',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _simpan,
                            icon: const Icon(Icons.save_outlined, size: 18),
                            label: const Text('Simpan Perubahan'),
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

  Widget _kartu({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDEFF3)),
        ),
        child: child,
      );

  Widget _label(String teks, {bool wajib = true, String? kanan}) => Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(text: teks, children: [
                if (wajib)
                  const TextSpan(
                      text: ' *', style: TextStyle(color: AppColors.error)),
              ]),
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800),
            ),
          ),
          if (kanan != null)
            Text(kanan,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11.5)),
        ],
      );

  InputDecoration _dekor() => InputDecoration(
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF1F2FC),
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      );

  Widget _breadcrumb() => _kartu(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment_outlined,
                          size: 14, color: AppColors.primaryDark),
                      const SizedBox(width: 4),
                      const Text('Tugas',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      const Text('  /  ',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      Expanded(
                        child: Text(
                          widget.task['title'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.school_outlined,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${widget.mapel} \u2022 ${widget.kelas}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Terbit',
                  style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

  Widget _kartuJudul() => _kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Judul Tugas', kanan: '${_judul.text.length}/60'),
            const SizedBox(height: 10),
            TextField(
              controller: _judul,
              maxLength: 60,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14),
              decoration: _dekor(),
            ),
          ],
        ),
      );

  Widget _kartuDeskripsi() => _kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Deskripsi & Instruksi Pengerjaan'),
            const SizedBox(height: 10),
            TextField(
              controller: _deskripsi,
              maxLines: 5,
              style: const TextStyle(fontSize: 14, height: 1.5),
              decoration: _dekor(),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(Icons.info_outline, size: 15, color: AppColors.primary),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Sertakan instruksi pengerjaan & rubrik penilaian.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _kartuWaktu() => _kartu(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.event_outlined,
                          size: 14, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text('Tenggat Waktu',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pilihTanggal,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F2FC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _deadline.isEmpty ? 'Pilih tanggal' : _deadline,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.star_border_rounded,
                          size: 15, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text('Bobot Rapor',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bobot,
                    style: const TextStyle(fontSize: 13),
                    decoration: _dekor(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _kartuBerkas() => _kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.folder_open_outlined,
                    color: AppColors.primaryDark, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Berkas Lampiran Tugas',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EEFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${_berkas.length} Berkas Terlampir',
                      style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._berkas.asMap().entries.map((e) => _itemBerkas(e.key, e.value)),
            InkWell(
              onTap: _pilihBerkas,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FF),
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
                    SizedBox(height: 8),
                    Text(
                      '+ Tambah Berkas Lainnya (Bisa pilih banyak berkas)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Format didukung: PDF, DOCX, PPTX, XLS (Maks. 50 MB per berkas)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _itemBerkas(int i, PlatformFile f) {
    final pdf = (f.extension ?? '').toLowerCase() == 'pdf';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: pdf ? const Color(0xFFFEE2E2) : const Color(0xFFFFE8D6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              pdf ? Icons.picture_as_pdf_outlined : Icons.description_outlined,
              color: pdf ? AppColors.error : AppColors.accentOrange,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${i + 1}. ${f.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                Text(_ukuran(f.size),
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 3),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Siap Diunduh Siswa',
                      style: TextStyle(
                          color: AppColors.success,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _berkas.removeAt(i)),
            icon: const Icon(Icons.delete_outline,
                color: Color(0xFF94A3B8), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _kartuKelas() => _kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text.rich(
                    TextSpan(text: 'Target Kelas', children: [
                      TextSpan(
                          text: ' *', style: TextStyle(color: AppColors.error)),
                    ]),
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                Text('${_kelasDipilih.length} Kelas Terpilih',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            ..._kelas.entries.map((e) {
              final aktif = _kelasDipilih.contains(e.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => setState(() {
                    aktif
                        ? _kelasDipilih.remove(e.key)
                        : _kelasDipilih.add(e.key);
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F2FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: aktif ? AppColors.primaryDark : Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: aktif
                                    ? AppColors.primaryDark
                                    : AppColors.border),
                          ),
                          child: aktif
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 17)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kelas ${e.key}',
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800)),
                              Text('${e.value} Siswa terdaftar',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11.5)),
                            ],
                          ),
                        ),
                        const Icon(Icons.groups_rounded,
                            color: AppColors.primary, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );

  Widget _kartuPublikasi() => _kartu(
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Publikasikan Sekarang',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 3),
                  Text('Tugas aktif dan dapat diakses siswa di aplikasi',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11.5)),
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

  Widget _rujukan() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF0FB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.menu_book_rounded,
                  color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rujukan Kurikulum & Silabus',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 2),
                  Text('Standar KD 3.6 & 4.6 Matematika Menengah',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11.5)),
                ],
              ),
            ),
          ],
        ),
      );
}