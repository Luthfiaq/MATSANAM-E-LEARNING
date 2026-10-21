import 'package:flutter/material.dart';
import '../../../services/materi_service.dart';
import '../../../widgets/cards/mapel_card.dart';
import '../../../utils/constants.dart';
import 'list_materi_screen.dart';

class PilihMapelMateriScreen extends StatefulWidget {
  const PilihMapelMateriScreen({Key? key}) : super(key: key);

  @override
  State<PilihMapelMateriScreen> createState() => _PilihMapelMateriScreenState();
}

class _PilihMapelMateriScreenState extends State<PilihMapelMateriScreen> {
  final MateriService _materiService = MateriService();
  late Future<List<Map<String, dynamic>>> _futureMapel;
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _futureMapel = _materiService.getDaftarMapel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Matsanam Siswa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureMapel,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final allMapel = snapshot.data ?? [];
          final filteredMapel = allMapel.where((mapel) {
            final nama = (mapel['nama'] ?? '').toLowerCase();
            return nama.contains(_searchKeyword.toLowerCase());
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Section
              const Text(
                'Materi Pembelajaran',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pilih mata pelajaran untuk melihat daftar materi dan modul belajar',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Search Bar
              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchKeyword = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari nama mata pelajaran...',
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
              const SizedBox(height: 16),

              // Filter Chips
              Row(
                children: [
                  ActionChip(
                    label: const Text('Semua Mapel'),
                    backgroundColor: AppColors.primary,
                    labelStyle: const TextStyle(color: Colors.white),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('Kelas 9'),
                    backgroundColor: Colors.white,
                    labelStyle: const TextStyle(color: Colors.black87),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('Peminatan'),
                    backgroundColor: Colors.white,
                    labelStyle: const TextStyle(color: Colors.black87),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Mapel Tersedia',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${filteredMapel.length} Mapel',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Grid Mapel Cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredMapel.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final mapel = filteredMapel[index];
                  final mapelId = mapel['id'] as int;
                  final namaMapel = mapel['nama'] as String;
                  final deskripsi = mapel['deskripsi'] as String? ?? 'Guru Pengampu';

                  return MapelCard(
                    namaMapel: namaMapel,
                    namaGuru: deskripsi,
                    infoBadge: '3 Modul',
                    iconData: Icons.menu_book_rounded,
                    actionLabel: 'Pilih Mapel',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListMateriScreen(
                            mapelId: mapelId,
                            namaMapel: namaMapel,
                            namaGuru: deskripsi,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              // Info Box Bawah
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Informasi Materi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tips: Pilih mapel untuk mengakses video pembelajaran, lembar kerja, dan modul PDF.',
                            style: TextStyle(fontSize: 11, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}