import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class TambahTugasGuruScreen extends StatefulWidget {
  final String mapel;
  final String kelas;
  const TambahTugasGuruScreen({
    super.key,
    this.mapel = 'Matematika',
    this.kelas = 'Kelas 9A, 9B',
  });

  @override
  State<TambahTugasGuruScreen> createState() => _TambahTugasGuruScreenState();
}

class _TambahTugasGuruScreenState extends State<TambahTugasGuruScreen> {
  final _judul = TextEditingController();
  final _bobot = TextEditingController(text: '20%');
  final _kkm = TextEditingController(text: '75');
  final _petunjuk = TextEditingController();

  final Map<String, int> _kelas = {'9A': 32, '9B': 32, '9C': 30};
  final Set<String> _kelasDipilih = {'9A', '9B'};
  final List<PlatformFile> _berkas = [];
  DateTime? _deadline;
  bool _langsung = true;
  bool _notif = true;

  static const _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void dispose() {
    _judul.dispose();
    _bobot.dispose();
    _kkm.dispose();
    _petunjuk.dispose();
    super.dispose();
  }

  int get _totalSiswa =>
      _kelasDipilih.fold(0, (s, k) => s + (_kelas[k] ?? 0));

  String _tgl(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final hasil = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (hasil != null) setState(() => _deadline = hasil);
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

  void _simpan({required bool draf}) {
    if (_judul.text.trim().isEmpty) {
      _pesan('Judul tugas wajib diisi');
      return;
    }
    if (_kelasDipilih.isEmpty) {
      _pesan('Pilih minimal satu kelas');
      return;
    }
    if (_deadline == null) {
      _pesan('Batas pengumpulan wajib diisi');
      return;
    }
    // TODO: sambungkan ke API di sini nanti.
    Navigator.pop(context, <String, String>{
      'title': _judul.text.trim(),
      'description': _petunjuk.text.trim(),
      'deadline': _tgl(_deadline!),
      'status': draf ? 'Draf' : (_langsung ? 'Aktif' : 'Draf'),
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
        title: const Text('Tambah Tugas',
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
                  _banner(),
                  const SizedBox(height: 14),
                  _kartuJudul(),
                  const SizedBox(height: 14),
                  _kartuWaktu(),
                  const SizedBox(height: 14),
                  _kartuBerkas(),
                  const SizedBox(height: 14),
                  _kartuPetunjuk(),
                  const SizedBox(height: 14),
                  _kartuPublikasi(),
                  const SizedBox(height: 14),
                  _tips(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _simpan(draf: false),
                      icon: const Icon(Icons.send_outlined, size: 18),
                      label: const Text('Simpan & Publikasikan Tugas'),
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
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: () => _simpan(draf: true),
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text('Simpan sebagai Draf'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: Color(0xFFEDEFF3)),
                        textStyle: const TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w700),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.maybePop(context),
                    child: const Text('Batal & Kembali ke Daftar Tugas',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF3)),
        ),
        child: child,
      );

  Widget _seksi(String teks, String badge,
      {Color? badgeBg, Color? badgeFg}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(teks,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: badgeBg ?? const Color(0xFFEFF1FB),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(badge,
              style: TextStyle(
                  color: badgeFg ?? AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _label(String teks, {bool wajib = false, String? kanan}) => Row(
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
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
          if (kanan != null)
            Text(kanan,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
        ],
      );

  InputDecoration _dekor(String hint, {Widget? prefix}) => InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        counterText: '',
        prefixIcon: prefix,
        filled: true,
        fillColor: const Color(0xFFF8F9FC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEDEFF3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEDEFF3)),
        ),
      );

  Widget _banner() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFDDE7FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBFD3FF)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.menu_book_outlined,
                          size: 14, color: AppColors.primaryDark),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'PUSAT KURIKULUM MATSANAM \u2022 T.A. 2024/2025',
                          style: TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.mapel} \u2022 Target: ${widget.kelas}',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Aktif',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

  Widget _kartuJudul() => _kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _seksi('Judul & Sasaran', '* Wajib diisi',
                badgeBg: AppColors.errorLight, badgeFg: AppColors.error),
            const SizedBox(height: 14),
            _label('Judul Tugas Pembelajaran',
                wajib: true, kanan: '${_judul.text.length}/100'),
            const SizedBox(height: 8),
            TextField(
              controller: _judul,
              maxLength: 100,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 13.5),
              decoration: _dekor('Contoh: Tugas Bab 4 - Latihan Mandiri'),
            ),
            const SizedBox(height: 14),
            _label('Pilihan Kelas Sasaran',
                kanan:
                    '${_kelasDipilih.length} Kelas terpilih ($_totalSiswa siswa)'),
            const SizedBox(height: 8),
            ..._kelas.entries.map((e) {
              final aktif = _kelasDipilih.contains(e.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() {
                    aktif
                        ? _kelasDipilih.remove(e.key)
                        : _kelasDipilih.add(e.key);
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: aktif
                          ? const Color(0xFFEFF4FF)
                          : const Color(0xFFF3F4FB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          aktif
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: aktif
                              ? AppColors.primaryDark
                              : AppColors.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${e.key} (${e.value} Siswa)',
                            style: TextStyle(
                              color: aktif
                                  ? AppColors.primaryDark
                                  : AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(aktif ? 'Semester Ganjil' : 'Tersedia',
                            style: TextStyle(
                                color: aktif
                                    ? AppColors.primaryDark
                                    : AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );

  Widget _kartuWaktu() => _kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _seksi('Tenggat Waktu & Bobot', 'Akademik',
                badgeBg: AppColors.infoLight, badgeFg: AppColors.primaryDark),
            const SizedBox(height: 14),
            _label('Batas Pengumpulan (Deadline)', wajib: true),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pilihTanggal,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEDEFF3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      _deadline == null
                          ? 'Pilih tanggal'
                          : '${_tgl(_deadline!)}, 23:59 WIB',
                      style: TextStyle(
                        color: _deadline == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: _kolomAngka(
                        'Bobot Rapor (%)', _bobot, 'Komponen Tugas')),
                const SizedBox(width: 12),
                Expanded(
                    child: _kolomAngka(
                        'KKM Minimal', _kkm, 'Batas Ketuntasan')),
              ],
            ),
          ],
        ),
      );

  Widget _kolomAngka(String label, TextEditingController c, String catatan) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          const SizedBox(height: 8),
          TextField(
            controller: c,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            decoration: _dekor(''),
          ),
          const SizedBox(height: 4),
          Text(catatan,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      );

  Widget _kartuBerkas() => _kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _seksi('Berkas Soal / Panduan', 'Multi-upload'),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pilihBerkas,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined,
                        color: AppColors.primaryDark, size: 34),
                    SizedBox(height: 8),
                    Text('Sentuh atau Tarik Berkas ke Sini',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text(
                      'Mendukung PDF, DOCX, Lembar Kerja,\nGambar (Maks. 50 MB)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ..._berkas.asMap().entries.map((e) => _itemBerkas(e.key, e.value)),
            InkWell(
              onTap: _pilihBerkas,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: AppColors.primaryDark, size: 18),
                    SizedBox(width: 6),
                    Text('Tambah File Lainnya',
                        style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: pdf ? const Color(0xFFFEE2E2) : AppColors.infoLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              pdf ? Icons.picture_as_pdf_outlined : Icons.description_outlined,
              color: pdf ? AppColors.error : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                Text('${_ukuran(f.size)} \u2022 Siap diunduh siswa',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
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

  Widget _kartuPetunjuk() => _kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _seksi('Petunjuk & Catatan Pengerjaan', 'Opsional'),
            const SizedBox(height: 12),
            TextField(
              controller: _petunjuk,
              maxLines: 5,
              style: const TextStyle(fontSize: 13.5, height: 1.5),
              decoration: _dekor('Tulis petunjuk pengerjaan untuk siswa...'),
            ),
          ],
        ),
      );

  Widget _kartuPublikasi() => _kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Pengaturan Publikasi',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            _barisSwitch(
              Icons.visibility_outlined,
              AppColors.primary,
              const Color(0xFFEFF4FF),
              'Publikasikan Langsung ke Siswa',
              'Siswa dapat langsung mengakses tugas di beranda',
              _langsung,
              (v) => setState(() => _langsung = v),
            ),
            const SizedBox(height: 10),
            _barisSwitch(
              Icons.notifications_active_outlined,
              AppColors.success,
              AppColors.successLight,
              'Kirim Notifikasi Push ke Siswa',
              'Kirimkan pemberitahuan instan ke perangkat ponsel siswa',
              _notif,
              (v) => setState(() => _notif = v),
            ),
          ],
        ),
      );

  Widget _barisSwitch(IconData ikon, Color warna, Color latar, String judul,
      String desk, bool nilai, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF0F2F5)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: latar, borderRadius: BorderRadius.circular(10)),
            child: Icon(ikon, color: warna, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(desk,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: nilai,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _tips() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tugas dengan instruksi dan rubrik yang jelas meningkatkan ketepatan pengumpulan hingga 90%!',
                style: TextStyle(
                    color: Color(0xFF065F46),
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
}