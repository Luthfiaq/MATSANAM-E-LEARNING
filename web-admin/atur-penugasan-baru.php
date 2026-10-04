<?php
// Admin Web - Atur Penugasan Baru
// UI converted from the supplied Figma HTML.
?>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin Web - Atur Penugasan Baru</title>
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
        <div class="flex items-start self-stretch">
          <div class="bg-white w-72" style="box-shadow: 0px 1px 3px #0f172a0d">
            <div class="self-stretch pb-[55px]">
              <div class="flex items-center self-stretch py-3">
                <img
                  src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/xcc66ncw_expires_30_days.png"
                  class="w-9 h-9 ml-6 mr-3 rounded-lg object-fill"
                />
                <div class="w-[123px]">
                  <div class="self-stretch">
                    <div class="flex flex-col items-start self-stretch">
                      <span class="text-slate-900 text-base font-bold">
                        MATSANAM
                      </span>
                    </div>
                    <div class="flex flex-col items-start self-stretch">
                      <span class="text-slate-400 text-[11px] font-bold">
                        Digital Academic Portal
                      </span>
                    </div>
                  </div>
                </div>
              </div>
              <div class="self-stretch pt-1 px-4">
                <div
                  class="flex items-center self-stretch py-2 mb-4 rounded-lg"
                >
                  <img
                    src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/sny1m4j5_expires_30_days.png"
                    class="w-5 h-5 mx-3 rounded-lg object-fill"
                  />
                  <a href="dashboard.php" class="flex items-center w-full"><span class="text-slate-600 text-sm"> Dashboard Utama </span></a>
                </div>
                <div class="flex flex-col self-stretch mb-4 gap-1">
                  <div class="flex flex-col items-start self-stretch pl-3">
                    <span class="text-slate-400 text-[11px] font-bold">
                      MANAJEMEN GURU
                    </span>
                  </div>
                  <div class="flex items-center self-stretch py-2 rounded-lg">
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/slbz2z6a_expires_30_days.png"
                      class="w-5 h-5 mx-3 rounded-lg object-fill"
                    />
                    <a href="list-penugasan-guru.php" class="flex items-center w-full"><span class="text-slate-600 text-sm">
                      List Penugasan Guru
                    </span></a>
                  </div>
                  <div
                    class="flex items-center self-stretch bg-blue-600 py-2 rounded-lg"
                    style="box-shadow: 0px 1px 2px #0000000d"
                  >
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/5smcdpju_expires_30_days.png"
                      class="w-5 h-5 mx-3 rounded-lg object-fill"
                    />
                    <span class="text-white text-sm font-bold">
                      Atur Penugasan Baru
                    </span>
                  </div>
                </div>
                <div class="flex flex-col self-stretch mb-4 gap-1">
                  <div class="flex flex-col items-start self-stretch pl-3">
                    <span class="text-slate-400 text-[11px] font-bold">
                      VERIFIKASI &amp; IZIN
                    </span>
                  </div>
                  <div
                    class="flex justify-between items-center self-stretch py-2 px-3 rounded-lg"
                  >
                    <div class="flex shrink-0 items-center gap-3">
                      <img
                        src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/jvu5tca6_expires_30_days.png"
                        class="w-5 h-5 object-fill"
                      />
                      <a href="verifikasi-surat-absensi.php" class="flex items-center flex-1"><span class="text-slate-600 text-sm">
                        Verifikasi Surat
                      </span></a>
                    </div>
                    <div
                      class="flex flex-col shrink-0 items-start bg-[#F59E0B26] py-0.5 px-2 rounded-xl"
                    >
                      <span class="text-[#F59E0B] text-[11px] font-bold">
                        5
                      </span>
                    </div>
                  </div>
                  <div class="flex items-center self-stretch py-2 rounded-lg">
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/ih3ldnln_expires_30_days.png"
                      class="w-5 h-5 mx-3 rounded-lg object-fill"
                    />
                    <a href="histori-verifikasi-surat.php" class="flex items-center w-full"><span class="text-slate-600 text-sm">
                      Histori Verifikasi
                    </span></a>
                  </div>
                </div>
                <div class="flex flex-col self-stretch mb-4 gap-1">
                  <div class="flex flex-col items-start self-stretch pl-3">
                    <span class="text-slate-400 text-[11px] font-bold">
                      PRESENSI &amp; LAPORAN
                    </span>
                  </div>
                  <div class="flex items-center self-stretch py-2 rounded-lg">
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/7i4zaxi7_expires_30_days.png"
                      class="w-5 h-5 mx-3 rounded-lg object-fill"
                    />
                    <a href="rekap-absensi-siswa.php" class="flex items-center w-full"><span class="text-slate-600 text-sm">
                      Rekap Absensi Siswa
                    </span></a>
                  </div>
                </div>
                <div class="flex flex-col self-stretch mb-[209px] gap-1">
                  <div class="flex flex-col items-start self-stretch pl-3">
                    <span class="text-slate-400 text-[11px] font-bold">
                      KONFIGURASI
                    </span>
                  </div>
                  <div
                    class="flex items-center self-stretch py-2 px-3 gap-3 rounded-lg"
                  >
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/j6943hiq_expires_30_days.png"
                      class="w-5 h-5 rounded-lg object-fill"
                    />
                    <div class="flex flex-1 flex-col items-start">
                      <span class="text-slate-600 text-sm">
                        Pengaturan &amp; Master Data
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="self-stretch bg-white p-4">
              <div
                class="flex justify-center items-center self-stretch bg-slate-50 py-[11px] gap-[26px] rounded-lg border border-solid border-slate-200"
              >
                <div class="flex shrink-0 items-center gap-2">
                  <div class="bg-[#006C4A] w-2.5 h-2.5 rounded-xl"></div>
                  <span class="text-slate-600 text-[11px]">
                    Status Database
                  </span>
                </div>
                <div
                  class="flex flex-col shrink-0 items-start bg-[#006C4A1A] py-0.5 px-2 rounded-md"
                >
                  <span class="text-[#006C4A] text-[11px] font-bold">
                    Terhubung Aktif
                  </span>
                </div>
              </div>
            </div>
          </div>
          <div class="flex-1 relative">
            <div class="self-stretch bg-slate-50 pb-[1277px]">
              <div
                class="flex items-center self-stretch bg-[#FFFFFFF0] py-[11px]"
                style="box-shadow: 0px 1px 2px #0f172a05"
              >
                <button
                  class="flex flex-1 justify-center items-center bg-[#F2F3FF] text-left py-[7px] ml-[41px] mr-[31px] gap-2 rounded-lg border border-solid border-slate-200"
                  onclick="alert('Pressed!')"
                  }
                >
                  <img
                    src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/lddfl2kn_expires_30_days.png"
                    class="w-3 h-[13px] rounded-lg object-fill"
                  />
                  <span class="text-slate-600 text-[11px]">
                    Semester: Ganjil
                  </span>
                  <span class="text-slate-900 text-[11px] font-bold">
                    T.A. 2026/2027 Ganjil
                  </span>
                </button>
                <div
                  class="flex flex-1 items-center bg-slate-50 mr-[13px] gap-[9px] rounded-lg border border-solid border-slate-200"
                >
                  <img
                    src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/xmsx90td_expires_30_days.png"
                    class="w-7 h-[30px] object-fill"
                  />
                  <div class="flex flex-1 items-center">
                    <div class="flex-1 h-4"></div>
                    <div class="w-[11px] h-2"></div>
                  </div>
                </div>
                <div class="flex flex-1 justify-between items-center mr-[21px]">
                  <img
                    src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/u5jcvt1w_expires_30_days.png"
                    class="w-[38px] h-[38px] rounded-lg object-fill"
                  />
                  <div class="flex shrink-0 items-center px-1 gap-3">
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/h05766cl_expires_30_days.png"
                      class="w-8 h-8 rounded-xl object-fill"
                    />
                    <div class="flex flex-col shrink-0 items-center">
                      <div class="flex flex-col items-start">
                        <span class="text-slate-900 text-sm font-bold">
                          Ust. H. Ahmad Zulfikar
                        </span>
                        <span
                          class="text-slate-400 text-[11px] font-bold mr-[15px]"
                        >
                          Super Admin / Tata Usaha
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div
              class="self-stretch absolute bottom-[-48px] right-8 left-8 pt-1.5"
            >
              <div class="flex justify-between items-center self-stretch mb-1">
                <div class="flex shrink-0 items-center">
                  <span class="text-slate-400 text-xs mr-2">
                    Manajemen Guru
                  </span>
                  <img
                    src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/sz35e3ot_expires_30_days.png"
                    class="w-1 h-2 mr-[7px] object-fill"
                  />
                  <span class="text-slate-400 text-xs mr-[9px]">
                    Atur Penugasan Guru
                  </span>
                  <img
                    src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/cdx0old5_expires_30_days.png"
                    class="w-1 h-2 mr-2 object-fill"
                  />
                  <span class="text-slate-900 text-xs font-bold">
                    Tambah Penugasan Baru
                  </span>
                </div>
                <div
                  class="flex shrink-0 items-center bg-[#006C4A1A] py-1 px-3 gap-2 rounded-xl"
                >
                  <div class="bg-[#006C4A] w-2 h-2 rounded-xl"></div>
                  <span class="text-[#006C4A] text-[11px] font-bold">
                    MODE PEMETAAN AKTIF
                  </span>
                </div>
              </div>
              <div
                class="flex flex-col items-start self-stretch bg-white relative p-6 mb-3.5 rounded-lg"
                style="box-shadow: 0px 1px 2px #0000000d"
              >
                <div
                  class="flex-1 w-[200px] absolute top-0 bottom-0 right-0 rounded-xl blur-[40px]"
                  style="
                    background: linear-gradient(
                      180deg,
                      #eff6ff,
                      #dae2fd66,
                      #dae2fd00
                    );
                  "
                ></div>
                <div class="flex items-center self-stretch gap-[41px]">
                  <div class="flex flex-1 flex-col items-start gap-1">
                    <div class="flex items-center self-stretch gap-2">
                      <img
                        src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/q4gch9ns_expires_30_days.png"
                        class="w-8 h-8 rounded object-fill"
                      />
                      <span class="text-slate-900 text-2xl font-bold">
                        Tambah &amp; Alokasikan Penugasan Guru
                      </span>
                    </div>
                    <span class="text-slate-600 text-sm w-[673px]">
                      Plotting beban mengajar mingguan (JJM), distribusi
                      multi-mapel yang diampu, dan konfigurasi alokasi<br />kelas
                      rombel semester ganjil 2026/2027.
                    </span>
                  </div>
                  <div
                    class="flex items-center bg-slate-50 w-[165px] py-2 px-3 gap-2 rounded"
                  >
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/53kknzbb_expires_30_days.png"
                      class="w-4 h-[15px] rounded object-fill"
                    />
                    <div class="flex flex-1 flex-col items-start">
                      <div class="flex flex-col items-start self-stretch">
                        <span class="text-slate-400 text-[11px] font-bold">
                          Validasi Simpatika
                        </span>
                      </div>
                      <span class="text-[#006C4A] text-[11px] font-bold">
                        Terintegrasi Kemenag
                      </span>
                    </div>
                  </div>
                </div>
              </div>
              <div class="flex items-start self-stretch mb-7 gap-6">
                <div class="flex flex-1 flex-col gap-6">
                  <div
                    class="flex flex-col self-stretch bg-white p-6 gap-4 rounded-lg"
                    style="box-shadow: 0px 1px 2px #0000000d"
                  >
                    <div class="flex justify-between items-center self-stretch">
                      <div class="flex shrink-0 items-center gap-2.5">
                        <button
                          class="flex flex-col shrink-0 items-start bg-blue-600 text-left py-[5px] px-[11px] rounded border-0"
                          onclick="return false;"
                        >
                          <span class="text-white text-xs font-bold"> 1 </span>
                        </button>
                        <span class="text-slate-900 text-base font-bold">
                          Pemilihan Tenaga Pendidik &amp; Periode
                        </span>
                      </div>
                      <span class="text-slate-400 text-[11px] font-bold">
                        Langkah 1 dari 3
                      </span>
                    </div>
                    <div class="flex flex-col self-stretch gap-1">
                      <div class="flex flex-col items-start self-stretch">
                        <span class="text-slate-900 text-xs font-bold">
                          Nama Guru / Pendidik *
                        </span>
                      </div>
                      <div
                        class="flex justify-between items-center self-stretch bg-slate-50 p-2 rounded-lg"
                      >
                        <div class="flex items-center w-[376px] gap-3">
                          <img
                            src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/tsnw8atu_expires_30_days.png"
                            class="w-11 h-11 rounded-xl object-fill"
                          />
                          <div class="flex-1">
                            <div
                              class="flex flex-col items-center self-stretch"
                            >
                              <span class="text-slate-900 text-sm font-bold">
                                Bu Siti Rahmawati, M.Pd
                              </span>
                            </div>
                            <div class="flex items-center self-stretch">
                              <span class="text-slate-400 text-xs mr-2">
                                NIP. 198709182011012014
                              </span>
                              <span class="text-[#C3C6D7] text-xs mr-[9px]">
                                •
                              </span>
                              <span class="text-slate-600 text-xs">
                                Guru IPA &amp; Biologi Terapan
                              </span>
                            </div>
                          </div>
                        </div>
                        <img
                          src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/99vpt2ad_expires_30_days.png"
                          class="w-[29px] h-[37px] rounded object-fill"
                        />
                      </div>
                      <div
                        class="flex justify-center items-center self-stretch bg-[#F2F3FF] py-3 gap-11 rounded"
                      >
                        <div class="flex shrink-0 items-center gap-2">
                          <img
                            src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/zv11v2bp_expires_30_days.png"
                            class="w-[15px] h-[15px] object-fill"
                          />
                          <span class="text-slate-600 text-xs">
                            Saat ini: 0 JJM dialokasikan
                          </span>
                        </div>
                        <div class="flex shrink-0 items-center gap-[7px]">
                          <span class="text-slate-600 text-[11px] font-bold">
                            Target Wajib Kemenag:
                          </span>
                          <div
                            class="flex flex-col shrink-0 items-start bg-white py-0.5 px-2 rounded-sm"
                          >
                            <span class="text-slate-900 text-[11px] font-bold">
                              24 JJM / Minggu
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="flex flex-col self-stretch pt-1 gap-4">
                      <div class="flex items-center self-stretch gap-4">
                        <div class="flex flex-col w-[233px] gap-1">
                          <div class="flex flex-col items-start self-stretch">
                            <span class="text-slate-900 text-xs font-bold">
                              Tahun Akademik &amp; Semester *
                            </span>
                          </div>
                          <button
                            class="flex items-start self-stretch bg-slate-50 text-left py-2 px-3 gap-[17px] rounded border-0"
                            onclick="alert('Pressed!')"
                            }
                          >
                            <span class="text-slate-900 text-sm">
                              Semester Ganjil 2026/2027 (Juli - Des 2026)
                            </span>
                            <img
                              src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/bh578r1w_expires_30_days.png"
                              class="w-[9px] h-[5px] object-fill"
                            />
                          </button>
                        </div>
                        <div class="flex flex-col w-[233px] gap-1">
                          <div class="flex flex-col items-start self-stretch">
                            <span class="text-slate-900 text-xs font-bold">
                              Nomor SK Pembagian Tugas *
                            </span>
                          </div>
                          <div
                            class="flex flex-col items-start self-stretch bg-slate-50 py-2 px-3 rounded"
                          >
                            <span class="text-slate-900 text-sm">
                              SK-088/MTsN/PP.00.4/07/2026
                            </span>
                          </div>
                        </div>
                      </div>
                      <div class="flex flex-col items-start self-stretch gap-1">
                        <div class="flex flex-col items-start self-stretch">
                          <span class="text-slate-900 text-xs font-bold">
                            Tanggal Penetapan Surat Keputusan
                          </span>
                        </div>
                        <div
                          class="flex items-center bg-slate-50 gap-[11px] rounded"
                        >
                          <img
                            src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/5vay3owc_expires_30_days.png"
                            class="w-[25px] h-9 object-fill"
                          />
                          <div
                            class="flex flex-col shrink-0 items-start pr-[262px]"
                          >
                            <span class="text-slate-900 text-sm">
                              15/07/2026
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div
                    class="flex flex-col self-stretch bg-white p-6 gap-4 rounded-lg"
                    style="box-shadow: 0px 1px 2px #0000000d"
                  >
                    <div class="flex items-center self-stretch gap-3.5">
                      <div class="flex flex-1 items-center gap-2.5">
                        <div
                          class="flex flex-col shrink-0 items-start bg-blue-600 py-[5px] px-1.5 rounded"
                        >
                          <span class="text-white text-xs font-bold"> 2 </span>
                        </div>
                        <div class="flex-1">
                          <div class="flex flex-col items-start self-stretch">
                            <span class="text-slate-900 text-base font-bold">
                              Mata Pelajaran yang Diampu (Multi-Mapel)
                            </span>
                          </div>
                          <div class="flex flex-col items-start self-stretch">
                            <span class="text-slate-400 text-xs w-80">
                              Guru dapat mengampu lebih dari 1 mata pelajaran
                              sesuai<br />kualifikasi rumpun ilmu.
                            </span>
                          </div>
                        </div>
                      </div>
                      <div
                        class="flex flex-col shrink-0 items-start bg-[#004AC61A] py-0.5 px-2 rounded-sm"
                      >
                        <span class="text-[#004AC6] text-[11px] font-bold">
                          Multi-Mapel Aktif
                        </span>
                      </div>
                    </div>
                    <div class="flex flex-col self-stretch gap-2">
                      <div
                        class="flex items-center self-stretch bg-slate-50 p-2 gap-[18px] rounded-lg"
                      >
                        <div class="flex flex-1 items-center gap-3">
                          <img
                            src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/unf9c6uy_expires_30_days.png"
                            class="w-10 h-10 rounded object-fill"
                          />
                          <div class="flex flex-1 flex-col gap-0.5">
                            <div class="flex items-center self-stretch gap-2">
                              <div class="flex flex-1 flex-col items-start">
                                <span
                                  class="text-slate-900 text-base font-bold w-[163px]"
                                >
                                  IPA Terpadu (Fisika &amp;<br />Biologi)
                                </span>
                              </div>
                              <div
                                class="flex flex-col shrink-0 items-start bg-[#006C4A26] py-0.5 pl-2 pr-[37px] rounded-sm"
                              >
                                <span
                                  class="text-[#006C4A] text-[11px] font-bold w-10"
                                >
                                  4 JJM /<br />Rombel
                                </span>
                              </div>
                            </div>
                            <div class="flex items-center self-stretch">
                              <div
                                class="flex shrink-0 items-center mr-2 gap-1"
                              >
                                <img
                                  src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/bbi6psqw_expires_30_days.png"
                                  class="w-[13px] h-[13px] object-fill"
                                />
                                <span
                                  class="text-[#006C4A] text-[11px] font-bold"
                                >
                                  Linear Simpatika ✓
                                </span>
                              </div>
                              <span
                                class="text-[#C3C6D7] text-[11px] font-bold mr-[9px]"
                              >
                                •
                              </span>
                              <span class="text-slate-400 text-xs">
                                Kurikulum Merdeka MTs
                              </span>
                            </div>
                          </div>
                        </div>
                        <div class="flex shrink-0 items-center gap-[9px]">
                          <div
                            class="flex flex-col shrink-0 items-start bg-white py-1 pl-2.5 pr-[30px] rounded-md"
                          >
                            <span
                              class="text-slate-600 text-[11px] font-bold w-[34px]"
                            >
                              Mapel<br />Utama
                            </span>
                          </div>
                          <img
                            src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/pjnzr0iu_expires_30_days.png"
                            class="w-[25px] h-8 rounded object-fill"
                          />
                        </div>
                      </div>
                      <div
                        class="flex items-center self-stretch bg-slate-50 p-2 gap-[18px] rounded-lg"
                      >
                        <div class="flex flex-1 items-center gap-3">
                          <img
                            src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/i7xtuwcj_expires_30_days.png"
                            class="w-10 h-10 rounded object-fill"
                          />
                          <div class="flex flex-1 flex-col gap-0.5">
                            <div class="flex items-center self-stretch gap-2">
                              <div class="flex flex-1 flex-col items-start">
                                <span
                                  class="text-slate-900 text-base font-bold w-[118px]"
                                >
                                  Prakarya &amp;<br />Kewirausahaan
                                </span>
                              </div>
                              <div
                                class="flex flex-col shrink-0 items-start bg-[#F59E0B33] py-0.5 pl-2 pr-10 rounded-sm"
                              >
                                <span
                                  class="text-[#BC4800] text-[11px] font-bold w-10"
                                >
                                  2 JJM /<br />Rombel
                                </span>
                              </div>
                            </div>
                            <div class="flex items-center self-stretch">
                              <div
                                class="flex shrink-0 items-center mr-2 gap-1"
                              >
                                <img
                                  src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/vc19s6k7_expires_30_days.png"
                                  class="w-[13px] h-[13px] object-fill"
                                />
                                <span
                                  class="text-[#006C4A] text-[11px] font-bold w-[126px]"
                                >
                                  Linear Rumpun Terapan<br />✓
                                </span>
                              </div>
                              <span
                                class="text-[#C3C6D7] text-[11px] font-bold mr-[9px]"
                              >
                                •
                              </span>
                              <div
                                class="flex flex-col shrink-0 items-start pr-[37px]"
                              >
                                <span class="text-slate-400 text-xs w-[74px]">
                                  Keterampilan<br />Mandiri
                                </span>
                              </div>
                            </div>
                          </div>
                        </div>
                        <div class="flex shrink-0 items-center gap-[9px]">
                          <div
                            class="flex flex-col shrink-0 items-start bg-white py-1 pl-2.5 pr-[34px] rounded-md"
                          >
                            <span
                              class="text-slate-600 text-[11px] font-bold w-[35px]"
                            >
                              Mapel<br />Pilihan
                            </span>
                          </div>
                          <img
                            src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/jydeanf2_expires_30_days.png"
                            class="w-[25px] h-8 rounded object-fill"
                          />
                        </div>
                      </div>
                    </div>
                    <div class="flex items-center self-stretch py-1 gap-2">
                      <div
                        class="flex flex-1 items-center bg-slate-50 py-2 px-3 gap-2 rounded"
                      >
                        <div class="flex flex-1 flex-col items-start">
                          <span class="text-slate-600 text-xs">
                            + Pilih mata pelajaran lain untuk ditambahkan...
                          </span>
                        </div>
                        <img
                          src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/d9d439o0_expires_30_days.png"
                          class="w-[15px] h-[15px] object-fill"
                        />
                      </div>
                      <button
                        class="flex shrink-0 items-center bg-blue-50 text-left py-2 px-4 gap-1.5 rounded border-0"
                        onclick="return false;"
                      >
                        <img
                          src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/2rt9jbfi_expires_30_days.png"
                          class="w-2.5 h-2.5 rounded object-fill"
                        />
                        <span class="text-[#004AC6] text-xs font-bold">
                          Tambah Mapel
                        </span>
                      </button>
                    </div>
                    <div class="flex flex-col self-stretch pt-[9px] gap-2">
                      <div
                        class="flex justify-between items-center self-stretch"
                      >
                        <div class="flex shrink-0 items-center gap-1.5">
                          <img
                            src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/a72l7lh0_expires_30_days.png"
                            class="w-[7px] h-[15px] object-fill"
                          />
                          <span class="text-slate-900 text-xs font-bold">
                            Tugas Tambahan &amp; Ekuivalensi Beban (JJM)
                          </span>
                        </div>
                        <span class="text-slate-400 text-[11px] font-bold">
                          Maks. ekuivalen 12 JJM
                        </span>
                      </div>
                      <div class="flex items-center self-stretch">
                        <div
                          class="flex items-start bg-[#EFF6FF80] w-[155px] p-3 mr-2 gap-2.5 rounded"
                        >
                          <div
                            class="flex flex-col shrink-0 items-center pt-0.5"
                          >
                            <div
                              class="bg-[#0075FF] w-[13px] h-[13px] rounded-sm"
                            ></div>
                          </div>
                          <div class="flex flex-1 flex-col gap-[1px]">
                            <div
                              class="flex flex-col items-center self-stretch mr-[15px]"
                            >
                              <span
                                class="text-slate-900 text-[11px] font-bold w-[92px]"
                              >
                                Kepala<br />Laboratorium IPA
                              </span>
                            </div>
                            <div
                              class="flex flex-col items-center self-stretch"
                            >
                              <span class="text-[#004AC6] text-xs font-bold">
                                +12 JJM Ekuivalen
                              </span>
                            </div>
                          </div>
                        </div>
                        <div
                          class="flex shrink-0 items-start bg-[#EFF6FF80] p-3 mr-[9px] gap-2.5 rounded"
                        >
                          <div
                            class="flex flex-col shrink-0 items-center pt-0.5"
                          >
                            <div
                              class="bg-[#0075FF] w-[13px] h-[13px] rounded-sm"
                            ></div>
                          </div>
                          <div
                            class="flex flex-col shrink-0 items-center relative"
                          >
                            <div class="flex flex-col items-center pt-[29px]">
                              <span class="text-[#004AC6] text-xs font-bold">
                                +2 JJM Ekuivalen
                              </span>
                            </div>
                            <span
                              class="text-slate-900 text-[11px] font-bold w-[108px] absolute top-0 left-[-6px]"
                            >
                              Wali Kelas<br />8B
                            </span>
                          </div>
                        </div>
                        <div
                          class="flex items-start bg-slate-50 w-[155px] p-3 gap-2.5 rounded"
                        >
                          <div
                            class="flex flex-col shrink-0 items-center pt-0.5"
                          >
                            <div
                              class="bg-white w-[13px] h-[13px] rounded-sm border border-solid border-[#767676]"
                            ></div>
                          </div>
                          <div class="flex flex-1 flex-col gap-[1px]">
                            <div
                              class="flex flex-col items-center self-stretch"
                            >
                              <span
                                class="text-slate-900 text-[11px] w-[103px]"
                              >
                                Pembina Ekskul KIR<br />/ Robotik
                              </span>
                            </div>
                            <div
                              class="flex flex-col items-center self-stretch"
                            >
                              <span class="text-slate-400 text-xs">
                                +2 JJM Ekuivalen
                              </span>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="flex flex-col w-[372px] gap-6">
                  <div
                    class="flex flex-col self-stretch bg-white p-6 gap-4 rounded-lg"
                    style="box-shadow: 0px 1px 2px #0000000d"
                  >
                    <div class="flex items-center self-stretch">
                      <div class="flex flex-1 items-center gap-2.5">
                        <button
                          class="flex flex-col shrink-0 items-start bg-blue-600 text-left py-[5px] px-2.5 rounded border-0"
                          onclick="return false;"
                        >
                          <span class="text-white text-xs font-bold"> 3 </span>
                        </button>
                        <div class="flex flex-1 flex-col items-start">
                          <span
                            class="text-slate-900 text-base font-bold w-[134px]"
                          >
                            Distribusi Alokasi<br />Rombel
                          </span>
                        </div>
                      </div>
                      <div class="flex flex-col shrink-0 items-start pr-[46px]">
                        <span
                          class="text-slate-400 text-[11px] font-bold w-[49px]"
                        >
                          Per Mata<br />Pelajaran
                        </span>
                      </div>
                    </div>
                    <div class="flex flex-col self-stretch">
                      <span class="text-slate-600 text-xs">
                        Tentukan kelas mana saja yang diampu untuk masing-<br />masing
                        mata pelajaran yang telah dipilih di samping.
                      </span>
                    </div>
                    <div
                      class="flex flex-col self-stretch bg-slate-50 p-3 gap-1 rounded-lg"
                    >
                      <div
                        class="flex justify-between items-center self-stretch"
                      >
                        <div class="flex shrink-0 items-center gap-2">
                          <div class="bg-blue-600 w-2.5 h-2.5 rounded-xl"></div>
                          <span class="text-slate-900 text-sm font-bold">
                            IPA Terpadu
                          </span>
                        </div>
                        <div
                          class="flex flex-col shrink-0 items-start bg-blue-50 py-0.5 px-2 rounded-sm"
                        >
                          <span class="text-[#004AC6] text-[11px] font-bold">
                            4 JJM / Rombel
                          </span>
                        </div>
                      </div>
                      <div class="flex flex-col self-stretch pt-2 gap-2">
                        <div class="flex items-center self-stretch gap-2">
                          <div
                            class="flex shrink-0 items-center bg-[#FFFFFF00] p-2.5 gap-[21px] rounded"
                          >
                            <div class="flex items-center w-[72px] gap-2">
                              <div
                                class="bg-[#0075FF] w-[13px] h-[13px] rounded-sm"
                              ></div>
                              <div
                                class="flex flex-1 flex-col items-start pb-[1px] gap-0.5"
                              >
                                <div
                                  class="flex flex-col items-start self-stretch"
                                >
                                  <span
                                    class="text-slate-900 text-xs font-bold"
                                  >
                                    Kelas 8A
                                  </span>
                                </div>
                                <span class="text-slate-400 text-xs">
                                  32 Siswa
                                </span>
                              </div>
                            </div>
                            <span class="text-[#004AC6] text-[11px] font-bold">
                              4 JJM
                            </span>
                          </div>
                          <div
                            class="flex shrink-0 items-center bg-[#FFFFFF00] p-2.5 gap-[21px] rounded"
                          >
                            <div class="flex items-center w-[72px] gap-2">
                              <div
                                class="bg-[#0075FF] w-[13px] h-[13px] rounded-sm"
                              ></div>
                              <div
                                class="flex flex-1 flex-col items-start pb-[1px] gap-0.5"
                              >
                                <div
                                  class="flex flex-col items-start self-stretch"
                                >
                                  <span
                                    class="text-slate-900 text-xs font-bold"
                                  >
                                    Kelas 8B
                                  </span>
                                </div>
                                <span class="text-slate-400 text-xs">
                                  32 Siswa
                                </span>
                              </div>
                            </div>
                            <span class="text-[#004AC6] text-[11px] font-bold">
                              4 JJM
                            </span>
                          </div>
                        </div>
                        <div class="flex items-center self-stretch gap-2">
                          <div
                            class="flex shrink-0 items-center bg-[#FFFFFF00] p-2.5 gap-[21px] rounded"
                          >
                            <div class="flex items-center w-[72px] gap-2">
                              <div
                                class="bg-[#0075FF] w-[13px] h-[13px] rounded-sm"
                              ></div>
                              <div
                                class="flex flex-1 flex-col items-start pb-[1px] gap-0.5"
                              >
                                <div
                                  class="flex flex-col items-start self-stretch"
                                >
                                  <span
                                    class="text-slate-900 text-xs font-bold"
                                  >
                                    Kelas 8C
                                  </span>
                                </div>
                                <span class="text-slate-400 text-xs">
                                  32 Siswa
                                </span>
                              </div>
                            </div>
                            <span class="text-[#004AC6] text-[11px] font-bold">
                              4 JJM
                            </span>
                          </div>
                          <div
                            class="flex shrink-0 items-center bg-white p-2.5 gap-3.5 rounded"
                          >
                            <div class="flex items-center w-[72px] gap-2">
                              <div
                                class="bg-white w-[13px] h-[13px] rounded-sm border border-solid border-[#767676]"
                              ></div>
                              <div
                                class="flex flex-1 flex-col items-start pb-[1px] gap-0.5"
                              >
                                <div
                                  class="flex flex-col items-start self-stretch"
                                >
                                  <span class="text-slate-600 text-xs">
                                    Kelas 7A
                                  </span>
                                </div>
                                <span class="text-slate-400 text-xs">
                                  30 Siswa
                                </span>
                              </div>
                            </div>
                            <span class="text-slate-400 text-[11px] font-bold">
                              +4 JJM
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div
                      class="flex flex-col self-stretch bg-slate-50 p-3 gap-1 rounded-lg"
                    >
                      <div class="flex items-center self-stretch gap-0.5">
                        <div class="flex flex-1 items-center gap-2">
                          <div
                            class="bg-[#F59E0B] w-2.5 h-2.5 rounded-xl"
                          ></div>
                          <div class="flex flex-1 flex-col items-start">
                            <span class="text-slate-900 text-sm font-bold">
                              Prakarya &amp; Kewirausahaan
                            </span>
                          </div>
                        </div>
                        <div
                          class="flex flex-col shrink-0 items-start bg-[#F59E0B26] py-0.5 px-2 rounded-sm"
                        >
                          <span class="text-[#F59E0B] text-[11px] font-bold">
                            2 JJM / Rombel
                          </span>
                        </div>
                      </div>
                      <div class="flex flex-col self-stretch pt-2 gap-2">
                        <div class="flex items-center self-stretch gap-2">
                          <div
                            class="flex items-center bg-[#FFFFFF00] w-[146px] p-2.5 gap-[1px] rounded"
                          >
                            <div class="flex flex-1 items-center gap-2">
                              <div
                                class="bg-[#0075FF] w-[13px] h-[13px] rounded-sm"
                              ></div>
                              <div
                                class="flex flex-1 flex-col items-start pb-[1px] gap-0.5"
                              >
                                <div
                                  class="flex flex-col items-start self-stretch"
                                >
                                  <span
                                    class="text-slate-900 text-xs font-bold"
                                  >
                                    Kelas 9A
                                  </span>
                                </div>
                                <span class="text-slate-400 text-xs">
                                  Unggulan (32 Siswa)
                                </span>
                              </div>
                            </div>
                            <span class="text-[#F59E0B] text-[11px] font-bold">
                              2 JJM
                            </span>
                          </div>
                          <div
                            class="flex items-center bg-[#FFFFFF00] w-[146px] p-2.5 gap-[1px] rounded"
                          >
                            <div class="flex flex-1 items-center gap-2">
                              <div
                                class="bg-[#0075FF] w-[13px] h-[13px] rounded-sm"
                              ></div>
                              <div
                                class="flex flex-1 flex-col items-start pb-[1px] gap-0.5"
                              >
                                <div
                                  class="flex flex-col items-start self-stretch"
                                >
                                  <span
                                    class="text-slate-900 text-xs font-bold"
                                  >
                                    Kelas 9B
                                  </span>
                                </div>
                                <span class="text-slate-400 text-xs">
                                  Reguler (32 Siswa)
                                </span>
                              </div>
                            </div>
                            <span class="text-[#F59E0B] text-[11px] font-bold">
                              2 JJM
                            </span>
                          </div>
                        </div>
                        <div class="flex items-center self-stretch gap-2">
                          <div
                            class="flex items-center bg-white w-[146px] p-2.5 gap-[1px] rounded"
                          >
                            <div class="flex flex-1 items-center gap-2">
                              <div
                                class="bg-white w-[13px] h-[13px] rounded-sm border border-solid border-[#767676]"
                              ></div>
                              <div
                                class="flex flex-1 flex-col items-start pb-[1px] gap-0.5"
                              >
                                <div
                                  class="flex flex-col items-start self-stretch"
                                >
                                  <span class="text-slate-600 text-xs">
                                    Kelas 9C
                                  </span>
                                </div>
                                <span class="text-slate-400 text-xs">
                                  Reguler (30 Siswa)
                                </span>
                              </div>
                            </div>
                            <span class="text-slate-400 text-[11px] font-bold">
                              +2 JJM
                            </span>
                          </div>
                          <div
                            class="flex items-center bg-white w-[146px] p-2.5 gap-[1px] rounded"
                          >
                            <div class="flex flex-1 items-center gap-2">
                              <div
                                class="bg-white w-[13px] h-[13px] rounded-sm border border-solid border-[#767676]"
                              ></div>
                              <div
                                class="flex flex-1 flex-col items-start pb-[1px] gap-0.5"
                              >
                                <div
                                  class="flex flex-col items-start self-stretch"
                                >
                                  <span class="text-slate-600 text-xs">
                                    Kelas 9D
                                  </span>
                                </div>
                                <span class="text-slate-400 text-xs">
                                  Reguler (31 Siswa)
                                </span>
                              </div>
                            </div>
                            <span class="text-slate-400 text-[11px] font-bold">
                              +2 JJM
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div
                    class="flex flex-col self-stretch bg-white p-4 gap-2 rounded-lg"
                    style="box-shadow: 0px 1px 2px #0000000d"
                  >
                    <div
                      class="flex flex-col items-start self-stretch pb-[5px]"
                    >
                      <span class="text-slate-900 text-base font-bold">
                        Otomasi Sistem &amp; Notifikasi Guru
                      </span>
                    </div>
                    <div class="flex flex-col self-stretch pt-1 gap-2">
                      <div class="flex items-start self-stretch gap-3">
                        <div class="flex flex-col shrink-0 items-center pt-0.5">
                          <div
                            class="items-start bg-[#004AC6] py-0.5 pl-[18px] pr-0.5 rounded-xl"
                          >
                            <div class="bg-white w-4 h-4 rounded-xl"></div>
                          </div>
                        </div>
                        <div class="flex-1">
                          <div class="flex flex-col items-start self-stretch">
                            <span class="text-slate-900 text-xs font-bold">
                              Perbarui Jadwal Pelajaran Per Tahun Ajaran
                            </span>
                          </div>
                          <div class="flex flex-col items-start self-stretch">
                            <span class="text-slate-400 text-xs w-[257px]">
                              Otomatis sinkronkan rombel baru ke jadwal di<br />Portal
                              Web &amp; Aplikasi Mobile Guru.
                            </span>
                          </div>
                        </div>
                      </div>
                      <div class="flex items-start self-stretch gap-3">
                        <div class="flex flex-col shrink-0 items-center pt-0.5">
                          <div
                            class="items-start bg-[#004AC6] py-0.5 pl-[18px] pr-0.5 rounded-xl"
                          >
                            <div class="bg-white w-4 h-4 rounded-xl"></div>
                          </div>
                        </div>
                        <div class="flex-1">
                          <div class="flex flex-col items-start self-stretch">
                            <span class="text-slate-900 text-xs font-bold">
                              Kirim Notifikasi Draf Penugasan
                            </span>
                          </div>
                          <div class="flex flex-col self-stretch">
                            <span class="text-slate-400 text-xs">
                              Kirim draf SK dan plotting jam ke madrasah guru
                              terkait.
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div
                class="flex items-center self-stretch bg-[#FFFFFF00] p-4 mb-[149px] mx-0.5 gap-[51px] rounded-lg"
                style="box-shadow: 0px 4px 6px #0000001a"
              >
                <div class="flex items-center w-[337px] gap-3">
                  <img
                    src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/j24f4c4h_expires_30_days.png"
                    class="w-10 h-10 rounded-xl object-fill"
                  />
                  <div class="flex flex-1 flex-col items-start">
                    <div class="flex flex-col items-start self-stretch">
                      <span class="text-slate-900 text-sm font-bold">
                        Konfigurasi Penugasan Lengkap
                      </span>
                    </div>
                    <span class="text-slate-600 text-xs w-[285px]">
                      2 Mata Pelajaran • 5 Rombongan Belajar • 30 JJM<br />Terakumulasi
                    </span>
                  </div>
                </div>
                <div class="flex shrink-0 items-center gap-2">
                  <button
                    class="flex flex-col shrink-0 items-start bg-slate-50 text-left py-2.5 px-8 rounded border-0"
                    onclick="alert('Pressed!')"
                    }
                  >
                    <span class="text-slate-600 text-sm text-center w-[53px]">
                      Batal &amp;<br />Kembali
                    </span>
                  </button>
                  <div
                    class="flex shrink-0 items-center bg-white py-2.5 px-4 gap-[7px] rounded"
                  >
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/pcxue1zp_expires_30_days.png"
                      class="w-[13px] h-[13px] rounded object-fill"
                    />
                    <div class="flex flex-col shrink-0 items-start px-2">
                      <span class="text-slate-900 text-sm text-center w-[50px]">
                        Simpan<br />Draf
                      </span>
                    </div>
                  </div>
                  <div
                    class="flex shrink-0 items-center bg-[#FFFFFF00] py-2.5 px-5 gap-[7px] rounded"
                    style="box-shadow: 0px 2px 4px #0000001a"
                  >
                    <img
                      src="https://storage.googleapis.com/tagjs-prod.appspot.com/v1/X5CsluynKR/oyhuel78_expires_30_days.png"
                      class="w-3.5 h-3 rounded object-fill"
                    />
                    <div class="flex flex-col shrink-0 items-start px-[19px]">
                      <span
                        class="text-white text-sm font-bold text-center w-[152px]"
                      >
                        Simpan &amp; Publikasikan<br />Penugasan
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  
<script>
(function () {
  const storageKey = 'matsanam_assignment_draft';

  function notify(message) {
    const box = document.createElement('div');
    box.textContent = message;
    box.style.cssText = 'position:fixed;right:24px;bottom:24px;background:#0f172a;color:white;padding:12px 16px;border-radius:10px;font:600 13px system-ui;z-index:9999;box-shadow:0 8px 24px rgba(0,0,0,.18)';
    document.body.appendChild(box);
    setTimeout(() => box.remove(), 2200);
  }

  // Simpan status draft sederhana di browser agar tombol pada desain tidak lagi sekadar dummy.
  const saveDraft = () => {
    const draft = {
      teacher: 'Bu Siti Rahmawati, M.Pd',
      semester: 'Ganjil 2026/2027',
      subjects: ['IPA Terpadu', 'Prakarya & Kewirausahaan'],
      rombel: ['8A', '8B', '8C', '9A'],
      savedAt: new Date().toISOString()
    };
    localStorage.setItem(storageKey, JSON.stringify(draft));
    notify('Draf penugasan berhasil disimpan di browser.');
  };

  const allText = document.body.querySelectorAll('span');
  allText.forEach(span => {
    const t = span.textContent.replace(/\s+/g, ' ').trim();
    const clickable = span.closest('button, div');

    if (t === 'Simpan Draf' && clickable) {
      clickable.style.cursor = 'pointer';
      clickable.addEventListener('click', saveDraft);
    }

    if (t === 'Simpan & Publikasikan Penugasan' && clickable) {
      clickable.style.cursor = 'pointer';
      clickable.addEventListener('click', () => {
        saveDraft();
        notify('Penugasan siap dipublikasikan.');
      });
    }

    if (t === 'Batal & Kembali' && clickable) {
      clickable.style.cursor = 'pointer';
      clickable.addEventListener('click', () => window.location.href = 'dashboard.php');
    }
  });

  // Tombol dashboard/penugasan pada desain Figma dibuat menjadi navigasi nyata.
  document.querySelectorAll('button').forEach(btn => {
    const t = btn.textContent.replace(/\s+/g, ' ').trim();
    if (t === 'Semester: Ganjil T.A. 2026/2027 Ganjil') {
      btn.addEventListener('click', () => notify('Semester aktif: Ganjil 2026/2027'));
    }
    if (t === 'Tambah Mapel') {
      btn.addEventListener('click', () => notify('Fitur tambah mata pelajaran siap dihubungkan ke API Laravel.'));
    }
  });
})();
</script>
</body>
</html>
