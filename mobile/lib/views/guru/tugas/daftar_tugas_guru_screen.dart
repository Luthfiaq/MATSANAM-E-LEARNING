
import 'package:flutter/material.dart';

class DaftarTugasGuruScreen extends StatefulWidget {
  final String mapel;
  final String kelas;

  const DaftarTugasGuruScreen({
    super.key,
    required this.mapel,
    required this.kelas,
  });

  @override
  State<DaftarTugasGuruScreen> createState() =>
      _DaftarTugasGuruScreenState();
}

class _DaftarTugasGuruScreenState extends State<DaftarTugasGuruScreen> {
  final Color primary = const Color(0xFF0349C9);
  final TextEditingController searchController = TextEditingController();
final TextEditingController titleController = TextEditingController();
final TextEditingController descriptionController = TextEditingController();
final TextEditingController deadlineController = TextEditingController();

String searchQuery = '';
  final List<Map<String, String>> tasks = [
    {
      'title': 'Latihan Soal Bab 1',
      'description': 'Kerjakan latihan soal yang telah diberikan.',
      'deadline': '10 November 2026',
      'date': '04 November 2026',
    },
    {
      'title': 'Tugas Individu',
      'description': 'Buat rangkuman materi pembelajaran.',
      'deadline': '12 November 2026',
      'date': '03 November 2026',
    },
  ];

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get background =>
      isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC);

  Color get cardColor =>
      isDark ? const Color(0xFF1F2937) : Colors.white;

  Color get textColor =>
      isDark ? const Color(0xFFF1F5F9) : const Color(0xFF172033);

  Color get secondaryColor =>
      isDark ? const Color(0xFF9CA3AF) : const Color(0xFF94A3B8);

  Color get borderColor =>
      isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

  List<Map<String, String>> get filteredTasks {
    return tasks.where((task) {
      return task['title']!
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
void dispose() {
  searchController.dispose();
  titleController.dispose();
  descriptionController.dispose();
  deadlineController.dispose();
  super.dispose();
}
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> showTaskForm({
    Map<String, String>? task,
    int? index,
  }) async {
    

   titleController.text = task?['title'] ?? '';
descriptionController.text = task?['description'] ?? '';
deadlineController.text = task?['deadline'] ?? '';

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardColor,
        title: Text(
          task == null ? 'Tambah Tugas' : 'Edit Tugas',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(
                  labelText: 'Judul Tugas',
                  prefixIcon: Icon(Icons.assignment_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Tugas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: deadlineController,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(
                  labelText: 'Tenggat Waktu',
                  hintText: 'Contoh: 15 November 2026',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (titleController.text.trim().isEmpty ||
                  deadlineController.text.trim().isEmpty) {
                return;
              }

              Navigator.pop(dialogContext, {
                'title': titleController.text.trim(),
                'description': descriptionController.text.trim(),
                'deadline': deadlineController.text.trim(),
                'date': task?['date'] ?? '05 November 2026',
              });
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    
    if (result == null || !mounted) return;

    setState(() {
      if (index == null) {
        tasks.insert(0, result);
      } else {
        tasks[index] = result;
      }
    });

    showMessage(
      index == null
          ? 'Tugas berhasil ditambahkan'
          : 'Tugas berhasil diperbarui',
    );
  }

  Future<void> deleteTask(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardColor,
        title: Text(
          'Hapus Tugas?',
          style: TextStyle(color: textColor),
        ),
        content: Text(
          'Tugas "${tasks[index]['title']}" akan dihapus.',
          style: TextStyle(color: secondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        tasks.removeAt(index);
      });
      showMessage('Tugas berhasil dihapus');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(Icons.arrow_back, color: textColor),
        ),
        title: Text(
          'Daftar Tugas',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTaskForm(),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tugas'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClassInfo(),
              const SizedBox(height: 20),
              _buildSearch(),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tugas Pembelajaran',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${filteredTasks.length} Tugas',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (filteredTasks.isEmpty)
                _buildEmptyState()
              else
                ...filteredTasks.map((task) {
                  final index = tasks.indexOf(task);
                  return _buildTaskCard(task, index);
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.school_outlined,
            color: Colors.white,
            size: 27,
          ),
          const SizedBox(height: 12),
          const Text(
            'MATA PELAJARAN',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.mapel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.kelas,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() => searchQuery = value);
        },
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Cari tugas...',
          hintStyle: TextStyle(color: secondaryColor),
          prefixIcon: Icon(Icons.search, color: secondaryColor),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() => searchQuery = '');
                  },
                  icon: Icon(Icons.close, color: secondaryColor),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, String> task, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF263A60)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['title']!,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Dibuat ${task['date']}',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: secondaryColor),
                onSelected: (value) {
                  if (value == 'edit') {
                    showTaskForm(task: task, index: index);
                  } else if (value == 'delete') {
                    deleteTask(index);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 19),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 19,
                        ),
                        SizedBox(width: 8),
                        Text('Hapus'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            task['description']!,
            style: TextStyle(
              color: secondaryColor,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: borderColor),
          Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: 15,
                color: secondaryColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Tenggat: ${task['deadline']}',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 11,
                  ),
                ),
              ),
              const Icon(
                Icons.assignment_turned_in_outlined,
                color: Colors.green,
                size: 16,
              ),
              const SizedBox(width: 4),
              const Text(
                'Aktif',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 42,
            color: secondaryColor,
          ),
          const SizedBox(height: 12),
          Text(
            'Tugas tidak ditemukan',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Coba gunakan kata kunci lainnya.',
            style: TextStyle(
              color: secondaryColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
