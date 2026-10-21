import 'package:flutter/material.dart';
import '../../../models/nilai_model.dart';
import '../../../services/nilai_service.dart';
import '../../../widgets/cards/nilai_card.dart';
import '../../../utils/constants.dart';

class DetailNilaiScreen extends StatefulWidget {
  final int mapelId;
  final String namaMapel;

  const DetailNilaiScreen({
    Key? key,
    required this.mapelId,
    required this.namaMapel,
  }) : super(key: key);

  @override
  State<DetailNilaiScreen> createState() => _DetailNilaiScreenState();
}

class _DetailNilaiScreenState extends State<DetailNilaiScreen> {
  final NilaiService _nilaiService = NilaiService();
  late Future<List<NilaiModel>> _futureNilai;
  late Future<double> _futureRataRata;
  int _selectedTab = 0; // 0: Semua, 1: Tugas & PR, 2: Ujian & Quiz

  @override
  void initState() {
    super.initState();
    _futureNilai = _nilaiService.getNilaiByMapel(widget.mapelId);
    _futureRataRata = _nilaiService.getRataRataByMapel(widget.mapelId);
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
          'Detail Nilai Mapel & Rapor',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<NilaiModel>>(
        future: _futureNilai,
        builder: (context, snapshotNilai) {
          return FutureBuilder<double>(
            future: _futureRataRata,
            builder: (context, snapshotRata) {
              if (snapshotNilai.connectionState == ConnectionState.waiting ||
                  snapshotRata.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final listNilai = snapshotNilai.data ?? [];
              final rataRata = snapshotRata.data ?? 0.0;
              final kkm = listNilai.isNotEmpty ? listNilai.first.kkm : 75.0;
              final isTuntasRapor = rataRata >= kkm;

              // Filter berdasarkan Tab
              final filteredNilai = listNilai.where((item) {
                if (_selectedTab == 1) {
                  return item.jenisPenilaian.toLowerCase().contains('tugas') ||
                         item.jenisPenilaian.toLowerCase().contains('pr');
                } else if (_selectedTab == 2) {
                  return item.jenisPenilaian.toLowerCase().contains('quiz') ||
                         item.jenisPenilaian.toLowerCase().contains('ujian');
                }
                return true;
              }).toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header Info Mapel & Rapor Berjalan Card
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
                            const Text(
                              'KELAS 9A • Semester Ganjil',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.functions_rounded, color: AppColors.primary, size: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.namaMapel,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.school_rounded, size: 16, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text(
                                'Guru: Pak Imam Kholik, S.Pd',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Box Nilai Rapor Berjalan Biru
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'NILAI RAPOR BERJALAN',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        rataRata.toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      const Text(
                                        ' / 100',
                                        style: TextStyle(fontSize: 12, color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        isTuntasRapor ? Icons.check_circle_rounded : Icons.info_rounded,
                                        size: 14,
                                        color: Colors.greenAccent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isTuntasRapor ? 'Tuntas KKM (${kkm.toInt()})' : 'Belum Tuntas KKM (${kkm.toInt()})',
                                        style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: const [
                                    Text('PREDIKAT', style: TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 2),
                                    Text('A', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                    Text('Sangat Baik', style: TextStyle(fontSize: 9, color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tab Filter (Semua, Tugas & PR, Ujian & Quiz)
                  Row(
                    children: [
                      Expanded(child: _buildTabButton('Semua (${listNilai.length})', 0)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildTabButton('Tugas & PR', 1)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildTabButton('Ujian & Quiz', 2)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // List Item Nilai Cards
                  if (filteredNilai.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('Belum ada data nilai untuk kategori ini.')),
                    )
                  else
                    ...filteredNilai.map((item) {
                      return NilaiCard(
                        judulPenilaian: item.judulPenilaian,
                        tanggal: '${item.tanggal.day} ${_getMonthName(item.tanggal.month)} ${item.tanggal.year}',
                        jenisInfo: 'Bobot 20%',
                        nilai: item.nilai,
                        kkm: item.kkm,
                        isTuntas: item.statusLulus,
                        leadingIcon: item.jenisPenilaian.toLowerCase().contains('quiz')
                            ? Icons.quiz_rounded
                            : Icons.assignment_rounded,
                        onTap: () {
                          // Tampilkan Feedback Guru jika ada saat diklik
                          if (item.feedbackGuru != null) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(item.judulPenilaian),
                                content: Text('Feedback Guru:\n"${item.feedbackGuru}"'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Tutup'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      );
                    }).toList(),

                  const SizedBox(height: 12),

                  // Rata-rata & Catatan Guru Pengampu Card
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
                            Row(
                              children: const [
                                Icon(Icons.analytics_rounded, color: AppColors.primary, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Rata - Rata',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                            Text(
                              '${rataRata.toStringAsFixed(1)} / 100',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: rataRata / 100,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Catatan Guru Pengampu:',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '"Pemahaman konsep aljabar dan trigonometri sangat baik. Pertahankan ketelitian saat menyelesaikan soal bertingkat."',
                                      style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol Unduh Rincian Nilai Mapel PDF
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mengunduh Rincian Nilai Mapel PDF...')),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Unduh Rincian Nilai Mapel PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              );
            },
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
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

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }
}