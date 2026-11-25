import 'package:flutter/material.dart';

/// Ringkasan profil guru dari data autentikasi yang disimpan saat login.
class GuruProfileSummaryCard extends StatelessWidget {
  const GuruProfileSummaryCard({super.key, required this.profileFuture});

  final Future<Map<String, dynamic>?> profileFuture;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FutureBuilder<Map<String, dynamic>?>(
      future: profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data ?? const <String, dynamic>{};
        final name = (profile['nama_lengkap'] ?? 'Guru Pengampu').toString();
        final nip = (profile['nip'] ?? '').toString();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.badge_outlined,
                  color: colors.onPrimaryContainer,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GURU PENGAMPU',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (nip.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'NIP. $nip',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.tune_rounded, color: colors.onSurfaceVariant, size: 20),
            ],
          ),
        );
      },
    );
  }
}
