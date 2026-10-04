"use client";

import SuratList from "../../../components/verifikasi/SuratList";

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
    case "grid":
      return (
        <svg {...common}>
          <rect x="4" y="4" width="6" height="6" rx="1" />
          <rect x="14" y="4" width="6" height="6" rx="1" />
          <rect x="4" y="14" width="6" height="6" rx="1" />
          <rect x="14" y="14" width="6" height="6" rx="1" />
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

    case "userPlus":
      return (
        <svg {...common}>
          <circle cx="9" cy="8" r="3" />
          <path d="M3 20c.6-3.3 2.5-5 6-5" />
          <path d="M17 14v6M14 17h6" />
        </svg>
      );

    case "file":
      return (
        <svg {...common}>
          <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8Z" />
          <path d="M14 2v6h6M8 13h8M8 17h5" />
        </svg>
      );

    case "history":
      return (
        <svg {...common}>
          <path d="M3 12a9 9 0 1 0 3-6.7" />
          <path d="M3 4v5h5M12 7v5l3 2" />
        </svg>
      );

    case "calendar":
      return (
        <svg {...common}>
          <rect x="3" y="4" width="18" height="17" rx="2" />
          <path d="M16 2v4M8 2v4M3 10h18" />
        </svg>
      );

    case "settings":
      return (
        <svg {...common}>
          <path d="M12 8.5a3.5 3.5 0 1 0 0 7 3.5 3.5 0 0 0 0-7Z" />
          <path d="m19 13 .1-.9 2-1.5-2-3.5-2.3.7a8 8 0 0 0-1.6-.9L14.8 4h-5l-.4 2.9a8 8 0 0 0-1.6.9l-2.3-.7-2 3.5 2 1.5a8 8 0 0 0 0 1.8l-2 1.5 2 3.5 2.3-.7c.5.4 1 .7 1.6.9l.4 2.9h5l.4-2.9c.6-.2 1.1-.5 1.6-.9l2.3.7 2-3.5-2-1.5A8 8 0 0 0 19 13Z" />
        </svg>
      );

    case "search":
      return (
        <svg {...common}>
          <circle cx="11" cy="11" r="7" />
          <path d="m20 20-4-4" />
        </svg>
      );

    case "bell":
      return (
        <svg {...common}>
          <path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9M10 21h4" />
        </svg>
      );

    case "sliders":
      return (
        <svg {...common}>
          <path d="M4 6h16M4 12h16M4 18h16" />
          <circle cx="8" cy="6" r="2" fill="white" />
          <circle cx="15" cy="12" r="2" fill="white" />
          <circle cx="10" cy="18" r="2" fill="white" />
        </svg>
      );

    default:
      return null;
  }
}

type NavigationItem = {
  label: string;
  icon: string;
  active?: boolean;
  badge?: string;
};

type NavigationSection = {
  title: string;
  items: NavigationItem[];
};

const navigation: NavigationSection[] = [
  {
    title: "NAVIGASI UTAMA",
    items: [
      {
        label: "Dashboard Utama",
        icon: "grid",
      },
    ],
  },
  {
    title: "MANAJEMEN GURU",
    items: [
      {
        label: "List Penugasan Guru",
        icon: "users",
      },
      {
        label: "Atur Penugasan Baru",
        icon: "userPlus",
      },
    ],
  },
  {
    title: "VERIFIKASI & IZIN",
    items: [
      {
        label: "Verifikasi Surat",
        icon: "file",
        badge: "5",
      },
      {
        label: "Histori Verifikasi",
        icon: "history",
        active: true,
      },
    ],
  },
  {
    title: "PRESENSI & LAPORAN",
    items: [
      {
        label: "Rekap Absensi Siswa",
        icon: "calendar",
      },
    ],
  },
  {
    title: "KONFIGURASI",
    items: [
      {
        label: "Pengaturan & Master Data",
        icon: "sliders",
      },
    ],
  },
];

export default function VerifikasiAbsensiPage() {
  return (
    <div className="min-h-screen bg-[#f7f9fc] text-slate-700">
      {/* TOP HEADER */}
      <header className="fixed left-0 right-0 top-0 z-50 h-[52px] border-b border-slate-200 bg-white">
        <div className="flex h-full">
          {/* LOGO */}
          <div className="flex w-[230px] shrink-0 items-center border-r border-slate-200 px-4">
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-600 text-white">
              <Icon name="file" size={16} />
            </div>

            <div className="ml-2.5">
              <p className="text-[13px] font-extrabold leading-none tracking-tight text-slate-800">
                MATSANAM
              </p>

              <p className="mt-1 text-[8px] leading-none text-slate-400">
                Digital Academic Portal
              </p>
            </div>
          </div>

          {/* HEADER CONTENT */}
          <div className="flex min-w-0 flex-1 items-center justify-between px-4">
            <div className="flex items-center gap-3">
              <span className="flex h-7 items-center gap-1.5 rounded-md border border-blue-200 bg-blue-50 px-2 text-[10px] font-semibold text-blue-600">
                <Icon name="calendar" size={12} />
                T.A. 2026/2027 Ganjil
              </span>

              <div className="hidden h-7 w-[310px] items-center gap-2 rounded-md border border-slate-200 bg-slate-50 px-2.5 md:flex">
                <span className="text-slate-400">
                  <Icon name="search" size={14} />
                </span>

                <span className="text-[9px] text-slate-400">
                  Cari NIP, nama guru, kelas, atau siswa...
                </span>
              </div>
            </div>

            <div className="flex items-center gap-3">
              <button className="relative flex h-8 w-8 items-center justify-center text-slate-500">
                <Icon name="bell" size={17} />

                <span className="absolute right-1 top-1 h-1.5 w-1.5 rounded-full bg-red-500" />
              </button>

              <div className="h-6 w-px bg-slate-200" />

              <div className="hidden text-right sm:block">
                <p className="text-[11px] font-bold leading-none text-slate-700">
                  Ust. H. Ahmad Zulfikar
                </p>

                <p className="mt-1 text-[8px] font-semibold text-blue-600">
                  Super Admin / Tata Usaha
                </p>
              </div>

              <div className="flex h-8 w-8 items-center justify-center rounded-full bg-blue-600 text-white">
                <Icon name="users" size={16} />
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* SIDEBAR */}
      <aside className="fixed bottom-0 left-0 top-[52px] z-40 hidden w-[230px] border-r border-slate-200 bg-white lg:block">
        <div className="h-full px-3 py-4">
          {navigation.map((section) => (
            <div key={section.title} className="mb-5">
              <p className="mb-2 px-2 text-[8px] font-bold uppercase tracking-[0.12em] text-slate-400">
                {section.title}
              </p>

              <div className="space-y-0.5">
                {section.items.map((item) => (
                  <button
                    key={item.label}
                    className={`group flex w-full items-center rounded-md px-2.5 py-2 text-left transition ${
                      item.active
                        ? "bg-blue-600 text-white shadow-sm"
                        : "text-slate-500 hover:bg-slate-50 hover:text-slate-700"
                    }`}
                  >
                    <span
                      className={
                        item.active ? "text-white" : "text-slate-400"
                      }
                    >
                      <Icon name={item.icon} size={15} />
                    </span>

                    <span className="ml-2.5 flex-1 text-[10px] font-medium">
                      {item.label}
                    </span>

                    {item.badge && (
                      <span
                        className={`flex h-4 min-w-4 items-center justify-center rounded-full px-1 text-[8px] font-bold ${
                          item.active
                            ? "bg-white text-blue-600"
                            : "bg-red-500 text-white"
                        }`}
                      >
                        {item.badge}
                      </span>
                    )}
                  </button>
                ))}
              </div>
            </div>
          ))}

          {/* DATABASE STATUS */}
          <div className="absolute bottom-4 left-3 right-3 rounded-lg border border-slate-200 bg-slate-50 p-3">
            <p className="text-[8px] text-slate-400">Koneksi Database</p>

            <div className="mt-1 flex items-center gap-1.5">
              <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />

              <span className="text-[9px] font-semibold text-emerald-700">
                Terhubung Aktif
              </span>

              <span className="ml-auto text-slate-400">
                <Icon name="settings" size={12} />
              </span>
            </div>
          </div>
        </div>
      </aside>

      {/* MAIN */}
      <main className="min-h-screen pt-[52px] lg:pl-[230px]">
        <div className="mx-auto max-w-[1400px] px-4 py-5 sm:px-6 lg:px-7">
          {/* BREADCRUMB */}
          <div className="mb-1 flex items-center gap-1 text-[8px] font-bold uppercase tracking-wide text-slate-400">
            <span>KESISWAAN & TATA USAHA</span>
            <span>•</span>
            <span className="text-blue-600">
              HISTORI & LOG AUDIT
            </span>
          </div>

          {/* TITLE */}
          <div className="mb-5 flex flex-col gap-2 xl:flex-row xl:items-end xl:justify-between">
            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-[19px] font-bold tracking-tight text-slate-800">
                  Histori Verifikasi Surat Absensi
                </h1>

                <span className="rounded-full bg-blue-50 px-2 py-0.5 text-[8px] font-bold text-blue-600">
                  Flow 2.9 TU
                </span>
              </div>

              <p className="mt-1 max-w-[600px] text-[10px] leading-4 text-slate-500">
                Arsip komprehensif dan jejak audit verifikasi surat sakit,
                dispensasi kegiatan, serta izin wali yang telah disahkan oleh
                unit Tata Usaha MTsN 6 Jakarta.
              </p>
            </div>
          </div>

          {/* CONTENT */}
          <SuratList />
        </div>
      </main>
    </div>
  );
}