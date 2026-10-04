export type StatusVerifikasi = "Disetujui" | "Ditolak";
export type StatusPengajuan = "Menunggu" | "Disetujui" | "Ditolak";

export type JenisSurat =
| "Sakit Dokter"
| "Izin Kepentingan Keluarga"
| "Surat Keterangan Sakit"
| "Dispensasi Lomba"
| "Sakit Puskesmas"
| "Dispensasi Madrasah";

export interface VerifikasiSurat {
id: number;
idBerkas: string;
sumber: string;

namaSiswa: string;
kelas: string;
nisn: string;
inisial: string;

jenisSurat: JenisSurat;
durasi: string;
tanggal: string;
keterangan: string;

namaBerkas: string;
ukuranBerkas: string;
sumberBerkas: string;

waktuVerifikasi: string;
validator: string;

status: StatusVerifikasi;
catatan: string;
}

export interface PengajuanSurat {
id: number;
idBerkas: string;

namaSiswa: string;
kelas: string;
nisn: string;
inisial: string;

jenisSurat: JenisSurat;
durasi: string;
tanggal: string;
keterangan: string;

namaBerkas: string;
ukuranBerkas: string;

diajukanPada: string;
sumberPengajuan: string;

status: StatusPengajuan;
}