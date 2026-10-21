import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class NilaiCard extends StatelessWidget {
  final String judulPenilaian; // Contoh: "Quiz 1 - Bilangan Berpangkat"
  final String tanggal; // Contoh: "12 Agt 2026"
  final String jenisInfo; // Contoh: "Bobot 15%"
  final double nilai;
  final double kkm;
  final bool isTuntas;
  final IconData leadingIcon;
  final VoidCallback? onTap;

  const NilaiCard({
    Key? key,
    required this.judulPenilaian,
    required this.tanggal,
    required this.jenisInfo,
    required this.nilai,
    required this.kkm,
    required this.isTuntas,
    this.leadingIcon = Icons.assignment_rounded,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusLabel = isTuntas ? 'Tuntas' : 'Remedi';
    final statusColor = isTuntas ? Colors.green.shade700 : Colors.red.shade700;
    final statusBgColor = isTuntas ? Colors.green.shade50 : Colors.red.shade50;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Indikator Jenis Penilaian
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    leadingIcon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Informasi Judul & Tanggal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        judulPenilaian,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            tanggal,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const Text(' • ', style: TextStyle(color: Colors.grey)),
                          Text(
                            jenisInfo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Nilai Angka & Status Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      nilai % 1 == 0 ? nilai.toInt().toString() : nilai.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}