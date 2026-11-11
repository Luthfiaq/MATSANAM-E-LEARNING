import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class TambahMateriGuruScreen extends StatefulWidget {
  final String mapel;
  const TambahMateriGuruScreen({super.key, this.mapel = 'Matematika'});

  @override
  State<TambahMateriGuruScreen> createState() => _TambahMateriGuruScreenState();
}

class _TambahMateriGuruScreenState extends State<TambahMateriGuruScreen> {
  final _judul = TextEditingController();
  final _deskripsi = TextEditingController();

  final Map<String, int> _kelas = {'9A': 32, '9B': 32, '9C': 30};
  final Set<String> _kelasDipilih = {'9A', '9B'};
  final List<PlatformFile> _berkas = [];

  bool _langsung = true;
  bool _notif = true;

  @override
  void dispose() {
    _judul.dispose();
    _deskripsi.dispose();
    super.dispose();
  }

  int get _totalSiswa =>
      _kelasDipilih.fold(0, (sum, k) => sum + (_kelas[k] ?? 0));

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

      String _tanggalHariIni() {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final n = DateTime.now();
    return '${n.day.toString().padLeft(2, '0')} ${bulan[n.month - 1]} ${n.year}';
  }

  String _jenisMateri() {
    if (_berkas.isEmpty) return 'PDF';
    final ext = (_berkas.first.extension ?? '').toLowerCase();
    if (ext == 'pdf') return 'PDF';
    if (['mp4', 'mov', 'mkv', 'avi'].contains(ext)) return 'Video';
    return 'Dokumen';
  }

  void _simpan() {
    if (_judul.text.trim().isEmpty) {
      _pesan('Judul materi wajib diisi');
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
      'date': _tanggalHariIni(),
    });
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
        title: const Text(
          'Unggah Materi Baru',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  _header(),
                  const SizedBox(height: 14),
                  _kartuJudul(),
                  const SizedBox(height: 14),
                  _kartuBerkas(),
                  const SizedBox(height: 14),
                  _kartuDeskripsi(),
                  const SizedBox(height: 14),
                  _kartuPublikasi(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _simpan,
                      icon: const Icon(Icons.send_outlined, size: 18),
                      label: const Text('Simpan & Publikasikan Materi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        textStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => Navigator.maybePop(context),
                    child: const Text(
                      'Batal & Kembali ke Daftar Materi',
                      style: TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600),
                    ),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F2F5)),
      ),
      child: child,
    );
  }

  Widget _judulSeksi(IconData ikon, String teks, {Widget? trailing}) {
    return Row(
      children: [
        Icon(ikon, color: AppColors.primary, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            teks,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFE8EDFF)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PUSAT KURIKULUM MATSANAM',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.mapel,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.circle, size: 7, color: AppColors.success),
          const SizedBox(width: 4),
          const Text(
            'T.A. 2026/2027',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 10,
              fontWeight: FontWeight.w700,
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
          _judulSeksi(
            Icons.edit_note_rounded,
            'Judul & Sasaran',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '* Wajib diisi',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'Judul Materi Pembelajaran ',
                    children: [
                      TextSpan(
                          text: '*', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${_judul.text.length}/100',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _kolomTeks(
            controller: _judul,
            hint: 'Contoh: Bab 4 - Trigonometri Dasar',
            maxLength: 100,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Pilihan Kelas Sasaran',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${_kelasDipilih.length} Kelas terpilih ($_totalSiswa siswa)',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kelas.entries.map((e) {
              final aktif = _kelasDipilih.contains(e.key);
              return GestureDetector(
                onTap: () => setState(() {
                  aktif
                      ? _kelasDipilih.remove(e.key)
                      : _kelasDipilih.add(e.key);
                }),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: aktif ? AppColors.primaryDark : const Color(0xFFEFF1FB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        aktif
                            ? Icons.check_circle_outline
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: aktif ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${e.key} (${e.value} Siswa)',
                        style: TextStyle(
                          color: aktif ? Colors.white : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
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
          _judulSeksi(
            Icons.upload_file_rounded,
            'Berkas Materi',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF1FB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Multi-upload',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _pilihBerkas,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.cloud_upload_outlined,
                        color: AppColors.primary, size: 26),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Upload Berkas ke Sini',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Mendukung PDF, Video MP4, Audio, Dokumen\n(Maks. 50 MB)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          if (_berkas.isNotEmpty) const SizedBox(height: 12),
          ..._berkas.asMap().entries.map((e) => _itemBerkas(e.key, e.value)),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pilihBerkas,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline,
                      color: AppColors.primaryDark, size: 18),
                  SizedBox(width: 6),
                  Text(
                    '+ Tambah File Lainnya',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
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

  Widget _itemBerkas(int index, PlatformFile f) {
    final ext = (f.extension ?? '').toLowerCase();
    final video = ['mp4', 'mov', 'mkv', 'avi'].contains(ext);
    final pdf = ext == 'pdf';
    final warnaLatar = pdf
        ? const Color(0xFFFEE2E2)
        : video
            ? const Color(0xFFDBEAFE)
            : const Color(0xFFE5E7EB);
    final warnaIkon = pdf
        ? AppColors.error
        : video
            ? AppColors.primary
            : AppColors.textSecondary;
    final ikon = pdf
        ? Icons.picture_as_pdf_outlined
        : video
            ? Icons.play_circle_outline
            : Icons.insert_drive_file_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: warnaLatar,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(ikon, color: warnaIkon, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _ukuran(f.size),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _berkas.removeAt(index)),
            icon: const Icon(Icons.delete_outline,
                color: Color(0xFF94A3B8), size: 20),
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
          _judulSeksi(
            Icons.description_outlined,
            'Petunjuk & Deskripsi',
            trailing: const Text(
              'Opsional',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Deskripsi Materi',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _kolomTeks(
            controller: _deskripsi,
            hint: 'Tulis petunjuk belajar untuk siswa...',
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _kartuPublikasi() {
    return _kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _judulSeksi(Icons.tune_rounded, 'Pengaturan Publikasi'),
          const SizedBox(height: 12),
          _barisSwitch(
            ikon: Icons.visibility_outlined,
            warnaIkon: AppColors.success,
            warnaLatar: const Color(0xFFD1FAE5),
            judul: 'Publikasikan Langsung ke Siswa',
            deskripsi: 'Siswa dapat langsung mengakses materi di beranda aplikasi.',
            nilai: _langsung,
            onChanged: (v) => setState(() => _langsung = v),
          ),
          const SizedBox(height: 10),
          _barisSwitch(
            ikon: Icons.notifications_active_outlined,
            warnaIkon: AppColors.warning,
            warnaLatar: const Color(0xFFFEF3C7),
            judul: 'Kirim Notifikasi Push ke Siswa',
            deskripsi: 'Kirimkan pemberitahuan instan ke perangkat ponsel siswa.',
            nilai: _notif,
            onChanged: (v) => setState(() => _notif = v),
          ),
        ],
      ),
    );
  }

  Widget _barisSwitch({
    required IconData ikon,
    required Color warnaIkon,
    required Color warnaLatar,
    required String judul,
    required String deskripsi,
    required bool nilai,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: warnaLatar,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(ikon, color: warnaIkon, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  deskripsi,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: nilai,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _kolomTeks({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}