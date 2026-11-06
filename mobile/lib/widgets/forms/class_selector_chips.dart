import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ClassSelectorChips extends StatelessWidget {
  final List<Map<String, dynamic>> classes; // [{id: '9a', name: '9A', studentCount: 32}]
  final Set<String> selectedClassIds;
  final Function(String classId) onClassToggle;

  const ClassSelectorChips({
    Key? key,
    required this.classes,
    required this.selectedClassIds,
    required this.onClassToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimens.spacingSmall,
      runSpacing: AppDimens.spacingSmall,
      children: classes.map((classData) {
        final classId = classData['id']?.toString() ?? '';
        final className = classData['name']?.toString() ?? '';
        final studentCount = classData['studentCount'] ?? 0;
        final isSelected = selectedClassIds.contains(classId);

        return _buildChip(
          classId: classId,
          label: '$className ($studentCount Siswa)',
          isSelected: isSelected,
        );
      }).toList(),
    );
  }

  Widget _buildChip({
    required String classId,
    required String label,
    required bool isSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onClassToggle(classId),
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
        width: 1.5,
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
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
