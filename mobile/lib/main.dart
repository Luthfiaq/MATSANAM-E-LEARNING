import 'package:flutter/material.dart';
import 'views/siswa/dashboard/dashboard_siswa_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matsanam Mobile',
      home: const DashboardSiswaPage(),
    );
  }
}