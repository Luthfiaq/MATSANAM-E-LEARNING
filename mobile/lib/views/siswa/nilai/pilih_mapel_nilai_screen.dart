import 'package:flutter/material.dart';
import '../../../services/nilai_service.dart';
import '../../../widgets/cards/mapel_card.dart';
import '../../../utils/constants.dart';
import 'detail_nilai_screen.dart';

class PilihMapelNilaiScreen extends StatefulWidget {
  const PilihMapelNilaiScreen({Key? key}) : super(key: key);

  @override
  State<PilihMapelNilaiScreen> createState() => _PilihMapelNilaiScreenState();
}

class _PilihMapelNilaiScreenState extends State<PilihMapelNilaiScreen> {
  final NilaiService _nilaiService = NilaiService();
  late Future<List<Map<String, dynamic>>> _futureMapelNilai;
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _futureMapelNilai = _nilaiService.getDaftarMapelNilai();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Nilai Pilih Mapel',
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
        future: _futureMapelNilai,
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Subtitle
                const Text(
                  'Matsanam E-Learning',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),

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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionChip(
                        label: const Text('Semua Mapel'),
                        backgroundColor: AppColors.primary,
                        labelStyle: const TextStyle(color: Colors.white),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        label: const Text('Semester Ganjil'),
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
                ),
                const SizedBox(height: 20),

                // Section Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pilih Mata Pelajaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${filteredMapel.length} Mapel Terdaftar',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Grid Mapel Cards (menggunakan shrinkWrap agar aman di dalam SingleChildScrollView)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredMapel.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final mapel = filteredMapel[index];
                    final mapelId = mapel['id'] as int;
                    final namaMapel = mapel['nama'] as String;
                    final rataRata = (mapel['rata_rata'] as double).toStringAsFixed(1);

                    return MapelCard(
                      namaMapel: namaMapel,
                      namaGuru: 'Guru Pengampu Mapel',
                      infoBadge: 'Rerata: $rataRata',
                      iconData: Icons.menu_book_rounded,
                      actionLabel: 'Lihat Nilai',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailNilaiScreen(
                              mapelId: mapelId,
                              namaMapel: namaMapel,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Banner Unduh Rapor / Rekap Nilai Semester
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.description_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Rekap Nilai Semester',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Semester Ganjil 2026/2027',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mengunduh PDF Rekap Nilai Semester...')),
                          );
                        },
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: const Text('Unduh PDF', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20), // Spasi ekstra di bagian bawah agar tidak mentok
              ],
            ),
          );
        },
      ),
    );
  }
}