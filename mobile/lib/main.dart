import 'package:flutter/material.dart';

import 'views/siswa/absensi/absensi_screen.dart';
import 'views/siswa/absensi/upload_surat_screen.dart';
import 'views/siswa/materi/pilih_mapel_materi_screen.dart';
import 'views/siswa/nilai/pilih_mapel_nilai_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matsanam E-Learning',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
        useMaterial3: true,
      ),
      home: const PilihMapelNilaiScreen(),
    );
  }
}