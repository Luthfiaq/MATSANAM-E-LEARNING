import 'package:flutter/material.dart';

/// Logo MTsN 6 Nganjuk (assets/images/logo_mtsn6.png).
class SchoolLogo extends StatelessWidget {
  final double size;
  const SchoolLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_mtsn6.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        Icons.mosque_rounded,
        size: size * 0.7,
        color: const Color(0xFF059669),
      ),
    );
  }
}

/// Logo di dalam kartu putih bersudut membulat (onboarding & login).
class SchoolLogoCard extends StatelessWidget {
  final double size;
  const SchoolLogoCard({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.09),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SchoolLogo(size: size),
    );
  }
}
