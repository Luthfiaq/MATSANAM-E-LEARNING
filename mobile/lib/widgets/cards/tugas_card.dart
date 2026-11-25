import 'package:flutter/material.dart';

class TugasCard extends StatelessWidget {
  final String mapel;
  final String guru;
  final String judul;
  final bool prioritas;
  final bool deadlineMepet;
  final String deadline;
  final String statusDeadline;
  final Color statusColor;
  final VoidCallback onTap;

  const TugasCard({
    super.key,
    required this.mapel,
    required this.guru,
    required this.judul,
    required this.prioritas,
    required this.deadlineMepet,
    required this.deadline,
    required this.statusDeadline,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final neutralPanel = colors.surfaceContainerHighest;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .12 : .035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          if (prioritas)
            Container(
              height: 4,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.functions, size: 16, color: colors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '$mapel • $guru',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: dark ? .2 : .1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusDeadline,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    judul,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: deadlineMepet ? colors.error : colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        deadline,
                        style: TextStyle(
                          color: deadlineMepet ? colors.error : colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaPill(label: '🏆 Bobot: 10 Poin', color: neutralPanel, textColor: colors.onSurfaceVariant),
                      _MetaPill(label: '👤 Tugas Mandiri', color: neutralPanel, textColor: colors.onSurfaceVariant),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: neutralPanel,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Kerjakan latihan soal dan unggah foto jawaban dengan jelas sesuai instruksi guru.',
                    style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deadlineMepet ? colors.primary : colors.surface,
                      foregroundColor: deadlineMepet ? colors.onPrimary : colors.primary,
                      side: deadlineMepet ? BorderSide.none : BorderSide(color: colors.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      deadlineMepet
                          ? '🚀 Kumpulkan Tugas Sekarang'
                          : '📖 Buka & Kerjakan',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label, required this.color, required this.textColor});
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: TextStyle(fontSize: 12, color: textColor)),
  );
}
