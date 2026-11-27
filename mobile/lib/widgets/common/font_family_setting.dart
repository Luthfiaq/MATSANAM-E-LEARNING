import 'package:flutter/material.dart';

import '../../utils/app_theme_state.dart';

/// A shared font selector used by both Guru and Siswa settings screens.
/// The role-default option preserves the existing typography:
/// Guru = Inter, Siswa = Plus Jakarta Sans.
class FontFamilySetting extends StatelessWidget {
  const FontFamilySetting({
    super.key,
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  static const List<(String, String)> options = [
    ('role_default', 'Default sesuai peran'),
    ('Inter', 'Inter'),
    ('Plus Jakarta Sans', 'Plus Jakarta Sans'),
    ('Poppins', 'Poppins'),
    ('Roboto', 'Roboto'),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppThemeState.fontSelection,
      builder: (context, value, _) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final selected = options.any((option) => option.$1 == value)
            ? value
            : 'role_default';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Icons.text_fields_rounded,
                    color: colors.primary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Font aplikasi',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Berlaku untuk tampilan Guru dan Siswa.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selected,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Pilih jenis font',
                isDense: true,
              ),
              items: options
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option.$1,
                      child: Text(option.$2),
                    ),
                  )
                  .toList(),
              onChanged: (next) {
                if (next != null && next != selected) onChanged(next);
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Contoh tampilan: MATSANAM E-Learning',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              selected == 'role_default'
                  ? 'Default Guru: Inter • Default Siswa: Plus Jakarta Sans'
                  : 'Font $selected diterapkan pada kedua peran.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }
}
