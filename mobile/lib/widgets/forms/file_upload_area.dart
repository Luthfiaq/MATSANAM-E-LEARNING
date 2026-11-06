import 'package:flutter/material.dart';
import 'dart:io';
import '../../utils/constants.dart';
import '../common/status_badge.dart';

class FileUploadArea extends StatelessWidget {
  final List<File> files;
  final VoidCallback onPickFiles;
  final Function(int index) onRemoveFile;
  final String? hint;
  final List<String>? acceptedFormats;
  final int? maxSizeMB;
  final bool isLoading;

  const FileUploadArea({
    Key? key,
    required this.files,
    required this.onPickFiles,
    required this.onRemoveFile,
    this.hint,
    this.acceptedFormats,
    this.maxSizeMB,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload Zone
        InkWell(
          onTap: isLoading ? null : onPickFiles,
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              border: Border.all(
                color: AppColors.border,
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                const SizedBox(height: AppDimens.spacingMedium),
                Text(
                  hint ?? 'Sentuh atau Tarik Berkas ke Sini',
                  style: AppTypography.labelLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimens.spacingXSmall),
                Text(
                  _buildHintText(),
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        
        // Files List
        if (files.isNotEmpty) ...[
          const SizedBox(height: AppDimens.spacingMedium),
          ...files.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.spacingSmall),
              child: _buildFileCard(file, index),
            );
          }).toList(),
        ],
      ],
    );
  }

  String _buildHintText() {
    final formats = acceptedFormats?.join(', ').toUpperCase() ?? 'PDF, DOCX, PPTX';
    final size = maxSizeMB ?? 50;
    return 'Mendukung $formats (Maks $size MB)';
  }

  Widget _buildFileCard(File file, int index) {
    final fileName = file.path.split('/').last;
    final fileExtension = fileName.split('.').last.toUpperCase();
    final fileSize = _getFileSizeString(file);
    final fileIcon = _getFileIcon(fileExtension);
    final fileColor = _getFileColor(fileExtension);

    return Container(
      padding: const EdgeInsets.all(AppDimens.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // File Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: fileColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            ),
            child: Icon(
              fileIcon,
              color: fileColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimens.spacingMedium),
          
          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      fileSize,
                      style: AppTypography.caption,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• Siap diunduh',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Delete Button
          IconButton(
            onPressed: () => onRemoveFile(index),
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.textMuted,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.purple;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Colors.pink;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getFileSizeString(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
