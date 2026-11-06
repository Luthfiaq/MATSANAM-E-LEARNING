import 'package:flutter/material.dart';

import '../../utils/constants.dart';

/// Ringkasan profil guru dari data autentikasi yang sudah disimpan saat login.
class GuruProfileSummaryCard extends StatelessWidget {
  const GuruProfileSummaryCard({super.key, required this.profileFuture});

  final Future<Map<String, dynamic>?> profileFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data ?? const <String, dynamic>{};
        final name = (profile['nama_lengkap'] ?? 'Guru Pengampu').toString();
        final nip = (profile['nip'] ?? '').toString();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.badge_outlined, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GURU PENGAMPU',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (nip.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text('NIP. $nip', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.tune_rounded, color: AppColors.textSecondary, size: 20),
            ],
          ),
        );
      },
    );
  }
}
