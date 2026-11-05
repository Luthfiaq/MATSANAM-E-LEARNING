class DashboardSiswa {
  final String nama;
  final String nis;
  final String kelas;
  final String? periode;
  final String? hariIni;
  final int tugasAktif;
  final int? kehadiranPersen;
  final double? rerataNilai;
  final List<JadwalHariIni> jadwal;
  final int deadlineTotal;
  final List<DeadlineTugas> deadline;
  final List<MateriBaru> materi;

  const DashboardSiswa({
    required this.nama,
    required this.nis,
    required this.kelas,
    required this.periode,
    required this.hariIni,
    required this.tugasAktif,
    required this.kehadiranPersen,
    required this.rerataNilai,
    required this.jadwal,
    required this.deadlineTotal,
    required this.deadline,
    required this.materi,
  });

  String get namaPanggilan => nama.trim().split(RegExp(r'\s+')).first;

  /// Ada deadline kurang dari 24 jam -> titik merah di ikon lonceng.
  bool get adaNotifikasi =>
      deadline.any((d) => d.sisaMenit <= 24 * 60);

  factory DashboardSiswa.fromJson(Map<String, dynamic> j) {
    final siswa = (j['siswa'] ?? {}) as Map<String, dynamic>;
    final stats = (j['stats'] ?? {}) as Map<String, dynamic>;
    final dl = (j['deadline_tugas'] ?? {}) as Map<String, dynamic>;
    return DashboardSiswa(
      nama: (siswa['nama'] ?? '-').toString(),
      nis: (siswa['nis'] ?? '-').toString(),
      kelas: (siswa['kelas'] ?? '-').toString(),
      periode: j['periode']?.toString(),
      hariIni: j['hari_ini']?.toString(),
      tugasAktif: (stats['tugas_aktif'] ?? 0) as int,
      kehadiranPersen: stats['kehadiran_persen'] as int?,
      rerataNilai: (stats['rerata_nilai'] as num?)?.toDouble(),
      jadwal: ((j['jadwal_hari_ini'] ?? []) as List)
          .map((e) => JadwalHariIni.fromJson(e as Map<String, dynamic>))
          .toList(),
      deadlineTotal: (dl['total'] ?? 0) as int,
      deadline: ((dl['items'] ?? []) as List)
          .map((e) => DeadlineTugas.fromJson(e as Map<String, dynamic>))
          .toList(),
      materi: ((j['materi_baru'] ?? []) as List)
          .map((e) => MateriBaru.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class JadwalHariIni {
  final int id;
  final String mapel;
  final String guru;
  final String ruangan;
  final String jamMulai; // "HH:mm"
  final String jamSelesai;
  final String? statusAbsen; // hadir | izin | sakit | alpa | null

  const JadwalHariIni({
    required this.id,
    required this.mapel,
    required this.guru,
    required this.ruangan,
    required this.jamMulai,
    required this.jamSelesai,
    required this.statusAbsen,
  });

  factory JadwalHariIni.fromJson(Map<String, dynamic> j) => JadwalHariIni(
        id: j['id'] as int,
        mapel: (j['mapel'] ?? '-').toString(),
        guru: (j['guru'] ?? '-').toString(),
        ruangan: (j['ruangan'] ?? '-').toString(),
        jamMulai: (j['jam_mulai'] ?? '00:00').toString(),
        jamSelesai: (j['jam_selesai'] ?? '00:00').toString(),
        statusAbsen: j['status_absen']?.toString(),
      );

  static int _menit(String hhmm) {
    final p = hhmm.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  /// Toleransi presensi = 30 menit setelah jam mulai.
  String get batasToleransi {
    final m = _menit(jamMulai) + 30;
    final h = (m ~/ 60).toString().padLeft(2, '0');
    final mm = (m % 60).toString().padLeft(2, '0');
    return '$h:$mm';
  }

  /// Dihitung dari jam HP (WIB di perangkat siswa).
  JadwalFase faseSekarang(DateTime now) {
    final n = now.hour * 60 + now.minute;
    if (n < _menit(jamMulai)) return JadwalFase.akan;
    if (n < _menit(jamSelesai)) return JadwalFase.berlangsung;
    return JadwalFase.selesai;
  }

  bool get sudahAbsen => statusAbsen != null;
}

enum JadwalFase { akan, berlangsung, selesai }

class DeadlineTugas {
  final int id;
  final String judul;
  final String jenis;
  final String mapel;
  final DateTime deadline;
  final int sisaMenit;
  final int sudahKumpul;
  final int totalSiswa;
  final bool adaLampiran;

  const DeadlineTugas({
    required this.id,
    required this.judul,
    required this.jenis,
    required this.mapel,
    required this.deadline,
    required this.sisaMenit,
    required this.sudahKumpul,
    required this.totalSiswa,
    required this.adaLampiran,
  });

  factory DeadlineTugas.fromJson(Map<String, dynamic> j) => DeadlineTugas(
        id: j['id'] as int,
        judul: (j['judul'] ?? '-').toString(),
        jenis: (j['jenis'] ?? 'tugas').toString(),
        mapel: (j['mapel'] ?? '-').toString(),
        deadline: DateTime.parse(j['deadline'].toString()).toLocal(),
        sisaMenit: ((j['sisa_menit'] ?? 0) as num).toInt(),
        sudahKumpul: (j['sudah_kumpul'] ?? 0) as int,
        totalSiswa: (j['total_siswa'] ?? 0) as int,
        adaLampiran: (j['ada_lampiran'] ?? false) as bool,
      );

  double get progress =>
      totalSiswa == 0 ? 0 : (sudahKumpul / totalSiswa).clamp(0.0, 1.0);

  bool get mendesak => sisaMenit <= 24 * 60;

  /// "2 Jam Lagi!", "Besok, 23:59", "Jumat, 23:59"
  String get labelSisa {
    if (sisaMenit < 60) return '${sisaMenit < 1 ? 1 : sisaMenit} Menit Lagi!';
    if (sisaMenit < 24 * 60) return '${sisaMenit ~/ 60} Jam Lagi!';
    final jam =
        '${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}';
    final sekarang = DateTime.now();
    final selisihHari = DateTime(deadline.year, deadline.month, deadline.day)
        .difference(DateTime(sekarang.year, sekarang.month, sekarang.day))
        .inDays;
    if (selisihHari == 1) return 'Besok, $jam';
    const hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return '${hari[deadline.weekday - 1]}, $jam';
  }

  String get jenisLabel {
    switch (jenis) {
      case 'quiz':
        return 'Kuis';
      case 'uts':
        return 'UTS';
      case 'uas':
        return 'UAS';
      default:
        return 'Tugas';
    }
  }
}

class MateriBaru {
  final int id;
  final String judul;
  final String mapel;
  final String guru;
  final String ekstensi;

  const MateriBaru({
    required this.id,
    required this.judul,
    required this.mapel,
    required this.guru,
    required this.ekstensi,
  });

  factory MateriBaru.fromJson(Map<String, dynamic> j) => MateriBaru(
        id: j['id'] as int,
        judul: (j['judul'] ?? '-').toString(),
        mapel: (j['mapel'] ?? '-').toString(),
        guru: (j['guru'] ?? '-').toString(),
        ekstensi: (j['ekstensi'] ?? '').toString(),
      );
}
