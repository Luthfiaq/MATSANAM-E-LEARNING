<?php
// Admin Web - Dashboard
// UI converted from the supplied Figma HTML.
?>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin Web - Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
      body {
        font-family: system-ui;
      }
    </style>
  </head>
  <body>
    <div class="flex flex-col bg-white">
      <div class="self-stretch bg-white overflow-hidden">
        <div class="flex items-center self-stretch">
          <div class="bg-white w-72 pb-[1px]">
            <div class="self-stretch mb-[582px]">
              <div class="flex items-center self-stretch bg-white py-[13px]">
                <img
                  src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/1z5m1xj5_expires_30_days.png"
                  class="w-9 h-9 ml-6 mr-2 rounded-lg object-fill"
                />
                <div class="w-[89px]">
                  <div class="self-stretch">
                    <div class="flex flex-col items-start self-stretch">
                      <span class="text-slate-900 text-base font-bold">
                        Matsanam
                      </span>
                    </div>
                    <div class="flex flex-col items-start self-stretch">
                      <span class="text-slate-400 text-[11px] font-bold">
                        Digital Academic
                      </span>
                    </div>
                  </div>
                </div>
              </div>
              <div class="self-stretch p-4">
                <div class="flex flex-col items-start self-stretch pb-1 pl-2">
                  <span class="text-slate-400 text-[11px] font-bold">
                    NAVIGASI UTAMA
                  </span>
                </div>
                <div class="flex flex-col self-stretch gap-1">
                  <div
                    class="flex items-center self-stretch bg-blue-600 py-2 rounded-lg"
                    style="box-shadow: 0px 1px 2px #0000000d"
                  >
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/m6rnhowz_expires_30_days.png"
                      class="w-[15px] h-[15px] ml-4 mr-2 rounded-lg object-fill"
                    />
                    <a href="dashboard.php" class="flex items-center w-full"><span class="text-white text-sm"> Dashboard Utama </span></a>
                  </div>
                  <div
                    class="flex flex-col items-start self-stretch pt-[13px] pb-[5px] pl-2"
                  >
                    <span class="text-slate-400 text-[11px] font-bold">
                      MANAJEMEN GURU
                    </span>
                  </div>
                  <div class="flex items-center self-stretch py-2 rounded-lg">
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/hwr913uw_expires_30_days.png"
                      class="w-[15px] h-4 ml-4 mr-2 rounded-lg object-fill"
                    />
                    <span class="text-[#434655] text-sm">
                      List Penugasan Guru
                    </span>
                  </div>
                  <div class="flex items-center self-stretch py-2 rounded-lg">
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/uxgxpvv9_expires_30_days.png"
                      class="w-[18px] h-[13px] ml-4 mr-2 rounded-lg object-fill"
                    />
                    <span class="text-[#434655] text-sm">
                      Atur Penugasan Baru
                    </span>
                  </div>
                  <div
                    class="flex flex-col items-start self-stretch pt-[13px] pb-[5px] pl-2"
                  >
                    <span class="text-slate-400 text-[11px] font-bold">
                      VERIFIKASI &amp; IZIN
                    </span>
                  </div>
                  <div
                    class="flex justify-between items-center self-stretch py-2 px-4 rounded-lg"
                  >
                    <div class="flex shrink-0 items-center gap-2">
                      <img
                        src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/6rp85bfp_expires_30_days.png"
                        class="w-4 h-[15px] object-fill"
                      />
                      <span class="text-[#434655] text-sm">
                        Verifikasi Surat
                      </span>
                    </div>
                    <div
                      class="flex flex-col shrink-0 items-start bg-[#F59E0B33] py-0.5 px-1 rounded-xl"
                    >
                      <span class="text-[#F59E0B] text-[11px] font-bold">
                        5
                      </span>
                    </div>
                  </div>
                  <div class="flex items-center self-stretch py-2 rounded-lg">
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/15k9i0d7_expires_30_days.png"
                      class="w-4 h-[13px] ml-4 mr-2 rounded-lg object-fill"
                    />
                    <span class="text-[#434655] text-sm">
                      Histori Verifikasi
                    </span>
                  </div>
                  <div
                    class="flex flex-col items-start self-stretch pt-[13px] pb-[5px] pl-2"
                  >
                    <span class="text-slate-400 text-[11px] font-bold">
                      PRESENSI &amp; LAPORAN
                    </span>
                  </div>
                  <div class="flex items-center self-stretch py-2 rounded-lg">
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/vkkxv224_expires_30_days.png"
                      class="w-4 h-[15px] ml-4 mr-2 rounded-lg object-fill"
                    />
                    <span class="text-[#434655] text-sm">
                      Rekap Absensi Siswa
                    </span>
                  </div>
                  <div
                    class="flex flex-col items-start self-stretch pt-[13px] pb-[5px] pl-2"
                  >
                    <span class="text-slate-400 text-[11px] font-bold">
                      KONFIGURASI
                    </span>
                  </div>
                  <div
                    class="flex items-center self-stretch py-2 px-4 gap-2 rounded-lg"
                  >
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/d13qi09x_expires_30_days.png"
                      class="w-[15px] h-[15px] rounded-lg object-fill"
                    />
                    <div class="flex flex-1 flex-col items-start">
                      <span class="text-[#434655] text-sm">
                        Pengaturan &amp; Master Data
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="self-stretch bg-[#F2F3FF] p-4">
              <div
                class="flex justify-between items-center self-stretch bg-white p-[9px] rounded-lg border border-solid border-slate-200"
              >
                <div class="w-[104px]">
                  <div class="flex flex-col self-stretch">
                    <div class="flex flex-col items-start self-stretch">
                      <span class="text-slate-400 text-[11px] font-bold">
                        Koneksi Database
                      </span>
                    </div>
                    <div class="flex items-center self-stretch gap-1">
                      <div class="bg-[#006C4A] w-2 h-2 rounded-xl"></div>
                      <span class="text-[#006C4A] text-xs">
                        Terhubung Aktif
                      </span>
                    </div>
                  </div>
                </div>
                <img
                  src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/fzgbrak8_expires_30_days.png"
                  class="w-[13px] h-3.5 rounded-lg object-fill"
                />
              </div>
            </div>
          </div>
          <div class="flex-1 bg-slate-50 pb-6">
            <div
              class="flex items-center self-stretch bg-[#FFFFFFE3] py-[11px] px-6"
            >
              <div class="flex flex-1 items-center mr-[89px] gap-4">
                <button
                  class="flex shrink-0 items-center bg-blue-50 text-left py-[5px] px-[9px] gap-1 rounded-lg border border-solid border-[#004AC633]"
                  onclick="alert('Pressed!')"
                >
                  <img
                    src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/j300icsi_expires_30_days.png"
                    class="w-3 h-[13px] rounded-lg object-fill"
                  />
                  <span class="text-[#004AC6] text-xs">
                    T.A. 2026/2027 Ganjil
                  </span>
                </button>
                <div
                  class="flex flex-1 items-center bg-slate-50 py-1.5 px-3 gap-[11px] rounded-lg border border-solid border-slate-200"
                >
                  <img
                    src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/x61gc2yr_expires_30_days.png"
                    class="w-[13px] h-[18px] object-fill"
                  />
                  <div class="flex flex-1 flex-col items-start">
                    <span class="text-slate-400 text-xs">
                      Cari NIP, nama guru, kelas, atau siswa...
                    </span>
                  </div>
                </div>
              </div>
              <div class="flex items-center w-[278px] gap-[33px]">
                <img
                  src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/h35u2hvy_expires_30_days.png"
                  class="w-[30px] h-[39px] rounded-lg object-fill"
                />
                <div class="flex flex-1 items-center gap-[9px]">
                  <div class="flex-1">
                    <div class="flex flex-col items-start self-stretch">
                      <span class="text-slate-900 text-base font-bold">
                        Ust. H. Ahmad Zulfikar
                      </span>
                    </div>
                    <div
                      class="flex flex-col items-start self-stretch pl-[37px]"
                    >
                      <span class="text-[#004AC6] text-[11px] font-bold">
                        Super Admin / Tata Usaha
                      </span>
                    </div>
                  </div>
                  <img
                    src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/5x1ky03k_expires_30_days.png"
                    class="w-[31px] h-8 rounded-xl object-fill"
                  />
                </div>
              </div>
            </div>
            <div class="flex flex-col self-stretch pb-12 mx-6 gap-6">
              <div
                class="flex flex-col items-start self-stretch relative p-6 rounded-xl"
                style="
                  background: linear-gradient(
                    180deg,
                    #004ac6,
                    #2563eb,
                    #0053db
                  );
                "
              >
                <div
                  class="flex-1 bg-[#FFFFFF1A] w-[216px] absolute top-0 bottom-0 right-0 rounded-xl blur-[40px]"
                ></div>
                <div
                  class="bg-[#82F5C133] w-32 h-32 absolute top-0 right-40 rounded-xl blur-[24px]"
                ></div>
                <div class="flex justify-between items-center self-stretch">
                  <div class="flex flex-col items-start w-[607px] gap-1">
                    <div class="flex flex-col items-start self-stretch">
                      <div
                        class="flex items-center bg-[#FFFFFF26] py-0.5 px-2 gap-1 rounded-xl"
                      >
                        <img
                          src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/gd9zoycr_expires_30_days.png"
                          class="w-3 h-[9px] rounded-xl object-fill"
                        />
                        <span class="text-white text-[11px] font-bold">
                          EMIS &amp; Simpatika Synced 08:30 WIB
                        </span>
                      </div>
                    </div>
                    <span class="text-white text-2xl font-bold w-[607px]">
                      Selamat Datang di Portal Administrasi Akademik MTsN<br />Matsanam
                    </span>
                    <div class="flex flex-col items-start self-stretch">
                      <span class="text-[#EEEFFF] text-sm w-[517px]">
                        Pusat komando digital madrasah: kelola SK penugasan
                        guru, verifikasi berkas<br />perizinan siswa real-time,
                        dan pantau rekapitulasi kehadiran madrasah hari ini.
                      </span>
                    </div>
                  </div>
                  <div
                    class="flex items-center bg-[#FFFFFF1A] w-[186px] py-2 px-4 gap-4 rounded-lg"
                    style="box-shadow: 0px 1px 2px #0000000d"
                  >
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/jw5mn2dd_expires_30_days.png"
                      class="w-[38px] h-10 rounded-xl object-fill"
                    />
                    <div class="flex-1">
                      <div class="flex flex-col items-start self-stretch">
                        <span class="text-white text-[11px] font-bold">
                          OTORITAS SESI
                        </span>
                      </div>
                      <div class="flex flex-col items-start self-stretch">
                        <span class="text-white text-base font-bold w-[99px]">
                          Super Admin<br />TU
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="flex items-center self-stretch gap-4">
                <div
                  class="flex-1 bg-white p-4 rounded-lg"
                  style="box-shadow: 0px 1px 2px #0000000d"
                >
                  <div class="flex justify-between items-start self-stretch">
                    <div class="w-[89px]">
                      <div class="flex flex-col items-start self-stretch">
                        <span class="text-slate-400 text-xs">
                          Total Guru Aktif
                        </span>
                      </div>
                      <div class="flex items-start self-stretch pt-1 gap-2">
                        <span
                          class="text-slate-900 text-4xl font-bold mb-[11px]"
                        >
                          42
                        </span>
                        <span class="text-slate-600 text-xs mt-[23px]">
                          Guru
                        </span>
                      </div>
                    </div>
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/gpqi4lun_expires_30_days.png"
                      class="w-[41px] h-11 rounded-lg object-fill"
                    />
                  </div>
                  <div
                    class="flex items-center self-stretch pt-5 pb-1 gap-[3px]"
                  >
                    <div class="flex shrink-0 items-center gap-1">
                      <img
                        src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/ufqi5jqr_expires_30_days.png"
                        class="w-[13px] h-[13px] object-fill"
                      />
                      <span class="text-[#006C4A] text-[11px] font-bold w-20">
                        142 Penugasan<br />Kelas
                      </span>
                    </div>
                    <div class="flex flex-col shrink-0 items-start pr-4">
                      <span
                        class="text-slate-400 text-[11px] font-bold w-[62px]"
                      >
                        Rasio 100%<br />Terisi
                      </span>
                    </div>
                  </div>
                </div>
                <div
                  class="flex-1 bg-white p-4 rounded-lg"
                  style="box-shadow: 0px 1px 2px #0000000d"
                >
                  <div class="flex items-start self-stretch gap-3">
                    <div class="flex-1">
                      <div class="flex flex-col items-start self-stretch">
                        <span class="text-slate-400 text-xs">
                          Verifikasi Surat Absensi
                        </span>
                      </div>
                      <div class="flex items-start self-stretch pt-1 gap-1.5">
                        <span class="text-[#F59E0B] text-4xl font-bold">
                          7
                        </span>
                        <span class="text-slate-600 text-xs mt-[23px]">
                          Menunggu Approval
                        </span>
                      </div>
                    </div>
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/pauqay7x_expires_30_days.png"
                      class="w-11 h-11 rounded-lg object-fill"
                    />
                  </div>
                  <div
                    class="flex items-center self-stretch pt-5 pb-1 gap-[3px]"
                  >
                    <div
                      class="flex flex-1 items-center bg-[#F59E0B26] py-0.5 px-2 gap-1 rounded-xl"
                    >
                      <img
                        src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/0r7qeuou_expires_30_days.png"
                        class="w-2.5 h-3 rounded-xl object-fill"
                      />
                      <span
                        class="text-[#F59E0B] text-[11px] font-bold w-[82px]"
                      >
                        Waspada Batas<br />Jam 12:00
                      </span>
                    </div>
                    <span class="text-slate-400 text-[11px] font-bold w-[54px]">
                      4 Sakit • 3<br />Izin
                    </span>
                  </div>
                </div>
                <div
                  class="flex flex-1 flex-col bg-white p-4 gap-[18px] rounded-lg"
                  style="box-shadow: 0px 1px 2px #0000000d"
                >
                  <div class="flex items-start self-stretch gap-[18px]">
                    <div class="flex-1">
                      <div class="flex flex-col items-start self-stretch">
                        <span class="text-slate-400 text-xs">
                          Kehadiran Siswa Hari Ini
                        </span>
                      </div>
                      <div class="flex flex-col items-start self-stretch pt-1">
                        <span class="text-[#006C4A] text-4xl font-bold">
                          96.4%
                        </span>
                      </div>
                    </div>
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/9qwwvat9_expires_30_days.png"
                      class="w-[35px] h-11 rounded-lg object-fill"
                    />
                  </div>
                  <div class="flex flex-col items-start self-stretch pt-5">
                    <span class="text-slate-900 text-[11px] font-bold">
                      840 dari 872 Siswa
                    </span>
                  </div>
                </div>
                <div
                  class="flex-1 bg-white p-4 rounded-lg"
                  style="box-shadow: 0px 1px 2px #0000000d"
                >
                  <div class="flex items-start self-stretch gap-[7px]">
                    <div class="flex flex-1 flex-col items-start relative">
                      <div class="flex flex-col self-stretch gap-1">
                        <div class="flex flex-col items-start self-stretch">
                          <span class="text-slate-400 text-xs">
                            Rombel &amp; Kelas Aktif
                          </span>
                        </div>
                        <div
                          class="flex flex-col items-start self-stretch pb-[11px]"
                        >
                          <span class="text-slate-900 text-4xl font-bold">
                            24
                          </span>
                        </div>
                      </div>
                      <span
                        class="text-slate-600 text-xs absolute bottom-4 right-[-16px]"
                      >
                        Rombongan Belajar
                      </span>
                    </div>
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/o1247a6g_expires_30_days.png"
                      class="w-[41px] h-11 rounded-lg object-fill"
                    />
                  </div>
                  <div class="flex items-center self-stretch pt-5 pb-1">
                    <div class="flex flex-1 flex-col items-start">
                      <span
                        class="text-slate-400 text-[11px] font-bold w-[132px]"
                      >
                        Kelas 7 (8) • Kelas 8 (8) •<br />Kelas 9 (8)
                      </span>
                    </div>
                    <div class="flex flex-col shrink-0 items-start pr-3">
                      <span
                        class="text-[#004AC6] text-[11px] font-bold w-[30px]"
                      >
                        100%<br />Siap
                      </span>
                    </div>
                  </div>
                </div>
              </div>
              <div class="flex flex-col self-stretch gap-1">
                <div class="flex justify-between items-center self-stretch">
                  <div class="flex shrink-0 items-center gap-1">
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/g49fpzoy_expires_30_days.png"
                      class="w-3.5 h-[18px] object-fill"
                    />
                    <span class="text-slate-900 text-lg font-bold">
                      Aksi Cepat &amp; Alur Kerja Utama
                    </span>
                  </div>
                  <span class="text-slate-400 text-[11px] font-bold">
                    Sesuai SOP Administrasi Madrasah
                  </span>
                </div>
                <div class="flex items-center self-stretch gap-4">
                  <div
                    class="flex-1 bg-white p-6 rounded-lg"
                    style="box-shadow: 0px 1px 2px #0000000d"
                  >
                    <div class="items-start self-stretch relative">
                      <div
                        class="bg-[#EFF6FF99] w-24 h-32 absolute bottom-3 right-[-24px] rounded-bl-xl"
                      ></div>
                      <div class="flex flex-col items-start self-stretch gap-2">
                        <img
                          src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/r1a3daeg_expires_30_days.png"
                          class="w-12 h-12 rounded-lg object-fill"
                        />
                        <div
                          class="flex flex-col items-start self-stretch gap-1"
                        >
                          <span class="text-slate-900 text-base font-bold">
                            Atur Penugasan Guru
                          </span>
                          <span class="text-slate-600 text-xs">
                            Plotting jam mengajar, tambah/edit/hapus<br />penugasan
                            kelas, dan sinkronkan beban SKS
                          </span>
                        </div>
                      </div>
                    </div>
                    <div class="flex items-start self-stretch pt-8 gap-2">
                      <div class="flex shrink-0 items-center gap-1">
                        <img
                          src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/nxchmwyl_expires_30_days.png"
                          class="w-[13px] h-[13px] object-fill"
                        />
                        <span class="text-slate-400 text-[11px] font-bold w-11">
                          Update<br />Kemarin
                        </span>
                      </div>
                      <div
                        class="flex flex-1 justify-between items-center bg-[#004AC6] py-1.5 px-4 rounded-lg"
                        style="box-shadow: 0px 1px 2px #0000000d"
                      >
                        <span class="text-white text-xs font-bold w-[67px]">
                          Buka Kelola<br />Penugasan
                        </span>
                        <img
                          src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/g66qobqo_expires_30_days.png"
                          class="w-3 h-3 rounded-lg object-fill"
                        />
                      </div>
                    </div>
                  </div>
                  <div
                    class="flex-1 bg-white p-6 rounded-lg"
                    style="box-shadow: 0px 1px 2px #0000000d"
                  >
                    <div class="items-start self-stretch relative">
                      <div
                        class="bg-[#F59E0B1A] w-24 h-32 absolute bottom-3 right-[-24px] rounded-bl-xl"
                      ></div>
                      <div class="flex flex-col items-start self-stretch gap-2">
                        <img
                          src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/anyalo3j_expires_30_days.png"
                          class="w-12 h-12 rounded-lg object-fill"
                        />
                        <div class="flex flex-col self-stretch gap-1">
                          <div class="flex items-center self-stretch gap-2.5">
                            <span class="text-slate-900 text-base font-bold">
                              Verifikasi Surat Izin/Sakit
                            </span>
                            <div
                              class="flex flex-col shrink-0 items-start bg-[#F59E0B33] py-0.5 px-2 rounded-xl"
                            >
                              <span
                                class="text-[#F59E0B] text-[11px] font-bold"
                              >
                                7 Baru
                              </span>
                            </div>
                          </div>
                          <span class="text-slate-600 text-xs">
                            Validasi dokumen PDF/foto dokter dari orang<br />tua/wali
                            siswa. Setujui atau tolak izin disertai
                          </span>
                        </div>
                      </div>
                    </div>
                    <div class="flex items-start self-stretch pt-8 gap-[9px]">
                      <div class="flex shrink-0 items-center gap-1">
                        <img
                          src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/9f96e97p_expires_30_days.png"
                          class="w-[13px] h-[13px] object-fill"
                        />
                        <span
                          class="text-[#F59E0B] text-[11px] font-bold w-[55px]"
                        >
                          Butuh aksi<br />segera
                        </span>
                      </div>
                      <div
                        class="flex flex-1 justify-between items-center bg-[#004AC6] py-1.5 px-4 rounded-lg"
                        style="box-shadow: 0px 1px 2px #0000000d"
                      >
                        <span class="text-white text-xs font-bold w-[79px]">
                          Tinjau 7 Surat<br />Pending
                        </span>
                        <img
                          src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/rnfapdko_expires_30_days.png"
                          class="w-3 h-3 rounded-lg object-fill"
                        />
                      </div>
                    </div>
                  </div>
                  <div
                    class="flex-1 bg-white p-6 rounded-lg"
                    style="box-shadow: 0px 1px 2px #0000000d"
                  >
                    <div class="flex flex-col items-start self-stretch gap-2">
                      <img
                        src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/dz9cwlb0_expires_30_days.png"
                        class="w-12 h-12 rounded-lg object-fill"
                      />
                      <div class="flex flex-col self-stretch gap-1">
                        <div class="flex flex-col items-start self-stretch">
                          <span class="text-slate-900 text-base font-bold">
                            Rekap Absensi Siswa
                          </span>
                        </div>
                        <span class="text-slate-600 text-xs">
                          Filter data kehadiran berdasarkan semester,<br />rombel
                          kelas, bulan berjalan, dan unduh…
                        </span>
                      </div>
                    </div>
                    <div class="flex items-start self-stretch pt-8 gap-3">
                      <div class="flex shrink-0 items-center gap-1">
                        <img
                          src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/ki00r7xd_expires_30_days.png"
                          class="w-2.5 h-2.5 object-fill"
                        />
                        <span
                          class="text-slate-400 text-[11px] font-bold w-[53px]"
                        >
                          Format<br />Madrasah
                        </span>
                      </div>
                      <div
                        class="flex flex-1 justify-between items-center bg-[#E2E7FF] py-1.5 px-4 rounded-lg"
                      >
                        <span class="text-[#131B2E] text-xs font-bold w-16">
                          Buka Menu<br />Rekap
                        </span>
                        <img
                          src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/m7dkc3xh_expires_30_days.png"
                          class="w-3 h-3 rounded-lg object-fill"
                        />
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div
                class="self-stretch bg-white rounded-lg"
                style="box-shadow: 0px 1px 2px #0000000d"
              >
                <div
                  class="flex justify-between items-center self-stretch bg-white p-4"
                >
                  <div class="flex items-center w-[345px] gap-2">
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/3o3ycnke_expires_30_days.png"
                      class="w-9 h-9 rounded-lg object-fill"
                    />
                    <div class="flex-1">
                      <div class="flex flex-col items-start self-stretch">
                        <span class="text-slate-900 text-base font-bold">
                          Antrean Validasi Surat Perizinan Siswa
                        </span>
                      </div>
                      <div class="flex flex-col items-start self-stretch">
                        <span class="text-slate-400 text-[11px] font-bold">
                          Menampilkan permohonan yang perlu diverifikasi hari
                          ini
                        </span>
                      </div>
                    </div>
                  </div>
                  <div class="flex shrink-0 items-center gap-[5px]">
                    <div
                      class="flex shrink-0 items-center bg-slate-50 py-1 px-2 gap-1 rounded-lg"
                    >
                      <img
                        src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/zsqi8khd_expires_30_days.png"
                        class="w-3 h-2 rounded-lg object-fill"
                      />
                      <span class="text-slate-600 text-[11px] font-bold">
                        Filter Status
                      </span>
                    </div>
                    <div class="flex flex-col shrink-0 items-start px-2">
                      <span class="text-[#004AC6] text-[11px] font-bold">
                        Lihat Semua (7)
                      </span>
                    </div>
                  </div>
                </div>
                <div class="self-stretch">
                  <div class="flex items-center self-stretch bg-slate-50">
                    <div
                      class="flex flex-1 flex-col items-start py-2 pl-[15px]"
                    >
                      <span class="text-slate-600 text-xs font-bold">
                        SISWA &amp; NISN
                      </span>
                    </div>
                    <div
                      class="flex flex-col shrink-0 items-start py-2 pl-4 pr-24 mr-[1px]"
                    >
                      <span class="text-slate-600 text-xs font-bold">
                        KELAS
                      </span>
                    </div>
                    <div
                      class="flex flex-col shrink-0 items-start py-2 pl-4 pr-[35px] mr-[1px]"
                    >
                      <span class="text-slate-600 text-xs font-bold">
                        RENTANG IZIN
                      </span>
                    </div>
                    <div
                      class="flex flex-col shrink-0 items-start py-2 pl-4 pr-[81px]"
                    >
                      <span class="text-slate-600 text-xs font-bold">
                        JENIS &amp; BUKTI
                      </span>
                    </div>
                    <div class="flex flex-1 flex-col items-end py-2 pr-4">
                      <span class="text-slate-600 text-xs font-bold">
                        AKSI CEPAT
                      </span>
                    </div>
                  </div>
                  <div class="self-stretch">
                    <div class="flex items-center self-stretch">
                      <div
                        class="flex flex-1 items-center ml-[15px] mr-[17px] gap-2"
                      >
                        <button
                          class="flex flex-col shrink-0 items-start bg-[#E2E7FF] text-left py-[7px] px-2 rounded-xl border-0"
                          onclick="alert('Pressed!')"
                          }
                        >
                          <span class="text-[#004AC6] text-xs font-bold">
                            AR
                          </span>
                        </button>
                        <div class="flex-1">
                          <div class="flex flex-col items-start self-stretch">
                            <span class="text-slate-900 text-sm font-bold">
                              Ahmad Raihan Pratama
                            </span>
                          </div>
                          <div class="flex flex-col items-start self-stretch">
                            <span class="text-slate-400 text-[11px] font-bold">
                              NISN: 0098231451
                            </span>
                          </div>
                        </div>
                      </div>
                      <div
                        class="flex flex-col shrink-0 items-start bg-[#E2E7FF] py-0.5 px-2.5 my-[23px] ml-4 mr-[58px] rounded-xl"
                      >
                        <span class="text-slate-600 text-[11px] font-bold">
                          7-B (Bilingual)
                        </span>
                      </div>
                      <div class="w-[109px] mr-[17px]">
                        <div class="flex flex-col items-start self-stretch">
                          <span class="text-slate-900 text-[13px]">
                            Hari ini (1 Hari)
                          </span>
                        </div>
                        <div class="flex flex-col items-start self-stretch">
                          <span class="text-slate-400 text-[11px] font-bold">
                            24 Okt 2026
                          </span>
                        </div>
                      </div>
                      <div
                        class="flex shrink-0 items-center px-4 mr-4 gap-[5px]"
                      >
                        <div
                          class="flex shrink-0 items-center bg-[#DC26261A] py-0.5 px-2 gap-1 rounded-xl"
                        >
                          <div class="bg-red-600 w-1.5 h-1.5 rounded-xl"></div>
                          <span class="text-red-600 text-[11px] font-bold">
                            Sakit
                          </span>
                        </div>
                        <img
                          src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/ucogfgrg_expires_30_days.png"
                          class="w-[23px] h-[17px] rounded object-fill"
                        />
                      </div>
                      <div
                        class="flex flex-1 flex-col items-end py-5 pr-4 mr-[1px]"
                      >
                        <div class="flex items-center gap-[5px]">
                          <div
                            class="flex shrink-0 items-center bg-[#006C4A] py-1 px-2 gap-1 rounded-lg"
                            style="box-shadow: 0px 1px 2px #0000000d"
                          >
                            <img
                              src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/0y2okkkl_expires_30_days.png"
                              class="w-2.5 h-2 rounded-lg object-fill"
                            />
                            <span class="text-white text-[11px] font-bold">
                              Terima
                            </span>
                          </div>
                          <div
                            class="flex shrink-0 items-center bg-[#E2E7FF] py-1 px-2 gap-1 rounded-lg"
                          >
                            <img
                              src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/t6nm3ktk_expires_30_days.png"
                              class="w-[9px] h-[9px] rounded-lg object-fill"
                            />
                            <span class="text-red-600 text-[11px] font-bold">
                              Tolak
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="flex items-center self-stretch bg-[#F8FAFC4D]">
                      <div
                        class="flex flex-1 items-center ml-[15px] mr-[17px] gap-2"
                      >
                        <button
                          class="flex flex-col shrink-0 items-start bg-[#E2E7FF] text-left py-[7px] px-2 rounded-xl border-0"
                          onclick="alert('Pressed!')"
                          }
                        >
                          <span class="text-[#004AC6] text-xs font-bold">
                            SN
                          </span>
                        </button>
                        <div class="w-[101px]">
                          <div class="flex flex-col items-start self-stretch">
                            <span class="text-slate-900 text-sm font-bold">
                              Siti Nurhaliza
                            </span>
                          </div>
                          <div class="flex flex-col items-start self-stretch">
                            <span class="text-slate-400 text-[11px] font-bold">
                              NISN: 0098452109
                            </span>
                          </div>
                        </div>
                      </div>
                      <div
                        class="flex flex-col shrink-0 items-start bg-[#E2E7FF] py-0.5 px-2.5 my-[23px] ml-4 mr-[63px] rounded-xl"
                      >
                        <span class="text-slate-600 text-[11px] font-bold">
                          8-A (Tahfidz)
                        </span>
                      </div>
                      <div class="w-[109px] mr-[17px]">
                        <div class="flex flex-col items-start self-stretch">
                          <span class="text-slate-900 text-[13px]">
                            2 Hari
                          </span>
                        </div>
                        <div class="flex flex-col items-start self-stretch">
                          <span class="text-slate-400 text-[11px] font-bold">
                            24 - 25 Okt 2026
                          </span>
                        </div>
                      </div>
                      <div class="flex shrink-0 items-center px-4 mr-4 gap-1">
                        <div
                          class="flex shrink-0 items-center bg-[#F59E0B26] py-0.5 px-2 gap-1 rounded-xl"
                        >
                          <div
                            class="bg-[#F59E0B] w-1.5 h-1.5 rounded-xl"
                          ></div>
                          <span class="text-[#F59E0B] text-[11px] font-bold">
                            Izin Keluarga
                          </span>
                        </div>
                        <img
                          src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/jgg3egaq_expires_30_days.png"
                          class="w-5 h-[23px] rounded object-fill"
                        />
                      </div>
                      <div
                        class="flex flex-1 flex-col items-end py-5 pr-4 mr-[1px]"
                      >
                        <div class="flex items-center gap-[5px]">
                          <div
                            class="flex shrink-0 items-center bg-[#006C4A] py-1 px-2 gap-1 rounded-lg"
                            style="box-shadow: 0px 1px 2px #0000000d"
                          >
                            <img
                              src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/4s3pzt5e_expires_30_days.png"
                              class="w-2.5 h-2 rounded-lg object-fill"
                            />
                            <span class="text-white text-[11px] font-bold">
                              Terima
                            </span>
                          </div>
                          <div
                            class="flex shrink-0 items-center bg-[#E2E7FF] py-1 px-2 gap-1 rounded-lg"
                          >
                            <img
                              src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/0nnzvgis_expires_30_days.png"
                              class="w-[9px] h-[9px] rounded-lg object-fill"
                            />
                            <span class="text-red-600 text-[11px] font-bold">
                              Tolak
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="flex items-center self-stretch">
                      <div
                        class="flex flex-1 items-center ml-[15px] mr-[17px] gap-2"
                      >
                        <button
                          class="flex flex-col shrink-0 items-start bg-[#E2E7FF] text-left p-[7px] rounded-xl border-0"
                          onclick="alert('Pressed!')"
                          }
                        >
                          <span class="text-[#004AC6] text-xs font-bold">
                            MF
                          </span>
                        </button>
                        <div class="w-[124px]">
                          <div class="flex flex-col items-start self-stretch">
                            <span class="text-slate-900 text-sm font-bold">
                              Muhammad Fadhil
                            </span>
                          </div>
                          <div class="flex flex-col items-start self-stretch">
                            <span class="text-slate-400 text-[11px] font-bold">
                              NISN: 0087123984
                            </span>
                          </div>
                        </div>
                      </div>
                      <div
                        class="flex flex-col shrink-0 items-start bg-[#E2E7FF] py-0.5 px-2.5 my-[23px] ml-4 mr-[61px] rounded-xl"
                      >
                        <span class="text-slate-600 text-[11px] font-bold">
                          9-C (Reguler)
                        </span>
                      </div>
                      <div class="w-[109px] mr-[17px]">
                        <div class="flex flex-col items-start self-stretch">
                          <span class="text-slate-900 text-[13px]">
                            3 Hari
                          </span>
                        </div>
                        <div class="flex flex-col items-start self-stretch">
                          <span class="text-slate-400 text-[11px] font-bold">
                            24 - 26 Okt 2026
                          </span>
                        </div>
                      </div>
                      <div
                        class="flex shrink-0 items-center px-4 mr-4 gap-[5px]"
                      >
                        <div
                          class="flex shrink-0 items-center bg-[#DC26261A] py-0.5 px-2 gap-1 rounded-xl"
                        >
                          <div class="bg-red-600 w-1.5 h-1.5 rounded-xl"></div>
                          <span class="text-red-600 text-[11px] font-bold">
                            Sakit Rawat
                          </span>
                        </div>
                        <img
                          src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/ijohyyr4_expires_30_days.png"
                          class="w-[23px] h-[17px] rounded object-fill"
                        />
                      </div>
                      <div
                        class="flex flex-1 flex-col items-end py-5 pr-4 mr-[1px]"
                      >
                        <div class="flex items-center gap-[5px]">
                          <div
                            class="flex shrink-0 items-center bg-[#006C4A] py-1 px-2 gap-1 rounded-lg"
                            style="box-shadow: 0px 1px 2px #0000000d"
                          >
                            <img
                              src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/u6b3a5dc_expires_30_days.png"
                              class="w-2.5 h-2 rounded-lg object-fill"
                            />
                            <span class="text-white text-[11px] font-bold">
                              Terima
                            </span>
                          </div>
                          <div
                            class="flex shrink-0 items-center bg-[#E2E7FF] py-1 px-2 gap-1 rounded-lg"
                          >
                            <img
                              src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/n7i75erj_expires_30_days.png"
                              class="w-[9px] h-[9px] rounded-lg object-fill"
                            />
                            <span class="text-red-600 text-[11px] font-bold">
                              Tolak
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="flex items-center self-stretch bg-[#F8FAFC4D]">
                      <div
                        class="flex flex-1 items-center ml-[15px] mr-[17px] gap-2"
                      >
                        <button
                          class="flex flex-col shrink-0 items-start bg-[#E2E7FF] text-left py-[7px] px-2 rounded-xl border-0"
                          onclick="alert('Pressed!')"
                          }
                        >
                          <span class="text-[#004AC6] text-xs font-bold">
                            DN
                          </span>
                        </button>
                        <div class="flex-1">
                          <div class="flex flex-col items-start self-stretch">
                            <span class="text-slate-900 text-sm font-bold">
                              Dewi Nabila Az-Zahra
                            </span>
                          </div>
                          <div class="flex flex-col items-start self-stretch">
                            <span class="text-slate-400 text-[11px] font-bold">
                              NISN: 0091244588
                            </span>
                          </div>
                        </div>
                      </div>
                      <div
                        class="flex flex-col shrink-0 items-start bg-[#E2E7FF] py-0.5 px-2.5 my-[23px] ml-4 mr-[52px] rounded-xl"
                      >
                        <span class="text-slate-600 text-[11px] font-bold">
                          7-A (Unggulan)
                        </span>
                      </div>
                      <div class="w-[109px] mr-[17px]">
                        <div class="flex flex-col items-start self-stretch">
                          <span class="text-slate-900 text-[13px]">
                            Hari ini (1 Hari)
                          </span>
                        </div>
                        <div class="flex flex-col items-start self-stretch">
                          <span class="text-slate-400 text-[11px] font-bold">
                            24 Okt 2026
                          </span>
                        </div>
                      </div>
                      <div class="flex shrink-0 items-center px-4 mr-4 gap-1">
                        <div
                          class="flex shrink-0 items-center bg-[#004AC61A] py-0.5 px-2 gap-1 rounded-xl"
                        >
                          <div
                            class="bg-[#004AC6] w-1.5 h-1.5 rounded-xl"
                          ></div>
                          <span class="text-[#004AC6] text-[11px] font-bold">
                            Dispen Lomba
                          </span>
                        </div>
                        <img
                          src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/to8xrrcb_expires_30_days.png"
                          class="w-6 h-[23px] rounded object-fill"
                        />
                      </div>
                      <div
                        class="flex flex-1 flex-col items-end py-5 pr-4 mr-[1px]"
                      >
                        <div class="flex items-center gap-[5px]">
                          <div
                            class="flex shrink-0 items-center bg-[#006C4A] py-1 px-2 gap-1 rounded-lg"
                            style="box-shadow: 0px 1px 2px #0000000d"
                          >
                            <img
                              src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/pa7oa9e0_expires_30_days.png"
                              class="w-2.5 h-2 rounded-lg object-fill"
                            />
                            <span class="text-white text-[11px] font-bold">
                              Terima
                            </span>
                          </div>
                          <div
                            class="flex shrink-0 items-center bg-[#E2E7FF] py-1 px-2 gap-1 rounded-lg"
                          >
                            <img
                              src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/6bd1it8c_expires_30_days.png"
                              class="w-[9px] h-[9px] rounded-lg object-fill"
                            />
                            <span class="text-red-600 text-[11px] font-bold">
                              Tolak
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div
                  class="flex justify-between items-center self-stretch bg-[#F2F3FF] py-2 px-4"
                >
                  <span class="text-slate-400 text-[11px] font-bold">
                    Menampilkan 4 dari 7 antrean mendesak
                  </span>
                  <div class="flex shrink-0 items-center gap-1.5">
                    <span class="text-[#004AC6] text-[11px] font-bold">
                      Buka Halaman Verifikasi Penuh
                    </span>
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/jul5l2g2_expires_30_days.png"
                      class="w-[9px] h-[9px] object-fill"
                    />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </body>
</html>
