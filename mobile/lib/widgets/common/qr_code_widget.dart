import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../utils/constants.dart';

class QRCodeWidget extends StatefulWidget {
  final String data;
  final double size;
  final bool showRefreshButton;
  final Future<String?> Function()? onRefresh;
  final String? instructionText;

  const QRCodeWidget({
    super.key,
    required this.data,
    this.size = 280,
    this.showRefreshButton = false,
    this.onRefresh,
    this.instructionText,
  });

  @override
  State<QRCodeWidget> createState() => _QRCodeWidgetState();
}

class _QRCodeWidgetState extends State<QRCodeWidget> {
  late String _data;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
  }

  @override
  void didUpdateWidget(covariant QRCodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) _data = widget.data;
  }

  Future<void> _refresh() async {
    if (_refreshing || widget.onRefresh == null) return;
    setState(() => _refreshing = true);
    try {
      final freshData = await widget.onRefresh!.call();
      if (!mounted) return;
      if (freshData != null && freshData.isNotEmpty) {
        setState(() => _data = freshData);
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: AppDimens.paddingLarge,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        border: Border.all(color: colors.outlineVariant, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .12 : .05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            padding: const EdgeInsets.all(AppDimens.spacingLarge),
            decoration: BoxDecoration(
              // QR remains white so it stays easy to scan in both themes.
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Center(child: _buildQRCode(colors)),
          ),
          if (widget.instructionText != null) ...[
            const SizedBox(height: AppDimens.spacingMedium),
            Text(
              widget.instructionText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (widget.showRefreshButton && widget.onRefresh != null) ...[
            const SizedBox(height: AppDimens.spacingMedium),
            OutlinedButton.icon(
              onPressed: _refreshing ? null : _refresh,
              icon: _refreshing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, size: 18),
              label: Text(
                _refreshing ? 'Memperbarui QR...' : 'Regenerate QR Code',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQRCode(ColorScheme colors) {
    if (_data.isEmpty) {
      return Container(
        width: widget.size - 32,
        height: widget.size - 32,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_2, size: 80, color: colors.onSurfaceVariant),
            const SizedBox(height: AppDimens.spacingMedium),
            Text(
              'No QR Data',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      );
    }
    return QrImageView(
      data: _data,
      version: QrVersions.auto,
      size: widget.size - 32,
      backgroundColor: Colors.white,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
      gapless: true,
    );
  }
}
