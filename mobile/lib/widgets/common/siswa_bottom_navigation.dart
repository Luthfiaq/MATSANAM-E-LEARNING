import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class SiswaBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SiswaBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = <(IconData, String)>[
    (Icons.home_rounded, 'Beranda'),
    (Icons.menu_book_rounded, 'Materi'),
    (Icons.assignment_outlined, 'Tugas'),
    (Icons.bar_chart_rounded, 'Nilai'),
    (Icons.person_outline_rounded, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: .45)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(_items.length, (index) {
              final selected = index == currentIndex;
              final color = selected
                  ? AppColors.primary
                  : theme.colorScheme.onSurface.withValues(alpha: .6);
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_items[index].$1, size: 23, color: color),
                      const SizedBox(height: 3),
                      Text(
                        _items[index].$2,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
