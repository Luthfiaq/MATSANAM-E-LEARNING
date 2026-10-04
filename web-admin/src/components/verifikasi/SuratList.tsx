"use client";

import { useMemo, useState } from "react";
import type {
  PengajuanSurat,
  StatusVerifikasi,
  VerifikasiSurat,
} from "../../types/verifikasi";

type MainTab = "arsip" | "pending";
type ArchiveTab = "semua" | "disetujui" | "ditolak";

const initialArchiveData: VerifikasiSurat[] = [
  {
    id: 1,
    idBerkas: "VRF-2026-0901",
    sumber: "Via Portal Wali",
    namaSiswa: "Ahmad Fadhil Pratama",
    kelas: "9A",
    nisn: "009823145",
    inisial: "AF",
    jenisSurat: "Sakit Dokter",
    durasi: "3 Hari",
    tanggal: "24 - 26 Sep 2026",
    keterangan: "Dx: Infeksi Saluran Pernapasan",
    namaBerkas: "SK-Dokter_Fadhil.pdf",
    ukuranBerkas: "480 KB",
    sumberBerkas: "RS Mitra",
    waktuVerifikasi: "24 Sep 2026\n15:10 WIB",
    validator: "Ust. H. Ahmad Zulfikar",
    status: "Disetujui",
    catatan:
      "Surat dokter valid dan informasi tanggal izin sesuai dengan pengajuan.",
  },
  {
    id: 2,
    idBerkas: "VRF-2026-0902",
    sumber: "Via TU Loket",
    namaSiswa: "Nabila Rahma Azzahra",
    kelas: "8C",
    nisn: "009771209",
    inisial: "NR",
    jenisSurat: "Izin Kepentingan Keluarga",
    durasi: "2 Hari",
    tanggal: "22 - 23 Sep 2026",
    keterangan: "Keperluan: Takziah Kerabat Luar Kota",
    namaBerkas: "Surat_Wali_Nabila.jpg",
    ukuranBerkas: "1.2 MB",
    sumberBerkas: "TDP Basah",
    waktuVerifikasi: "22 Sep 2026\n08:40 WIB",
    validator: "Ust. H. Ahmad Zulfikar",
    status: "Disetujui",
    catatan:
      "Surat wali diterima dan alasan izin dinyatakan sesuai ketentuan.",
  },
  {
    id: 3,
    idBerkas: "VRF-2026-0903",
    sumber: "Via Portal Siswa",
    namaSiswa: "Dimas Arya Pratama",
    kelas: "9B",
    nisn: "009554311",
    inisial: "DA",
    jenisSurat: "Surat Keterangan Sakit",
    durasi: "1 Hari",
    tanggal: "20 Sep 2026",
    keterangan: "Pengirim: Klinik Pratama Sehat",
    namaBerkas: "Scan_Surat_Klinik.pdf",
    ukuranBerkas: "280 KB",
    sumberBerkas: "Rumah / Resubmission",
    waktuVerifikasi: "20 Sep 2026\n14:10 WIB",
    validator: "Hj. Siti Maemunah",
    status: "Ditolak",
    catatan:
      "Surat tidak dapat diverifikasi. Informasi klinik dan nomor surat tidak terbaca dengan jelas.",
  },
  {
    id: 4,
    idBerkas: "VRF-2026-0904",
    sumber: "Via Kemenag Prov.",
    namaSiswa: "Citra Dewi Lestari",
    kelas: "9A",
    nisn: "009419820",
    inisial: "CD",
    jenisSurat: "Dispensasi Lomba",
    durasi: "2 Hari",
    tanggal: "18 - 19 Sep 2026",
    keterangan: "Ajang: KSM Tingkat Provinsi DKI",
    namaBerkas: "Surat_Tugas_KSM.pdf",
    ukuranBerkas: "920 KB",
    sumberBerkas: "KSM Tingkat Provinsi DKI",
    waktuVerifikasi: "17 Sep 2026\n16:05 WIB",
    validator: "Ust. H. Ahmad Zulfikar",
    status: "Disetujui",
    catatan:
      "Surat tugas resmi diterima dan periode dispensasi sesuai dengan kegiatan.",
  },
  {
    id: 5,
    idBerkas: "VRF-2026-0905",
    sumber: "Via Portal Wali",
    namaSiswa: "Budi Santoso",
    kelas: "9B",
    nisn: "009214771",
    inisial: "BS",
    jenisSurat: "Sakit Puskesmas",
    durasi: "2 Hari",
    tanggal: "15 - 16 Sep 2026",
    keterangan: "Dx: Demam & Observasi Lab",
    namaBerkas: "Surat_Puskesmas.pdf",
    ukuranBerkas: "340 KB",
    sumberBerkas: "Puskesmas Pasar Rebo",
    waktuVerifikasi: "15 Sep 2026\n09:12 WIB",
    validator: "Ust. H. Ahmad Zulfikar",
    status: "Disetujui",
    catatan:
      "Surat puskesmas valid dan dapat digunakan sebagai bukti ketidakhadiran.",
  },
];

const initialPendingData: PengajuanSurat[] = [
  {
    id: 6,
    idBerkas: "VRF-2026-0910",
    namaSiswa: "Salsabila Putri",
    kelas: "8A",
    nisn: "009832101",
    inisial: "SP",
    jenisSurat: "Sakit Dokter",
    durasi: "2 Hari",
    tanggal: "01 - 02 Okt 2026",
    keterangan: "Demam dan perlu istirahat di rumah.",
    namaBerkas: "Surat_Dokter_Salsabila.pdf",
    ukuranBerkas: "420 KB",
    diajukanPada: "01 Okt 2026 • 07:32 WIB",
    sumberPengajuan: "Via Portal Wali",
    status: "Menunggu",
  },
  {
    id: 7,
    idBerkas: "VRF-2026-0911",
    namaSiswa: "Raka Maulana",
    kelas: "9C",
    nisn: "009834510",
    inisial: "RM",
    jenisSurat: "Izin Kepentingan Keluarga",
    durasi: "1 Hari",
    tanggal: "02 Okt 2026",
    keterangan: "Menghadiri acara keluarga di luar kota.",
    namaBerkas: "Surat_Wali_Raka.jpg",
    ukuranBerkas: "860 KB",
    diajukanPada: "02 Okt 2026 • 06:51 WIB",
    sumberPengajuan: "Via Portal Wali",
    status: "Menunggu",
  },
  {
    id: 8,
    idBerkas: "VRF-2026-0912",
    namaSiswa: "Nadia Fitria",
    kelas: "7B",
    nisn: "009811230",
    inisial: "NF",
    jenisSurat: "Dispensasi Madrasah",
    durasi: "2 Hari",
    tanggal: "03 - 04 Okt 2026",
    keterangan: "Mengikuti kegiatan resmi madrasah.",
    namaBerkas: "Surat_Tugas_Nadia.pdf",
    ukuranBerkas: "630 KB",
    diajukanPada: "03 Okt 2026 • 08:15 WIB",
    sumberPengajuan: "Via Guru",
    status: "Menunggu",
  },
];

function Icon({
  name,
  size = 18,
}: {
  name: string;
  size?: number;
}) {
  const common = {
    width: size,
    height: size,
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  switch (name) {
    case "search":
      return (
        <svg {...common}>
          <circle cx="11" cy="11" r="7" />
          <path d="m20 20-4-4" />
        </svg>
      );

    case "calendar":
      return (
        <svg {...common}>
          <rect x="3" y="4" width="18" height="17" rx="2" />
          <path d="M16 2v4M8 2v4M3 10h18" />
        </svg>
      );

    case "file":
      return (
        <svg {...common}>
          <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8Z" />
          <path d="M14 2v6h6M8 13h8M8 17h5" />
        </svg>
      );

    case "check":
      return (
        <svg {...common}>
          <circle cx="12" cy="12" r="9" />
          <path d="m8 12 2.5 2.5L16 9" />
        </svg>
      );

    case "x":
      return (
        <svg {...common}>
          <circle cx="12" cy="12" r="9" />
          <path d="m9 9 6 6M15 9l-6 6" />
        </svg>
      );

    case "download":
      return (
        <svg {...common}>
          <path d="M12 3v12M7 10l5 5 5-5M5 21h14" />
        </svg>
      );

    case "printer":
      return (
        <svg {...common}>
          <path d="M6 9V3h12v6M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2" />
          <path d="M6 14h12v7H6z" />
        </svg>
      );

    case "shield":
      return (
        <svg {...common}>
          <path d="M12 3 20 6v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z" />
          <path d="m9 12 2 2 4-4" />
        </svg>
      );

    case "eye":
      return (
        <svg {...common}>
          <path d="M2 12s3.5-6 10-6 10 6 10 6-3.5 6-10 6S2 12 2 12Z" />
          <circle cx="12" cy="12" r="2.5" />
        </svg>
      );

    case "chevron":
      return (
        <svg {...common}>
          <path d="m6 9 6 6 6-6" />
        </svg>
      );

    case "clock":
      return (
        <svg {...common}>
          <circle cx="12" cy="12" r="9" />
          <path d="M12 7v5l3 2" />
        </svg>
      );

    case "close":
      return (
        <svg {...common}>
          <path d="m6 6 12 12M18 6 6 18" />
        </svg>
      );

    case "user":
      return (
        <svg {...common}>
          <circle cx="12" cy="8" r="3.5" />
          <path d="M5 20c.8-3.2 3-5 7-5s6.2 1.8 7 5" />
        </svg>
      );

    case "menu":
      return (
        <svg {...common}>
          <path d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      );

    case "grid":
      return (
        <svg {...common}>
          <rect x="4" y="4" width="6" height="6" rx="1" />
          <rect x="14" y="4" width="6" height="6" rx="1" />
          <rect x="4" y="14" width="6" height="6" rx="1" />
          <rect x="14" y="14" width="6" height="6" rx="1" />
        </svg>
      );

    case "history":
      return (
        <svg {...common}>
          <path d="M3 12a9 9 0 1 0 3-6.7" />
          <path d="M3 4v5h5M12 7v5l3 2" />
        </svg>
      );

    case "settings":
      return (
        <svg {...common}>
          <path d="M12 8.5a3.5 3.5 0 1 0 0 7 3.5 3.5 0 0 0 0-7Z" />
          <path d="m19 13 .1-.9 2-1.5-2-3.5-2.3.7a8 8 0 0 0-1.6-.9L14.8 4h-5l-.4 2.9a8 8 0 0 0-1.6.9l-2.3-.7-2 3.5 2 1.5a8 8 0 0 0 0 1.8l-2 1.5 2 3.5 2.3-.7c.5.4 1 .7 1.6.9l.4 2.9h5l.4-2.9c.6-.2 1.1-.5 1.6-.9l2.3.7 2-3.5-2-1.5A8 8 0 0 0 19 13Z" />
        </svg>
      );

    case "users":
      return (
        <svg {...common}>
          <circle cx="9" cy="8" r="3" />
          <path d="M3 20c.6-3.3 2.5-5 6-5s5.4 1.7 6 5" />
          <path d="M16 5.5a3 3 0 0 1 0 5.8M18 15c1.8.8 2.8 2.3 3 5" />
        </svg>
      );

    default:
      return null;
  }
}

function StatCard({
  title,
  value,
  subtitle,
  type,
}: {
  title: string;
  value: string;
  subtitle: string;
  type: "total" | "success" | "danger";
}) {
  const styles = {
    total: {
      value: "text-slate-800",
      icon: "text-blue-600 bg-blue-50",
      line: "bg-blue-600",
      iconName: "file",
    },
    success: {
      value: "text-emerald-700",
      icon: "text-emerald-600 bg-emerald-50",
      line: "bg-emerald-600",
      iconName: "check",
    },
    danger: {
      value: "text-red-600",
      icon: "text-red-600 bg-red-50",
      line: "bg-red-600",
      iconName: "x",
    },
  }[type];

  return (
    <div className="relative overflow-hidden rounded-lg border border-slate-100 bg-white px-4 py-4 shadow-[0_1px_3px_rgba(15,23,42,0.04)]">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-[10px] font-medium uppercase tracking-[0.08em] text-slate-400">
            {title}
          </p>

          <p className={`mt-1 text-[27px] font-bold leading-none ${styles.value}`}>
            {value}
          </p>

          <p className="mt-4 text-[10px] text-slate-400">{subtitle}</p>
        </div>

        <div className={`rounded-lg p-3 ${styles.icon}`}>
          <Icon name={styles.iconName} size={20} />
        </div>
      </div>

      <div className={`absolute bottom-0 left-0 right-0 h-[3px] ${styles.line}`} />
    </div>
  );
}

function StatusBadge({ status }: { status: StatusVerifikasi }) {
  const approved = status === "Disetujui";

  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[10px] font-semibold ${
        approved
          ? "bg-emerald-100 text-emerald-700"
          : "bg-red-100 text-red-600"
      }`}
    >
      <span
        className={`flex h-3.5 w-3.5 items-center justify-center rounded-full ${
          approved ? "bg-emerald-500" : "bg-red-500"
        } text-white`}
      >
        <Icon name={approved ? "check" : "x"} size={9} />
      </span>
      {status}
    </span>
  );
}

function StudentAvatar({
  initials,
  variant,
}: {
  initials: string;
  variant: number;
}) {
  const colors = [
    "bg-blue-50 text-blue-700",
    "bg-emerald-50 text-emerald-700",
    "bg-red-50 text-red-600",
    "bg-blue-50 text-blue-700",
    "bg-indigo-50 text-indigo-700",
  ];

  return (
    <div
      className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-[11px] font-bold ${colors[variant % colors.length]}`}
    >
      {initials}
    </div>
  );
}

export default function SuratList() {
  const [mainTab, setMainTab] = useState<MainTab>("arsip");
  const [archiveTab, setArchiveTab] = useState<ArchiveTab>("semua");

  const [archiveData, setArchiveData] =
    useState<VerifikasiSurat[]>(initialArchiveData);

  const [pendingData, setPendingData] =
    useState<PengajuanSurat[]>(initialPendingData);

  const [search, setSearch] = useState("");
  const [kelas, setKelas] = useState("Semua Kelas (7, 8, 9)");
  const [jenis, setJenis] = useState("Semua Kategori");
  const [validator, setValidator] = useState("Semua Petugas Validator");

  const [selectedPending, setSelectedPending] =
    useState<PengajuanSurat | null>(null);

  const [showModal, setShowModal] = useState(false);
  const [modalMode, setModalMode] = useState<"approve" | "reject">("approve");
  const [rejectNote, setRejectNote] = useState("");

  const filteredArchive = useMemo(() => {
    const query = search.toLowerCase().trim();

    return archiveData.filter((item) => {
      const matchSearch =
        !query ||
        item.idBerkas.toLowerCase().includes(query) ||
        item.namaSiswa.toLowerCase().includes(query) ||
        item.nisn.toLowerCase().includes(query) ||
        item.namaBerkas.toLowerCase().includes(query);

      const matchKelas =
        kelas === "Semua Kelas (7, 8, 9)" || item.kelas === kelas;

      const matchJenis =
        jenis === "Semua Kategori" || item.jenisSurat === jenis;

      const matchValidator =
        validator === "Semua Petugas Validator" ||
        item.validator === validator;

      const matchStatus =
        archiveTab === "semua" ||
        (archiveTab === "disetujui" && item.status === "Disetujui") ||
        (archiveTab === "ditolak" && item.status === "Ditolak");

      return (
        matchSearch &&
        matchKelas &&
        matchJenis &&
        matchValidator &&
        matchStatus
      );
    });
  }, [archiveData, archiveTab, search, kelas, jenis, validator]);

  const totalProcessed = 142;
  const totalApproved = 128;
  const totalRejected = 14;

  const handleOpenVerification = (
    item: PengajuanSurat,
    mode: "approve" | "reject",
  ) => {
    setSelectedPending(item);
    setModalMode(mode);
    setRejectNote("");
    setShowModal(true);
  };

  const handleVerification = () => {
    if (!selectedPending) return;

    if (modalMode === "approve") {
      const approved: VerifikasiSurat = {
        id: selectedPending.id,
        idBerkas: selectedPending.idBerkas,
        sumber: selectedPending.sumberPengajuan,
        namaSiswa: selectedPending.namaSiswa,
        kelas: selectedPending.kelas,
        nisn: selectedPending.nisn,
        inisial: selectedPending.inisial,
        jenisSurat: selectedPending.jenisSurat,
        durasi: selectedPending.durasi,
        tanggal: selectedPending.tanggal,
        keterangan: selectedPending.keterangan,
        namaBerkas: selectedPending.namaBerkas,
        ukuranBerkas: selectedPending.ukuranBerkas,
        sumberBerkas: "Dokumen Pengajuan",
        waktuVerifikasi: "04 Okt 2026\n17:09 WIB",
        validator: "Ust. H. Ahmad Zulfikar",
        status: "Disetujui",
        catatan: "Pengajuan telah diverifikasi dan dinyatakan sah.",
      };

      setArchiveData((prev) => [approved, ...prev]);

      setPendingData((prev) =>
        prev.filter((item) => item.id !== selectedPending.id),
      );
    } else {
      const rejected: VerifikasiSurat = {
        id: selectedPending.id,
        idBerkas: selectedPending.idBerkas,
        sumber: selectedPending.sumberPengajuan,
        namaSiswa: selectedPending.namaSiswa,
        kelas: selectedPending.kelas,
        nisn: selectedPending.nisn,
        inisial: selectedPending.inisial,
        jenisSurat: selectedPending.jenisSurat,
        durasi: selectedPending.durasi,
        tanggal: selectedPending.tanggal,
        keterangan: selectedPending.keterangan,
        namaBerkas: selectedPending.namaBerkas,
        ukuranBerkas: selectedPending.ukuranBerkas,
        sumberBerkas: "Dokumen Pengajuan",
        waktuVerifikasi: "04 Okt 2026\n17:09 WIB",
        validator: "Ust. H. Ahmad Zulfikar",
        status: "Ditolak",
        catatan:
          rejectNote.trim() ||
          "Pengajuan ditolak oleh validator berdasarkan hasil verifikasi.",
      };

      setArchiveData((prev) => [rejected, ...prev]);

      setPendingData((prev) =>
        prev.filter((item) => item.id !== selectedPending.id),
      );
    }

    setShowModal(false);
    setSelectedPending(null);
  };

  const handlePrint = () => {
    window.print();
  };

  const handleExport = () => {
    const headers = [
      "ID Berkas",
      "Nama Siswa",
      "Kelas",
      "NISN",
      "Jenis Surat",
      "Durasi",
      "Tanggal",
      "Status",
      "Validator",
    ];

    const rows = filteredArchive.map((item) => [
      item.idBerkas,
      item.namaSiswa,
      item.kelas,
      item.nisn,
      item.jenisSurat,
      item.durasi,
      item.tanggal,
      item.status,
      item.validator,
    ]);

    const csv = [
      headers.join(","),
      ...rows.map((row) =>
        row
          .map((value) => `"${String(value).replace(/"/g, '""')}"`)
          .join(","),
      ),
    ].join("\n");

    const blob = new Blob([csv], {
      type: "text/csv;charset=utf-8;",
    });

    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");

    link.href = url;
    link.download = "histori-verifikasi-absensi.csv";
    link.click();

    URL.revokeObjectURL(url);
  };

  return (
    <>
      <div className="space-y-4">
        {/* STATISTICS */}
        <div className="grid grid-cols-1 gap-3 md:grid-cols-3">
          <StatCard
            title="Total Surat Diproses"
            value={String(totalProcessed)}
            subtitle="Semester Ganjil berjalan"
            type="total"
          />

          <StatCard
            title="Disetujui / Sah"
            value={String(totalApproved)}
            subtitle="128 berkas sah"
            type="success"
          />

          <StatCard
            title="Ditolak / Gugur"
            value={String(totalRejected)}
            subtitle="14 berkas tidak sah"
            type="danger"
          />
        </div>

        {/* MAIN TAB */}
        <div className="rounded-lg border border-slate-100 bg-white shadow-[0_1px_3px_rgba(15,23,42,0.04)]">
          <div className="flex items-center justify-between border-b border-slate-100 px-4 pt-3">
            <div className="flex gap-5">
              <button
                onClick={() => setMainTab("arsip")}
                className={`relative pb-3 text-xs font-semibold ${
                  mainTab === "arsip"
                    ? "text-blue-600"
                    : "text-slate-500 hover:text-slate-700"
                }`}
              >
                Histori Arsip
                {mainTab === "arsip" && (
                  <span className="absolute bottom-0 left-0 right-0 h-0.5 rounded-full bg-blue-600" />
                )}
              </button>

              <button
                onClick={() => setMainTab("pending")}
                className={`relative flex items-center gap-2 pb-3 text-xs font-semibold ${
                  mainTab === "pending"
                    ? "text-blue-600"
                    : "text-slate-500 hover:text-slate-700"
                }`}
              >
                Pengajuan Masuk
                <span className="rounded-full bg-red-500 px-1.5 py-0.5 text-[9px] font-bold text-white">
                  {pendingData.length}
                </span>

                {mainTab === "pending" && (
                  <span className="absolute bottom-0 left-0 right-0 h-0.5 rounded-full bg-blue-600" />
                )}
              </button>
            </div>
          </div>

          {mainTab === "arsip" ? (
            <div>
              {/* SEARCH + ACTION */}
              <div className="flex flex-col gap-3 border-b border-slate-100 p-4 lg:flex-row lg:items-center">
                <div className="relative flex-1">
                  <span className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">
                    <Icon name="search" size={16} />
                  </span>

                  <input
                    value={search}
                    onChange={(event) => setSearch(event.target.value)}
                    placeholder="Cari ID berkas, nama siswa, NISN, atau instansi dokter..."
                    className="h-9 w-full rounded-md border border-slate-200 bg-slate-50 pl-9 pr-3 text-[11px] text-slate-700 outline-none transition focus:border-blue-400 focus:bg-white focus:ring-2 focus:ring-blue-50"
                  />
                </div>

                <div className="flex gap-2">
                  <button
                    onClick={handlePrint}
                    className="flex h-9 items-center gap-2 rounded-md border border-slate-200 bg-white px-3 text-[11px] font-semibold text-slate-600 hover:bg-slate-50"
                  >
                    <Icon name="printer" size={15} />
                    Cetak Arsip
                  </button>

                  <button
                    onClick={handleExport}
                    className="flex h-9 items-center gap-2 rounded-md bg-blue-600 px-3 text-[11px] font-semibold text-white shadow-sm hover:bg-blue-700"
                  >
                    <Icon name="download" size={15} />
                    Ekspor Log (.xlsx)
                  </button>
                </div>
              </div>

              {/* FILTER */}
              <div className="grid grid-cols-1 gap-2 border-b border-slate-100 p-4 md:grid-cols-2 xl:grid-cols-4">
                <div>
                  <label className="mb-1 block text-[9px] font-semibold uppercase tracking-wide text-slate-400">
                    Tingkat / Kelas
                  </label>

                  <div className="relative">
                    <select
                      value={kelas}
                      onChange={(event) => setKelas(event.target.value)}
                      className="h-9 w-full appearance-none rounded-md border border-slate-200 bg-slate-50 px-3 text-[11px] text-slate-600 outline-none focus:border-blue-400"
                    >
                      <option>Semua Kelas (7, 8, 9)</option>
                      <option>7A</option>
                      <option>7B</option>
                      <option>8A</option>
                      <option>8C</option>
                      <option>9A</option>
                      <option>9B</option>
                      <option>9C</option>
                    </select>

                    <span className="pointer-events-none absolute right-2 top-1/2 -translate-y-1/2 text-slate-400">
                      <Icon name="chevron" size={13} />
                    </span>
                  </div>
                </div>

                <div>
                  <label className="mb-1 block text-[9px] font-semibold uppercase tracking-wide text-slate-400">
                    Jenis Surat
                  </label>

                  <div className="relative">
                    <select
                      value={jenis}
                      onChange={(event) => setJenis(event.target.value)}
                      className="h-9 w-full appearance-none rounded-md border border-slate-200 bg-slate-50 px-3 text-[11px] text-slate-600 outline-none focus:border-blue-400"
                    >
                      <option>Semua Kategori</option>
                      <option>Sakit Dokter</option>
                      <option>Izin Kepentingan Keluarga</option>
                      <option>Surat Keterangan Sakit</option>
                      <option>Dispensasi Lomba</option>
                      <option>Sakit Puskesmas</option>
                      <option>Dispensasi Madrasah</option>
                    </select>

                    <span className="pointer-events-none absolute right-2 top-1/2 -translate-y-1/2 text-slate-400">
                      <Icon name="chevron" size={13} />
                    </span>
                  </div>
                </div>

                <div>
                  <label className="mb-1 block text-[9px] font-semibold uppercase tracking-wide text-slate-400">
                    Periode Tanggal Proses
                  </label>

                  <div className="flex h-9 items-center gap-2 rounded-md border border-slate-200 bg-slate-50 px-3 text-[11px] text-slate-600">
                    <Icon name="calendar" size={14} />
                    <span>01 Sep 2026 - 30 Sep 2026</span>
                  </div>
                </div>

                <div>
                  <label className="mb-1 block text-[9px] font-semibold uppercase tracking-wide text-slate-400">
                    Validator TU
                  </label>

                  <div className="relative">
                    <select
                      value={validator}
                      onChange={(event) => setValidator(event.target.value)}
                      className="h-9 w-full appearance-none rounded-md border border-slate-200 bg-slate-50 px-3 text-[11px] text-slate-600 outline-none focus:border-blue-400"
                    >
                      <option>Semua Petugas Validator</option>
                      <option>Ust. H. Ahmad Zulfikar</option>
                      <option>Hj. Siti Maemunah</option>
                    </select>

                    <span className="pointer-events-none absolute right-2 top-1/2 -translate-y-1/2 text-slate-400">
                      <Icon name="chevron" size={13} />
                    </span>
                  </div>
                </div>
              </div>

              {/* ARCHIVE TABS */}
              <div className="flex items-center justify-between border-b border-slate-100 px-4">
                <div className="flex">
                  <button
                    onClick={() => setArchiveTab("semua")}
                    className={`border-b-2 px-4 py-3 text-[11px] font-semibold ${
                      archiveTab === "semua"
                        ? "border-blue-600 text-slate-800"
                        : "border-transparent text-slate-400"
                    }`}
                  >
                    Semua Arsip
                    <span className="ml-1 text-slate-400">(142)</span>
                  </button>

                  <button
                    onClick={() => setArchiveTab("disetujui")}
                    className={`border-b-2 px-4 py-3 text-[11px] font-semibold ${
                      archiveTab === "disetujui"
                        ? "border-blue-600 text-slate-800"
                        : "border-transparent text-slate-400"
                    }`}
                  >
                    Disetujui
                    <span className="ml-1 text-emerald-600">(128)</span>
                  </button>

                  <button
                    onClick={() => setArchiveTab("ditolak")}
                    className={`border-b-2 px-4 py-3 text-[11px] font-semibold ${
                      archiveTab === "ditolak"
                        ? "border-blue-600 text-slate-800"
                        : "border-transparent text-slate-400"
                    }`}
                  >
                    Ditolak
                    <span className="ml-1 text-red-600">(14)</span>
                  </button>
                </div>
              </div>

              {/* TABLE */}
              <div className="overflow-x-auto">
                <table className="min-w-[1100px] w-full text-left">
                  <thead>
                    <tr className="bg-[#f4f6ff]">
                      <th className="w-[130px] px-4 py-3 text-[9px] font-bold uppercase tracking-wide text-slate-500">
                        No & ID Berkas
                      </th>

                      <th className="w-[220px] px-4 py-3 text-[9px] font-bold uppercase tracking-wide text-slate-500">
                        Siswa & Rombel
                      </th>

                      <th className="w-[210px] px-4 py-3 text-[9px] font-bold uppercase tracking-wide text-slate-500">
                        Jenis & Durasi Izin
                      </th>

                      <th className="w-[210px] px-4 py-3 text-[9px] font-bold uppercase tracking-wide text-slate-500">
                        Berkas Terlampir
                      </th>

                      <th className="w-[150px] px-4 py-3 text-[9px] font-bold uppercase tracking-wide text-slate-500">
                        Waktu Verifikasi
                      </th>

                      <th className="w-[130px] px-4 py-3 text-[9px] font-bold uppercase tracking-wide text-slate-500">
                        Status Keputusan
                      </th>

                      <th className="w-[230px] px-4 py-3 text-[9px] font-bold uppercase tracking-wide text-slate-500">
                        Catatan
                      </th>
                    </tr>
                  </thead>

                  <tbody className="divide-y divide-slate-100">
                    {filteredArchive.map((item, index) => (
                      <tr
                        key={item.idBerkas}
                        className="hover:bg-slate-50/70"
                      >
                        <td className="px-4 py-4 align-top">
                          <p className="text-[12px] font-bold text-slate-700">
                            #{index + 1}
                          </p>

                          <p className="mt-1 text-[10px] font-bold text-red-500">
                            {item.idBerkas}
                          </p>

                          <p className="mt-1 text-[9px] text-slate-400">
                            {item.sumber}
                          </p>
                        </td>

                        <td className="px-4 py-4 align-top">
                          <div className="flex gap-2">
                            <StudentAvatar
                              initials={item.inisial}
                              variant={index}
                            />

                            <div>
                              <p className="text-[11px] font-bold text-slate-700">
                                {item.namaSiswa}
                              </p>

                              <div className="mt-1 flex items-center gap-2">
                                <span className="rounded-sm bg-indigo-50 px-1.5 py-1 text-[9px] font-bold text-indigo-600">
                                  Kelas {item.kelas}
                                </span>

                                <span className="text-[9px] text-slate-400">
                                  NISN: {item.nisn}
                                </span>
                              </div>
                            </div>
                          </div>
                        </td>

                        <td className="px-4 py-4 align-top">
                          <div className="flex gap-2">
                            <span
                              className={`mt-0.5 flex h-4 w-4 shrink-0 items-center justify-center rounded ${
                                item.status === "Disetujui"
                                  ? "bg-red-50 text-red-500"
                                  : "bg-red-50 text-red-500"
                              }`}
                            >
                              <Icon name="file" size={10} />
                            </span>

                            <div>
                              <p className="text-[10px] font-bold text-slate-700">
                                {item.jenisSurat}
                              </p>

                              <p className="mt-1 text-[9px] text-slate-500">
                                {item.durasi} ({item.tanggal})
                              </p>

                              <p className="mt-1 max-w-[170px] text-[9px] leading-4 text-slate-400">
                                {item.keterangan}
                              </p>
                            </div>
                          </div>
                        </td>

                        <td className="px-4 py-4 align-top">
                          <div className="rounded-md bg-indigo-50/70 p-2">
                            <div className="flex items-center gap-2">
                              <span className="flex h-7 w-7 shrink-0 items-center justify-center rounded bg-white text-red-500 shadow-sm">
                                <Icon name="file" size={14} />
                              </span>

                              <div className="min-w-0">
                                <p className="truncate text-[9px] font-bold text-blue-600">
                                  {item.namaBerkas}
                                </p>

                                <p className="mt-0.5 text-[8px] text-slate-400">
                                  {item.ukuranBerkas} • {item.sumberBerkas}
                                </p>
                              </div>
                            </div>
                          </div>
                        </td>

                        <td className="px-4 py-4 align-top">
                          <div className="whitespace-pre-line text-[9px] leading-4 text-slate-600">
                            {item.waktuVerifikasi}
                          </div>

                          <p className="mt-1 text-[9px] text-slate-400">
                            Oleh: {item.validator}
                          </p>
                        </td>

                        <td className="px-4 py-4 align-top">
                          <StatusBadge status={item.status} />
                        </td>

                        <td className="px-4 py-4 align-top">
                          <div
                            className={`rounded-md p-2 text-[9px] leading-4 ${
                              item.status === "Ditolak"
                                ? "bg-red-50 text-red-600"
                                : "bg-slate-50 text-slate-500"
                            }`}
                          >
                            {item.catatan}
                          </div>
                        </td>
                      </tr>
                    ))}

                    {filteredArchive.length === 0 && (
                      <tr>
                        <td
                          colSpan={7}
                          className="px-4 py-12 text-center text-xs text-slate-400"
                        >
                          Tidak ada arsip yang sesuai dengan filter.
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>

              {/* PAGINATION */}
              <div className="flex flex-col gap-3 border-t border-slate-100 px-4 py-3 sm:flex-row sm:items-center sm:justify-between">
                <div className="text-[9px] text-slate-400">
                  Menampilkan per halaman:
                  <span className="ml-2 rounded bg-indigo-50 px-3 py-1 font-semibold text-slate-600">
                    5 baris
                  </span>

                  <span className="ml-3">
                    Menampilkan 1 - {Math.min(filteredArchive.length, 5)} dari{" "}
                    {totalProcessed} berkas
                  </span>
                </div>

                <div className="flex items-center gap-1">
                  <button className="px-2 text-slate-400">&laquo;</button>
                  <button className="px-2 text-slate-400">&lsaquo;</button>

                  <button className="flex h-7 w-7 items-center justify-center rounded bg-blue-600 text-[10px] font-bold text-white">
                    1
                  </button>

                  <button className="flex h-7 w-7 items-center justify-center text-[10px] text-slate-500">
                    2
                  </button>

                  <button className="flex h-7 w-7 items-center justify-center text-[10px] text-slate-500">
                    3
                  </button>

                  <span className="px-1 text-[10px] text-slate-400">...</span>

                  <button className="flex h-7 w-7 items-center justify-center text-[10px] text-slate-500">
                    29
                  </button>

                  <button className="px-2 text-slate-400">&rsaquo;</button>
                  <button className="px-2 text-slate-400">&raquo;</button>
                </div>
              </div>
            </div>
          ) : (
            /* PENDING */
            <div>
              <div className="flex flex-col gap-2 border-b border-slate-100 px-4 py-4 sm:flex-row sm:items-center sm:justify-between">
                <div>
                  <h3 className="text-sm font-bold text-slate-800">
                    Pengajuan Surat Masuk
                  </h3>
                  <p className="mt-1 text-[10px] text-slate-400">
                    Tinjau dan verifikasi surat absensi yang belum diproses.
                  </p>
                </div>

                <span className="w-fit rounded-full bg-amber-50 px-3 py-1.5 text-[10px] font-semibold text-amber-600">
                  {pendingData.length} pengajuan menunggu verifikasi
                </span>
              </div>

              <div className="overflow-x-auto">
                <table className="min-w-[1050px] w-full text-left">
                  <thead>
                    <tr className="bg-[#f4f6ff]">
                      <th className="px-4 py-3 text-[9px] font-bold uppercase tracking-wide text-slate-500">
                        ID Berkas
                      </th>

                      <th className="px-4 py-3 text-[9px] font-bold uppercase tracking-wide text-slate-500">
                        Siswa & Rombel
                      </th>

                      <th className="px-4 py-3 text-[9px] font-bold uppercase tracking-wide text-slate-500">
                        Jenis & Durasi
                      </th>

                      <th className="px-4 py-3 text-[9px] font-bold uppercase tracking-wide text-slate-500">
                        Berkas
                      </th>

                      <th className="px-4 py-3 text-[9px] font-bold uppercase tracking-wide text-slate-500">
                        Diajukan
                      </th>

                      <th className="px-4 py-3 text-[9px] font-bold uppercase tracking-wide text-slate-500">
                        Status
                      </th>

                      <th className="px-4 py-3 text-[9px] font-bold uppercase tracking-wide text-slate-500">
                        Aksi
                      </th>
                    </tr>
                  </thead>

                  <tbody className="divide-y divide-slate-100">
                    {pendingData.map((item, index) => (
                      <tr
                        key={item.idBerkas}
                        className="hover:bg-slate-50/70"
                      >
                        <td className="px-4 py-4 align-top">
                          <p className="text-[10px] font-bold text-red-500">
                            {item.idBerkas}
                          </p>
                          <p className="mt-1 text-[9px] text-slate-400">
                            {item.sumberPengajuan}
                          </p>
                        </td>

                        <td className="px-4 py-4 align-top">
                          <div className="flex gap-2">
                            <StudentAvatar
                              initials={item.inisial}
                              variant={index + 2}
                            />

                            <div>
                              <p className="text-[11px] font-bold text-slate-700">
                                {item.namaSiswa}
                              </p>

                              <div className="mt-1 flex gap-2">
                                <span className="rounded-sm bg-indigo-50 px-1.5 py-1 text-[9px] font-semibold text-indigo-600">
                                  Kelas {item.kelas}
                                </span>

                                <span className="text-[9px] text-slate-400">
                                  {item.nisn}
                                </span>
                              </div>
                            </div>
                          </div>
                        </td>

                        <td className="px-4 py-4 align-top">
                          <p className="text-[10px] font-bold text-slate-700">
                            {item.jenisSurat}
                          </p>

                          <p className="mt-1 text-[9px] text-slate-400">
                            {item.durasi} • {item.tanggal}
                          </p>

                          <p className="mt-1 max-w-[220px] text-[9px] leading-4 text-slate-400">
                            {item.keterangan}
                          </p>
                        </td>

                        <td className="px-4 py-4 align-top">
                          <div className="flex items-center gap-2 rounded-md bg-indigo-50 p-2">
                            <span className="flex h-7 w-7 shrink-0 items-center justify-center rounded bg-white text-red-500">
                              <Icon name="file" size={14} />
                            </span>

                            <div>
                              <p className="max-w-[150px] truncate text-[9px] font-semibold text-blue-600">
                                {item.namaBerkas}
                              </p>
                              <p className="text-[8px] text-slate-400">
                                {item.ukuranBerkas}
                              </p>
                            </div>
                          </div>
                        </td>

                        <td className="px-4 py-4 align-top text-[9px] leading-4 text-slate-500">
                          {item.diajukanPada}
                        </td>

                        <td className="px-4 py-4 align-top">
                          <span className="inline-flex items-center gap-1.5 rounded-full bg-amber-100 px-2.5 py-1 text-[10px] font-semibold text-amber-700">
                            <Icon name="clock" size={11} />
                            Menunggu
                          </span>
                        </td>

                        <td className="px-4 py-4 align-top">
                          <div className="flex gap-1.5">
                            <button
                              onClick={() => handleOpenVerification(item, "approve")}
                              className="rounded-md bg-emerald-600 px-2.5 py-1.5 text-[9px] font-bold text-white hover:bg-emerald-700"
                            >
                              ACC
                            </button>

                            <button
                              onClick={() => handleOpenVerification(item, "reject")}
                              className="rounded-md bg-red-50 px-2.5 py-1.5 text-[9px] font-bold text-red-600 hover:bg-red-100"
                            >
                              Tolak
                            </button>

                            <button
                              onClick={() => {
                                setSelectedPending(item);
                                setModalMode("approve");
                                setRejectNote("");
                                setShowModal(true);
                              }}
                              className="flex h-7 w-7 items-center justify-center rounded-md border border-slate-200 text-slate-500 hover:bg-slate-50"
                              title="Lihat detail"
                            >
                              <Icon name="eye" size={13} />
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}

                    {pendingData.length === 0 && (
                      <tr>
                        <td
                          colSpan={7}
                          className="px-4 py-14 text-center"
                        >
                          <div className="mx-auto flex h-10 w-10 items-center justify-center rounded-full bg-emerald-50 text-emerald-600">
                            <Icon name="check" size={20} />
                          </div>

                          <p className="mt-3 text-xs font-semibold text-slate-700">
                            Semua pengajuan sudah diverifikasi
                          </p>

                          <p className="mt-1 text-[10px] text-slate-400">
                            Tidak ada surat yang menunggu pemeriksaan.
                          </p>
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </div>

        {/* AUDIT FOOTER */}
        <div className="flex items-center gap-3 rounded-lg border border-emerald-100 bg-white px-4 py-3 shadow-[0_1px_3px_rgba(15,23,42,0.03)]">
          <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-md bg-emerald-100 text-emerald-600">
            <Icon name="shield" size={18} />
          </div>

          <div className="min-w-0 flex-1">
            <p className="text-[11px] font-bold text-slate-700">
              Integritas Log Verifikasi Digital Kesiswaan Matsanam
            </p>

            <p className="mt-0.5 text-[9px] text-slate-400">
              Setiap perubahan status surat absensi tercatat permanen pada sistem
              audit trail madrasah sesuai Kepdirjen Pendis Kemenag RI.
            </p>
          </div>

          <div className="hidden items-center gap-1.5 text-[9px] font-semibold text-emerald-600 sm:flex">
            <Icon name="shield" size={13} />
            Enkripsi SHA-256 Terverifikasi
          </div>
        </div>
      </div>

      {/* MODAL VERIFIKASI */}
      {showModal && selectedPending && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center bg-slate-950/40 p-4 backdrop-blur-[2px]">
          <div className="w-full max-w-xl overflow-hidden rounded-xl bg-white shadow-2xl">
            {/* MODAL HEADER */}
            <div className="flex items-start justify-between border-b border-slate-100 px-5 py-4">
              <div>
                <p className="text-[9px] font-bold uppercase tracking-wider text-blue-600">
                  Verifikasi Surat Absensi
                </p>

                <h3 className="mt-1 text-base font-bold text-slate-800">
                  {selectedPending.namaSiswa}
                </h3>

                <p className="mt-1 text-[10px] text-slate-400">
                  {selectedPending.idBerkas} • Kelas {selectedPending.kelas}
                </p>
              </div>

              <button
                onClick={() => setShowModal(false)}
                className="flex h-8 w-8 items-center justify-center rounded-md text-slate-400 hover:bg-slate-100 hover:text-slate-600"
              >
                <Icon name="close" size={18} />
              </button>
            </div>

            {/* MODAL BODY */}
            <div className="max-h-[65vh] overflow-y-auto px-5 py-5">
              <div className="grid gap-3 sm:grid-cols-2">
                <div className="rounded-lg border border-slate-100 bg-slate-50 p-3">
                  <p className="text-[9px] font-semibold uppercase text-slate-400">
                    Jenis Surat
                  </p>

                  <p className="mt-1 text-xs font-bold text-slate-700">
                    {selectedPending.jenisSurat}
                  </p>
                </div>

                <div className="rounded-lg border border-slate-100 bg-slate-50 p-3">
                  <p className="text-[9px] font-semibold uppercase text-slate-400">
                    Durasi
                  </p>

                  <p className="mt-1 text-xs font-bold text-slate-700">
                    {selectedPending.durasi}
                  </p>
                </div>

                <div className="rounded-lg border border-slate-100 bg-slate-50 p-3">
                  <p className="text-[9px] font-semibold uppercase text-slate-400">
                    Tanggal
                  </p>

                  <p className="mt-1 text-xs font-bold text-slate-700">
                    {selectedPending.tanggal}
                  </p>
                </div>

                <div className="rounded-lg border border-slate-100 bg-slate-50 p-3">
                  <p className="text-[9px] font-semibold uppercase text-slate-400">
                    NISN
                  </p>

                  <p className="mt-1 text-xs font-bold text-slate-700">
                    {selectedPending.nisn}
                  </p>
                </div>
              </div>

              <div className="mt-3 rounded-lg border border-slate-100 p-3">
                <p className="text-[9px] font-semibold uppercase text-slate-400">
                  Keterangan Pengajuan
                </p>

                <p className="mt-1 text-xs leading-5 text-slate-600">
                  {selectedPending.keterangan}
                </p>
              </div>

              <div className="mt-3 rounded-lg border border-blue-100 bg-blue-50/60 p-3">
                <div className="flex items-center gap-2">
                  <span className="flex h-8 w-8 items-center justify-center rounded-md bg-white text-red-500 shadow-sm">
                    <Icon name="file" size={16} />
                  </span>

                  <div>
                    <p className="text-[10px] font-bold text-blue-700">
                      {selectedPending.namaBerkas}
                    </p>

                    <p className="mt-0.5 text-[9px] text-slate-400">
                      {selectedPending.ukuranBerkas}
                    </p>
                  </div>
                </div>
              </div>

              {modalMode === "reject" && (
                <div className="mt-4">
                  <label className="mb-1.5 block text-[10px] font-bold text-slate-600">
                    Catatan Penolakan
                  </label>

                  <textarea
                    value={rejectNote}
                    onChange={(event) => setRejectNote(event.target.value)}
                    rows={3}
                    placeholder="Masukkan alasan penolakan surat..."
                    className="w-full resize-none rounded-md border border-slate-200 px-3 py-2 text-xs text-slate-700 outline-none focus:border-red-400 focus:ring-2 focus:ring-red-50"
                  />
                </div>
              )}

              {modalMode === "approve" && (
                <div className="mt-4 rounded-lg border border-emerald-100 bg-emerald-50 p-3">
                  <div className="flex gap-2">
                    <div className="text-emerald-600">
                      <Icon name="shield" size={16} />
                    </div>

                    <div>
                      <p className="text-[10px] font-bold text-emerald-700">
                        Konfirmasi Persetujuan
                      </p>

                      <p className="mt-1 text-[9px] leading-4 text-emerald-600">
                        Surat akan dicatat sebagai dokumen sah dan masuk ke
                        histori verifikasi setelah Anda menyetujui pengajuan.
                      </p>
                    </div>
                  </div>
                </div>
              )}
            </div>

            {/* MODAL FOOTER */}
            <div className="flex justify-end gap-2 border-t border-slate-100 bg-slate-50 px-5 py-3">
              <button
                onClick={() => setShowModal(false)}
                className="rounded-md border border-slate-200 bg-white px-4 py-2 text-[10px] font-semibold text-slate-600 hover:bg-slate-100"
              >
                Batal
              </button>

              {modalMode === "approve" ? (
                <button
                  onClick={handleVerification}
                  className="flex items-center gap-1.5 rounded-md bg-emerald-600 px-4 py-2 text-[10px] font-bold text-white hover:bg-emerald-700"
                >
                  <Icon name="check" size={13} />
                  Setujui / ACC Surat
                </button>
              ) : (
                <button
                  onClick={handleVerification}
                  className="flex items-center gap-1.5 rounded-md bg-red-600 px-4 py-2 text-[10px] font-bold text-white hover:bg-red-700"
                >
                  <Icon name="x" size={13} />
                  Tolak Surat
                </button>
              )}
            </div>
          </div>
        </div>
      )}
    </>
  );
}