import 'package:flutter/material.dart';

import '../../../utils/constants.dart';

class EditTugasScreen extends StatefulWidget {
  final Map<String, dynamic> tugas;
  const EditTugasScreen({super.key, this.tugas = const {}});

  @override
  State<EditTugasScreen> createState() => _EditTugasScreenState();
}

class _EditTugasScreenState extends State<EditTugasScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  late TextEditingController _bobotController;
  String? _selectedMapel;
  String? _selectedKelas;
  DateTime? _selectedDeadline;
  bool _isLoading = false;

  final List<String> _mapelList = [
    'Matematika',
    'Bahasa Indonesia',
    'IPA',
    'IPS',
    'B. Inggris',
  ];
  final List<String> _kelasList = ['9A', '9B', '9C', '9D'];

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.tugas['judul'] ?? '');
    _deskripsiController = TextEditingController(
      text: widget.tugas['deskripsi'] ?? '',
    );
    _bobotController = TextEditingController(
      text: widget.tugas['bobot']?.toString() ?? '100',
    );
    _selectedMapel = widget.tugas['mata_pelajaran'];
    _selectedKelas = widget.tugas['kelas'];
    if (widget.tugas['deadline'] != null) {
      final deadline = DateTime.parse(widget.tugas['deadline']);
      _selectedDeadline = deadline;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _bobotController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 23, minute: 59),
      );
      if (time != null) {
        setState(() {
          _selectedDeadline = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tugas berhasil diupdate'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    }
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Edit Tugas',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormSectionTitle('Informasi Tugas'),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Mata Pelajaran',
                      hint: 'Pilih mapel',
                      value: _selectedMapel,
                      items: _mapelList,
                      onChanged: (value) =>
                          setState(() => _selectedMapel = value),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      label: 'Kelas',
                      hint: 'Pilih kelas',
                      value: _selectedKelas,
                      items: _kelasList,
                      onChanged: (value) =>
                          setState(() => _selectedKelas = value),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _judulController,
                      label: 'Judul Tugas',
                      hint: 'Contoh: Soal Ujian Tengah Semester',
                      validator: (value) =>
                          value!.isEmpty ? 'Judul tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _deskripsiController,
                      label: 'Deskripsi / Instruksi',
                      hint: 'Masukkan instruksi pengerjaan...',
                      maxLines: 4,
                      validator: (value) => value!.isEmpty
                          ? 'Deskripsi tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _bobotController,
                      label: 'Bobot Nilai',
                      hint: 'Contoh: 100',
                      prefix: 'Poin',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    _buildFormSectionTitle('Deadline'),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: InkWell(
                        onTap: _pickDeadline,
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.warningLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.access_time_rounded,
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Batas Waktu',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _selectedDeadline != null
                                        ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year} ${_selectedDeadline!.hour.toString().padLeft(2, '0')}:${_selectedDeadline!.minute.toString().padLeft(2, '0')}'
                                        : 'Pilih deadline',
                                    style: TextStyle(
                                      color: _selectedDeadline != null
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildFormSectionTitle('Lampiran'),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.upload_file_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'File Saat Ini',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'tugas_matematika.pdf',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.download_rounded, size: 16),
                            label: const Text('Unduh'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded),
                          SizedBox(width: 8),
                          Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFormSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          border: InputBorder.none,
        ),
        style: TextStyle(
          color: value != null
              ? AppColors.textPrimary
              : AppColors.textSecondary,
          fontWeight: value != null ? FontWeight.w600 : FontWeight.normal,
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Pilih $label' : null,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? prefix,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (prefix != null) ...[
                Text(
                  prefix,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: TextFormField(
                  controller: controller,
                  maxLines: maxLines,
                  keyboardType: keyboardType,
                  validator: validator,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
