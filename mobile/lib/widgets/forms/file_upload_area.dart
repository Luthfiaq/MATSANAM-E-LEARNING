import 'dart:io';

import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class FileUploadArea extends StatelessWidget {
  final List<File> files;
  final VoidCallback onPickFiles;
  final Function(int index) onRemoveFile;
  final String? hint;
  final List<String>? acceptedFormats;
  final int? maxSizeMB;
  final bool isLoading;

  const FileUploadArea({
    super.key,
    required this.files,
    required this.onPickFiles,
    required this.onRemoveFile,
    this.hint,
    this.acceptedFormats,
    this.maxSizeMB,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: isLoading ? null : onPickFiles,
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              border: Border.all(color: colors.outlineVariant, width: 1.5),
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
                    color: colors.primary,
                  ),
                const SizedBox(height: AppDimens.spacingMedium),
                Text(
                  hint ?? 'Sentuh atau Tarik Berkas ke Sini',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimens.spacingXSmall),
                Text(
                  _buildHintText(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        if (files.isNotEmpty) ...[
          const SizedBox(height: AppDimens.spacingMedium),
          ...files.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.spacingSmall),
              child: _buildFileCard(context, entry.value, entry.key),
            );
          }),
        ],
      ],
    );
  }

  String _buildHintText() {
    final formats = acceptedFormats?.join(', ').toUpperCase() ?? 'PDF, DOCX, PPTX';
    final size = maxSizeMB ?? 50;
    return 'Mendukung $formats (Maks $size MB)';
  }

  Widget _buildFileCard(BuildContext context, File file, int index) {
    final colors = Theme.of(context).colorScheme;
    final fileName = file.path.split('/').last;
    final fileExtension = fileName.split('.').last.toUpperCase();
    final fileSize = _getFileSizeString(file);
    final fileIcon = _getFileIcon(fileExtension);
    final fileColor = _getFileColor(fileExtension);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.spacingMedium),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: fileColor.withValues(alpha: dark ? .22 : .12),
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            ),
            child: Icon(fileIcon, color: fileColor, size: 20),
          ),
          const SizedBox(width: AppDimens.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      fileSize,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• Siap diunggah',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dark ? const Color(0xFF6EE7B7) : const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Hapus lampiran',
            onPressed: () => onRemoveFile(index),
            icon: Icon(
              Icons.delete_outline,
              color: colors.onSurfaceVariant,
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
        return const Color(0xFFDC2626);
      case 'doc':
      case 'docx':
        return const Color(0xFF2563EB);
      case 'ppt':
      case 'pptx':
        return const Color(0xFFD97706);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF059669);
      case 'jpg':
      case 'jpeg':
      case 'png':
        return const Color(0xFF9333EA);
      case 'mp4':
      case 'avi':
      case 'mov':
        return const Color(0xFFDB2777);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _getFileSizeString(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
