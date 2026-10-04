import 'package:flutter/material.dart';

import 'views/siswa/absensi/absensi_screen.dart';
import 'views/siswa/absensi/upload_surat_screen.dart';

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
      home: const AbsensiScreen(),
    );
  }
}