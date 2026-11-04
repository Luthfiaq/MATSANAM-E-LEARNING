
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/absensi_model.dart';
import '../../../services/absensi_service.dart';
import '../../../utils/constants.dart';

class UploadSuratScreen extends StatefulWidget {
  const UploadSuratScreen({super.key});

  @override
  State<UploadSuratScreen> createState() => _UploadSuratScreenState();
}

class _UploadSuratScreenState extends State<UploadSuratScreen> {
  final _formKey = GlobalKey<FormState>();
  final AbsensiService _absensiService = AbsensiService();
  final TextEditingController _keteranganController =
      TextEditingController();

  String? _jenisIzin;
  String? _selectedJenisLabel;

  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;

  Uint8List? _fileBytes;
  String? _fileName;

  bool _isLoading = false;
  bool _showHistory = false;

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _pilihTanggalMulai() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalMulai ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tanggalMulai = picked;

        if (_tanggalSelesai == null ||
            _tanggalSelesai!.isBefore(picked)) {
          _tanggalSelesai = picked;
        }
      });
    }
  }

  Future<void> _pilihTanggalSelesai() async {
    final minimumDate = _tanggalMulai ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalSelesai ?? minimumDate,
      firstDate: minimumDate,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tanggalSelesai = picked;
      });
    }
  }

  // ============================================================
  // FILE PICKER
  // ============================================================

  Future<void> _pilihFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result == null) return;

      final file = result.files.single;

      if (file.bytes == null) {
        _showSnackBar('File tidak dapat dibaca.', isError: true);
        return;
      }

      if (file.bytes!.length > 5 * 1024 * 1024) {
        _showSnackBar('Ukuran file maksimal 5 MB.', isError: true);
        return;
      }

      setState(() {
        _fileBytes = file.bytes;
        _fileName = file.name;
      });
    } catch (e) {
      _showSnackBar('Gagal memilih file.', isError: true);
    }
  }

  void _hapusFile() {
    setState(() {
      _fileBytes = null;
      _fileName = null;
    });
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _kirimPengajuan() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_jenisIzin == null || _selectedJenisLabel == null) {
      _showSnackBar(
        'Silakan pilih jenis ketidakhadiran.',
        isError: true,
      );
      return;
    }

    if (_tanggalMulai == null || _tanggalSelesai == null) {
      _showSnackBar('Silakan lengkapi rentang tanggal.', isError: true);
      return;
    }

    if (_tanggalSelesai!.isBefore(_tanggalMulai!)) {
      _showSnackBar(
        'Tanggal selesai tidak boleh sebelum tanggal mulai.',
        isError: true,
      );
      return;
    }

    if (_fileBytes == null || _fileName == null) {
      _showSnackBar(
        'Silakan upload surat bukti terlebih dahulu.',
        isError: true,
      );
      return;
    }

    final pengajuan = PengajuanIzinModel(
      jenisIzin: _jenisIzin!,
      tanggalMulai: _tanggalMulai!,
      tanggalSelesai: _tanggalSelesai!,
      keterangan: _keteranganController.text.trim(),
      fileBytes: _fileBytes,
      fileName: _fileName,
    );

    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await _absensiService.kirimPengajuanIzin(pengajuan);

      if (!mounted) return;

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        _showSnackBar('Pengajuan berhasil dikirim.');
        _resetForm();
      } else {
        _showSnackBar(
          'Pengajuan gagal. Status: ${response.statusCode}',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        'Terjadi kesalahan saat mengirim pengajuan.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    setState(() {
      _jenisIzin = null;
      _selectedJenisLabel = null;
      _tanggalMulai = null;
      _tanggalSelesai = null;
      _fileBytes = null;
      _fileName = null;
      _keteranganController.clear();
    });
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pengajuan Izin / Sakit',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTabHeader(),
                const SizedBox(height: 16),

                if (_showHistory)
                  _buildHistoriKehadiran()
                else ...[
                  _buildInfoCard(),
                  const SizedBox(height: 22),

                  _buildSectionTitle('Jenis Ketidakhadiran'),
                  const SizedBox(height: 8),
                  _buildJenisIzinCards(),
                  const SizedBox(height: 22),

                  _buildSectionTitle('Rentang Tanggal'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: 'Mulai',
                          date: _tanggalMulai,
                          onTap: _pilihTanggalMulai,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDateField(
                          label: 'Selesai',
                          date: _tanggalSelesai,
                          onTap: _pilihTanggalSelesai,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  _buildSectionTitle('Keterangan / Alasan'),
                  const SizedBox(height: 8),
                  _buildKeteranganField(),
                  const SizedBox(height: 22),

                  _buildSectionTitle('Upload Dokumen Bukti'),
                  const SizedBox(height: 8),
                  _buildUploadBox(),
                  const SizedBox(height: 20),

                  _buildSubmitButton(),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TAB HEADER
  // ============================================================

  Widget _buildTabHeader() {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              title: 'Form Izin',
              icon: Icons.edit_note_rounded,
              isSelected: !_showHistory,
              onTap: () {
                setState(() => _showHistory = false);
              },
            ),
          ),
          Expanded(
            child: _buildTabItem(
              title: 'Histori Kehadiran',
              icon: Icons.calendar_month_outlined,
              isSelected: _showHistory,
              onTap: () {
                setState(() => _showHistory = true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected
                  ? Colors.white
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 25,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Form Ketidakhadiran Resmi',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Surat permohonan akan diverifikasi oleh Wali Kelas dan guru piket madrasah.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
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
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ============================================================
  // JENIS KETIDAKHADIRAN
  // ============================================================

  Widget _buildJenisIzinCards() {
    final jenis = [
      {
        'title': 'Sakit',
        'description': 'Memerlukan surat keterangan dokter',
        'icon': Icons.medical_services_outlined,
        'color': Colors.orange,
        'value': 'Sakit',
      },
      {
        'title': 'Izin Penting Keluarga',
        'description': 'Keperluan mendesak keluarga/wali',
        'icon': Icons.family_restroom_rounded,
        'color': AppColors.primary,
        'value': 'Izin',
      },
      {
        'title': 'Dispensasi Madrasah',
        'description': 'Tugas lomba / kegiatan delegasi',
        'icon': Icons.emoji_events_outlined,
        'color': Colors.teal,
        'value': 'Izin',
      },
    ];

    return Column(
      children: jenis.map((item) {
        final selected = _selectedJenisLabel == item['title'];
        final itemColor = item['color'] as Color;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                _selectedJenisLabel = item['title'] as String;
                _jenisIzin = item['value'] as String;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.border,
                  width: selected ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? AppColors.primary
                          : const Color(0xFFE9EDFF),
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    item['icon'] as IconData,
                    color: itemColor,
                    size: 23,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['description'] as String,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primary,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // HISTORI KEHADIRAN
  // ============================================================

  Widget _buildHistoriKehadiran() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.event_note_outlined,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum Ada Histori Kehadiran',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Riwayat kehadiran akan ditampilkan di sini setelah guru atau admin menginput data presensi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final dateText = date == null
        ? 'Pilih tanggal'
        : DateFormat('dd/MM/yyyy').format(date);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dateText,
                    style: TextStyle(
                      color: date == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // KETERANGAN
  // ============================================================

  Widget _buildKeteranganField() {
    return TextFormField(
      controller: _keteranganController,
      maxLines: 4,
      textInputAction: TextInputAction.newline,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        hintText:
            'Tuliskan alasan lengkap kondisi siswa dan informasi pendukung...',
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 13,
          height: 1.4,
        ),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Keterangan wajib diisi';
        }
        if (value.trim().length < 5) {
          return 'Keterangan terlalu singkat';
        }
        return null;
      },
    );
  }

  // ============================================================
  // UPLOAD BOX
  // ============================================================

  Widget _buildUploadBox() {
    final hasFile = _fileBytes != null && _fileName != null;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: hasFile ? null : _pilihFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: hasFile ? _buildSelectedFile() : _buildEmptyUpload(),
      ),
    );
  }

  Widget _buildEmptyUpload() {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.cloud_upload_outlined,
            color: AppColors.primary,
            size: 27,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Upload Surat Dokter / Keterangan',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Format JPG, PNG, atau PDF (Maks. 5MB)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFile() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: AppColors.success,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dokumen terpilih',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _fileName!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Hapus file',
          onPressed: _hapusFile,
          icon: const Icon(
            Icons.close_rounded,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _kirimPengajuan,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor:
              AppColors.primary.withOpacity(0.6),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_outlined, size: 19),
                  SizedBox(width: 8),
                  Text(
                    'Kirim Surat Izin / Sakit',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
