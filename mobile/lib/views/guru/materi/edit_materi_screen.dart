import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/api_config.dart';
import '../../../utils/constants.dart';
import '../../../utils/theme_helpers.dart';

class EditMateriScreen extends StatefulWidget {
  final Map<String, dynamic> materi;
  const EditMateriScreen({super.key, this.materi = const {}});

  @override
  State<EditMateriScreen> createState() => _EditMateriScreenState();
}

class _EditMateriScreenState extends State<EditMateriScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  late TextEditingController _linkController;
  String? _selectedMapel;
  String? _selectedKelas;
  String _selectedType = 'pdf';
  late String _originalType;
  PlatformFile? _pickedFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(
      text: widget.materi['judul'] ?? '',
    );
    _deskripsiController = TextEditingController(
      text: widget.materi['deskripsi'] ?? '',
    );
    _selectedMapel = widget.materi['mata_pelajaran'];
    _selectedKelas = widget.materi['kelas'];
    _selectedType = widget.materi['tipe']?.toString() ?? 'pdf';
    _originalType = _selectedType;
    _linkController = TextEditingController(
      text: widget.materi['link']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _linkController.dispose();
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text('Edit Materi', style: context.matsanamHeading3),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pushNamed(context, '/pengaturan'),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 19),
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
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _editContextHeader(),
                      const SizedBox(height: 12),
                      _editSection(
                        title: 'Judul & Deskripsi',
                        subtitle: 'Perbarui informasi materi pembelajaran.',
                        children: [
                          _buildTextField(
                            controller: _judulController,
                            label: 'Judul Materi',
                            hint: 'Masukkan judul materi...',
                            validator: (value) => value == null || value.trim().isEmpty
                                ? 'Judul tidak boleh kosong'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _deskripsiController,
                            label: 'Deskripsi Pembelajaran',
                            hint: 'Tulis petunjuk belajar untuk siswa...',
                            maxLines: 4,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _editSection(
                        title: 'Berkas Materi Pembelajaran',
                        subtitle: 'Materi menggunakan satu berkas atau satu tautan sesuai jenisnya.',
                        children: [
                          _buildFormSectionTitle('Jenis Materi'),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.matsanamPage,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.matsanamBorder),
                            ),
                            child: Column(
                              children: [
                                _buildTypeOption('pdf', 'File PDF', Icons.picture_as_pdf_outlined, AppColors.primary),
                                Divider(height: 18, color: context.matsanamBorder),
                                _buildTypeOption('video', 'Video', Icons.play_circle_outline_rounded, AppColors.accentOrange),
                                Divider(height: 18, color: context.matsanamBorder),
                                _buildTypeOption('link', 'Link URL', Icons.link_rounded, AppColors.info),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFormSectionTitle('File / Link Saat Ini'),
                          const SizedBox(height: 9),
                          if ((widget.materi['file_path']?.toString() ?? '').isNotEmpty)
                            _buildCurrentFile()
                          else if (widget.materi['link'] != null)
                            _buildCurrentLink()
                          else
                            _buildNoCurrentResource(),
                          const SizedBox(height: 16),
                          _buildFormSectionTitle('Ganti File / Link'),
                          const SizedBox(height: 9),
                          if (_selectedType == 'pdf' || _selectedType == 'video')
                            _buildFileUpload()
                          else
                            _buildLinkInput(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _editInfoNote(),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _isLoading
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: BoxDecoration(
                  color: context.matsanamSurface,
                  border: Border(top: BorderSide(color: context.matsanamBorder)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          foregroundColor: context.matsanamText,
                          side: BorderSide(color: context.matsanamBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _submitForm,
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Simpan Perubahan'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _editContextHeader() {
    final academicYear = (widget.materi['tahun_ajaran'] ?? '').toString().trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.matsanamSurface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: context.matsanamBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('MATSANAM GURU', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .55)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(color: context.matsanamSoftSuccess, borderRadius: BorderRadius.circular(20)),
                child: Text('Terhubung ke Jadwal', style: TextStyle(color: context.matsanamSuccess, fontSize: 9, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            '${_selectedMapel ?? 'Mata Pelajaran'} • ${_selectedKelas ?? 'Kelas'}',
            style: TextStyle(color: context.matsanamText, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            academicYear.isEmpty
                ? 'Materi tetap terikat pada jadwal kelas ini.'
                : 'T.A. $academicYear • Materi tetap terikat pada jadwal kelas ini.',
            style: TextStyle(color: context.matsanamTextSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _editSection({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: context.matsanamSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.matsanamBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: context.matsanamText, fontSize: 14, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: context.matsanamTextSecondary, fontSize: 11, height: 1.35)),
        const SizedBox(height: 14),
        ...children,
      ],
    ),
  );

  Widget _editInfoNote() => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: context.matsanamSoftPrimary,
      borderRadius: BorderRadius.circular(13),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            'Perubahan judul, deskripsi, atau berkas akan memperbarui materi yang sama. Sasaran kelas mengikuti jadwal asal.',
            style: TextStyle(color: context.matsanamTextSecondary, fontSize: 11, height: 1.4),
          ),
        ),
      ],
    ),
  );

  Widget _buildFormSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: context.matsanamText,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildReadOnlyInfoField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.matsanamSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.matsanamBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: context.matsanamTextSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: context.matsanamText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_outline_rounded,
            color: context.matsanamTextSecondary,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.matsanamSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.matsanamBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.matsanamTextSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: context.matsanamTextSecondary),
              border: InputBorder.none,
            ),
            style: TextStyle(color: context.matsanamText),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(
    String type,
    String label,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () => setState(() {
        if (_selectedType != type) _pickedFile = null;
        _selectedType = type;
      }),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _selectedType == type
                  ? color.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: _selectedType == type ? color : context.matsanamTextSecondary,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              color: _selectedType == type
                  ? context.matsanamText
                  : context.matsanamTextSecondary,
              fontWeight: _selectedType == type
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
          const Spacer(),
          if (_selectedType == type)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
        ],
      ),
    );
  }

  String _fileSizeLabel(dynamic rawSize) {
    if (rawSize is! num || rawSize <= 0) return 'File tersimpan';
    final bytes = rawSize.toDouble();
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }

  Widget _buildCurrentFile() {
    final isVideo = _originalType == 'video';
    final filePath = widget.materi['file_path']?.toString() ?? '';
    final fileName =
        widget.materi['file_name']?.toString() ??
        (filePath.isEmpty ? 'File materi' : filePath.split('/').last);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.matsanamPage,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.matsanamBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.matsanamSoftPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isVideo
                  ? Icons.play_circle_outline_rounded
                  : Icons.picture_as_pdf_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.matsanamText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _fileSizeLabel(widget.materi['file_size']),
                  style: TextStyle(
                    color: context.matsanamTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLink() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.matsanamPage,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.matsanamBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.link_rounded, color: AppColors.info),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tautan materi saat ini',
                  style: TextStyle(
                    color: context.matsanamText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.materi['link']?.toString() ?? '-',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.matsanamTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCurrentResource() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.matsanamSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.matsanamBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: context.matsanamTextSecondary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Belum ada file atau tautan yang tersimpan. Tambahkan pada bagian Ganti File / Link.',
              style: TextStyle(color: context.matsanamTextSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUpload() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.matsanamPage,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.matsanamBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: context.matsanamSoftPrimary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.upload_file_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'PDF atau video (maksimal 10 MB)',
            style: TextStyle(
              color: context.matsanamTextSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickReplacementFile,
            icon: Icon(Icons.folder_open_rounded),
            label: Text(_pickedFile?.name ?? 'Pilih File Baru'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickReplacementFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _selectedType == 'pdf'
            ? ['pdf']
            : ['mp4', 'mov', 'webm'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      if (file.bytes == null) {
        throw Exception('File tidak dapat dibaca oleh browser.');
      }
      if (file.size > 10 * 1024 * 1024) {
        throw Exception('Ukuran file maksimal 10 MB.');
      }
      if (!mounted) return;
      setState(() => _pickedFile = file);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildLinkInput() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.matsanamSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.matsanamBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ganti Link URL',
            style: TextStyle(
              color: context.matsanamTextSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.language,
                color: context.matsanamTextSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _linkController,
                  decoration: InputDecoration(
                    hintText: 'https://...',
                    hintStyle: TextStyle(color: context.matsanamTextSecondary),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: context.matsanamText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final materiId = int.tryParse(widget.materi['id']?.toString() ?? '');
    if (materiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ID materi tidak ditemukan. Buka ulang dari daftar materi.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final linkValue = _linkController.text.trim();
    if (_selectedType == 'link') {
      final uri = Uri.tryParse(linkValue);
      if (uri == null ||
          !uri.hasScheme ||
          !['http', 'https'].contains(uri.scheme)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Masukkan URL http:// atau https:// yang valid.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }
    final hasCurrentFile =
        (widget.materi['file_path']?.toString() ?? '').isNotEmpty;
    if ((_selectedType == 'pdf' || _selectedType == 'video') &&
        (_selectedType != _originalType || !hasCurrentFile) &&
        _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih file baru untuk tipe materi yang dipilih.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/guru/materi/$materiId');
      late http.Response response;
      if (_pickedFile != null) {
        final request = http.MultipartRequest('POST', uri)
          ..headers['Accept'] = 'application/json'
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['_method'] = 'PUT'
          ..fields['judul'] = _judulController.text.trim()
          ..fields['deskripsi'] = _deskripsiController.text.trim()
          ..fields['tipe'] = _selectedType
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              _pickedFile!.bytes!,
              filename: _pickedFile!.name,
            ),
          );
        final sent = await request.send().timeout(ApiConfig.timeout);
        response = await http.Response.fromStream(
          sent,
        ).timeout(ApiConfig.timeout);
      } else {
        response = await http
            .put(
              uri,
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                'judul': _judulController.text.trim(),
                'deskripsi': _deskripsiController.text.trim(),
                'tipe': _selectedType,
                'link': _selectedType == 'link'
                    ? linkValue
                    : (_pickedFile == null && _selectedType == _originalType
                          ? widget.materi['link']
                          : null),
              }),
            )
            .timeout(ApiConfig.timeout);
      }

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
        var message = 'Materi gagal diperbarui (HTTP ${response.statusCode}).';
        if (decoded is Map) {
          final errors = decoded['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final first = errors.values.first;
            if (first is List && first.isNotEmpty) {
              message = first.first.toString();
            }
          }
          if (message.startsWith('Materi gagal diperbarui')) {
            message = decoded['message']?.toString() ?? message;
          }
        }
        throw Exception(message);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            decoded['message']?.toString() ?? 'Materi berhasil diperbarui.',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
