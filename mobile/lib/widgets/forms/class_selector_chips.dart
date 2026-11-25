import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class ClassSelectorChips extends StatelessWidget {
  final List<Map<String, dynamic>> classes;
  final Set<String> selectedClassIds;
  final Function(String classId) onClassToggle;

  const ClassSelectorChips({
    super.key,
    required this.classes,
    required this.selectedClassIds,
    required this.onClassToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimens.spacingSmall,
      runSpacing: AppDimens.spacingSmall,
      children: classes.map((classData) {
        final classId = classData['id']?.toString() ?? '';
        final className = classData['name']?.toString() ?? '';
        final studentCount = classData['studentCount'] ?? 0;
        return _buildChip(
          context,
          classId: classId,
          label: '$className ($studentCount Siswa)',
          isSelected: selectedClassIds.contains(classId),
        );
      }).toList(),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String classId,
    required String label,
    required bool isSelected,
  }) {
    final colors = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onClassToggle(classId),
      selectedColor: colors.primary,
      checkmarkColor: colors.onPrimary,
      backgroundColor: colors.surface,
      side: BorderSide(
        color: isSelected ? colors.primary : colors.outlineVariant,
        width: 1.2,
      ),
      labelStyle: TextStyle(
        color: isSelected ? colors.onPrimary : colors.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spacingMedium,
        vertical: AppDimens.spacingSmall,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
      ),
    );
  }
}
