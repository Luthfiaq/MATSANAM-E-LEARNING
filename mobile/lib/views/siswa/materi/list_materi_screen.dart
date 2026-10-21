import 'package:flutter/material.dart';
import '../../../models/materi_model.dart';
import '../../../services/materi_service.dart';
import '../../../widgets/cards/materi_card.dart';
import '../../../utils/constants.dart';
import 'detail_materi_screen.dart';

class ListMateriScreen extends StatefulWidget {
  final int mapelId;
  final String namaMapel;
  final String namaGuru;

  const ListMateriScreen({
    Key? key,
    required this.mapelId,
    required this.namaMapel,
    required this.namaGuru,
  }) : super(key: key);

  @override
  State<ListMateriScreen> createState() => _ListMateriScreenState();
}

class _ListMateriScreenState extends State<ListMateriScreen> {
  final MateriService _materiService = MateriService();
  late Future<List<MateriModel>> _futureMateri;
  String _searchKeyword = '';
  int _selectedTab = 0; // 0: Semua, 1: Belum Dipelajari, 2: Selesai

  @override
  void initState() {
    super.initState();
    _futureMateri = _materiService.getMateriByMapel(widget.mapelId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Materi',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<MateriModel>>(
        future: _futureMateri,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final listMateri = snapshot.data ?? [];

          // Filtering berdasarkan Search & Tab
          final filteredList = listMateri.where((item) {
            final matchSearch = item.judulMateri.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
                item.deskripsi.toLowerCase().contains(_searchKeyword.toLowerCase());
            
            // Dummy status logic for demo tabs
            if (_selectedTab == 1) {
              return matchSearch && item.id % 2 != 0; // Simulasi Belum
            } else if (_selectedTab == 2) {
              return matchSearch && item.id % 2 == 0; // Simulasi Selesai
            }
            return matchSearch;
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card Info Mapel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SEMESTER GANJIL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${listMateri.length} Modul',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.namaMapel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.namaGuru} • MTsN 6 Nganjuk',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(
                      value: 0.5,
                      backgroundColor: Color(0xFFE0E0E0),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Progres Pembelajaran', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('2 dari 4 selesai (50%)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              TextField(
                onChanged: (val) => setState(() => _searchKeyword = val),
                decoration: InputDecoration(
                  hintText: 'Cari judul bab atau topik materi...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tab Filter Horizontal
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabButton('Semua Materi (${listMateri.length})', 0),
                    const SizedBox(width: 8),
                    _buildTabButton('Belum Dipelajari', 1),
                    const SizedBox(width: 8),
                    _buildTabButton('Sudah Selesai', 2),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Offline Access Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.download_done_rounded, color: AppColors.primary),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Akses Belajar Offline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('Unduh seluruh berkas materi mapel', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      child: const Text('Unduh Semua', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Daftar Materi Cards
              if (filteredList.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Tidak ada materi ditemukan.')),
                )
              else
                ...filteredList.map((materi) {
                  final isSelesai = materi.id % 2 == 0;
                  return MateriCard(
                    judulMateri: materi.judulMateri,
                    deskripsiSingkat: materi.deskripsi,
                    tipeFile: materi.tipeFile,
                    infoFile: 'Format: ${materi.tipeFile.toUpperCase()} (${materi.namaGuru ?? "Guru"})',
                    waktuInfo: 'Baru Diunggah',
                    isSelesai: isSelesai,
                    skorKuis: isSelesai ? 'Skor: 90/100' : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailMateriScreen(materi: materi),
                        ),
                      );
                    },
                  );
                }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}