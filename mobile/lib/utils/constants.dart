// ✅ BENAR
import 'package:flutter/material.dart';

class AppColors {
  // 1. Primary Color (Biru Utama Matsanam)
  static const Color primary = Color(0xFF2563EB); // Royal Blue untuk tombol utama, header, dan tab aktif
  static const Color primaryDark = Color(0xFF1D4ED8); // Shade lebih gelap untuk state hover/pressed
  static const Color primaryLight = Color(0xFFEFF6FF); // Background soft/chip biru muda

  // 2. Secondary / Accent Color (Satu nada pendukung & elemen khusus)
  static const Color secondary = Color(0xFF10B981); // Emerald Green (Digunakan pada aksi sukses/presensi)
  static const Color secondaryLight = Color(0xFFD1FAE5); // Soft Emerald untuk background badge/chip
  static const Color accentOrange = Color(0xFFC2410C); // Accent Oranye/Cokelat untuk media video

  // 3. Background Color (Latar Belakang Halaman)
  static const Color background = Color(0xFFF8FAFC); // Off-White / Slate 50 bersih

  // 4. Surface / Card Color (Container & Input Field)
  static const Color surface = Color(0xFFFFFFFF); // Putih bersih untuk Card, Modal, & Sheet

  // 5. Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900 untuk judul & teks utama
  static const Color textSecondary = Color(0xFF64748B); // Slate 500 untuk sub-judul, hint, & caption

  // 6. Border / Divider Color
  static const Color border = Color(0xFFE2E8F0); // Slate 200 untuk garis pemisah & border input

  // 7. Status Colors (Alerts, Badges, & Indicators)
  static const Color success = Color(0xFF059669); // Hijau untuk status "Tuntas", "Hadir", atau "Terima"
  static const Color successLight = Color(0xFFD1FAE5);

  static const Color warning = Color(0xFFD97706); // Kuning/Oranye untuk "Belum Dinilai" atau "Deadline Dekat"
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFDC2626); // Merah untuk "Terlambat", "Tolak", atau "Belum Kumpul"
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color info = Color(0xFF2563EB); // Biru Status
  static const Color infoLight = Color(0xFFDBEAFE);
}