import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/absensi_model.dart';
import '../../../services/absensi_service.dart';
import '../../../utils/constants.dart';

class UploadSuratScreen extends StatefulWidget {
  const UploadSuratScreen({
    super.key,
  });

  @override
  State<UploadSuratScreen> createState() => _UploadSuratScreenState();
}

class _UploadSuratScreenState extends State<UploadSuratScreen> {
  final _formKey = GlobalKey<FormState>();

  final AbsensiService _absensiService = AbsensiService();

  final TextEditingController _keteranganController =
      TextEditingController();

  String? _jenisIzin;

  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;

  Uint8List? _fileBytes;
  String? _fileName;

  bool _isLoading = false;

  final List<String> _jenisIzinList = [
    'Sakit',
    'Izin',
  ];

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _pilihTanggalMulai() async {
    final DateTime? picked = await showDatePicker(
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

        // Jika tanggal selesai belum dipilih,
        // otomatis mengikuti tanggal mulai.
        if (_tanggalSelesai == null ||
            _tanggalSelesai!.isBefore(picked)) {
          _tanggalSelesai = picked;
        }
      });
    }
  }

  Future<void> _pilihTanggalSelesai() async {
    final DateTime minimumDate =
        _tanggalMulai ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
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
      final FilePickerResult? result =
          await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'pdf',
        ],
        withData: true,
      );

      if (result == null) {
        return;
      }

      final PlatformFile file = result.files.single;

      if (file.bytes == null) {
        _showSnackBar(
          'File tidak dapat dibaca.',
          isError: true,
        );
        return;
      }

      // Maksimal 5 MB
      if (file.bytes!.length > 5 * 1024 * 1024) {
        _showSnackBar(
          'Ukuran file maksimal 5 MB.',
          isError: true,
        );
        return;
      }

      setState(() {
        _fileBytes = file.bytes;
        _fileName = file.name;
      });
    } catch (e) {
      _showSnackBar(
        'Gagal memilih file.',
        isError: true,
      );
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

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_tanggalMulai == null) {
      _showSnackBar(
        'Silakan pilih tanggal mulai.',
        isError: true,
      );
      return;
    }

    if (_tanggalSelesai == null) {
      _showSnackBar(
        'Silakan pilih tanggal selesai.',
        isError: true,
      );
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

    final PengajuanIzinModel pengajuan =
        PengajuanIzinModel(
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
          await _absensiService.kirimPengajuanIzin(
        pengajuan,
      );

      if (!mounted) return;

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        _showSnackBar(
          'Pengajuan izin berhasil dikirim.',
        );

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

  void _showSnackBar(
    String message, {
    bool isError = false,
  }) {
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
          onPressed: () {
            Navigator.pop(context);
          },
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
            padding: const EdgeInsets.fromLTRB(
              24,
              16,
              24,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ==================================================
                // TAB
                // ==================================================

                _buildTabHeader(),

                const SizedBox(height: 16),

                // ==================================================
                // INFO CARD
                // ==================================================

                _buildInfoCard(),

                const SizedBox(height: 22),

                // ==================================================
                // JENIS KETIDAKHADIRAN
                // ==================================================

                _buildSectionTitle(
                  'Jenis Ketidakhadiran',
                ),

                const SizedBox(height: 8),

                _buildJenisIzinDropdown(),

                const SizedBox(height: 22),

                // ==================================================
                // RENTANG TANGGAL
                // ==================================================

                _buildSectionTitle(
                  'Rentang Tanggal',
                ),

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

                // ==================================================
                // KETERANGAN
                // ==================================================

                _buildSectionTitle(
                  'Keterangan / Alasan',
                ),

                const SizedBox(height: 8),

                _buildKeteranganField(),

                const SizedBox(height: 22),

                // ==================================================
                // UPLOAD
                // ==================================================

                _buildSectionTitle(
                  'Upload Dokumen Bukti',
                ),

                const SizedBox(height: 8),

                _buildUploadBox(),

                const SizedBox(height: 20),

                // ==================================================
                // BUTTON
                // ==================================================

                _buildSubmitButton(),

                const SizedBox(height: 16),
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
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Form Izin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                // Bisa diarahkan ke halaman histori
              },
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.textSecondary,
                      size: 17,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Histori Kehadiran',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
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
  // DROPDOWN
  // ============================================================

  Widget _buildJenisIzinDropdown() {
    return DropdownButtonFormField<String>(
      value: _jenisIzin,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,

        hintText: 'Pilih jenis ketidakhadiran',
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),

        prefixIcon: const Icon(
          Icons.event_busy_outlined,
          color: AppColors.primary,
          size: 20,
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
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
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
      ),

      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textSecondary,
      ),

      items: _jenisIzinList.map(
        (String jenis) {
          return DropdownMenuItem<String>(
            value: jenis,
            child: Text(
              jenis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          );
        },
      ).toList(),

      onChanged: (String? value) {
        setState(() {
          _jenisIzin = value;
        });
      },

      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Jenis izin wajib dipilih';
        }

        return null;
      },
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
    final String dateText = date == null
        ? 'Pilih tanggal'
        : DateFormat('MM/dd/yyyy').format(date);

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
          border: Border.all(
            color: AppColors.border,
          ),
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
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
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
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
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
    final bool hasFile =
        _fileBytes != null && _fileName != null;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: hasFile ? null : _pilihFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: hasFile
            ? _buildSelectedFile()
            : _buildEmptyUpload(),
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
        onPressed: _isLoading
            ? null
            : _kirimPengajuan,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor:
              AppColors.primary.withOpacity(0.6),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor:
              AppColors.primary.withOpacity(0.25),
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
                  valueColor:
                      AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
            : const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send_outlined,
                    size: 19,
                  ),
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