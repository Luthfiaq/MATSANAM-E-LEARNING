<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Penugasan;
use App\Models\PengumpulanTugas;
use App\Models\Nilai;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class NilaiController extends Controller
{
    public function index(Request $request)
    {
        $query = Penugasan::with(["jadwal.kelas", "jadwal.mataPelajaran", "pengumpulan"])
            ->latest();

        if ($request->filled("search")) {
            $query->where("judul", "like", "%" . $request->search . "%");
        }

        if ($request->filled("jenis")) {
            $query->where("jenis", $request->jenis);
        }

        $tugas = $query->paginate(15);

        return view("admin.nilai.index", compact("tugas"));
    }

    public function detail($tugasId)
    {
        $tugas = Penugasan::with([
            "jadwal.kelas", 
            "jadwal.mataPelajaran", 
            "pengumpulan.siswa", 
            "pengumpulan.nilai",
            "pengumpulan.files"
        ])->findOrFail($tugasId);

        $pengumpulan = $tugas->pengumpulan;

        return view("admin.nilai.detail", compact("tugas", "pengumpulan"));
    }

    /** Download a legacy primary submission file through the authenticated Admin route. */
    public function submissionFile(int $submissionId)
    {
        $submission = PengumpulanTugas::findOrFail($submissionId);
        abort_if(blank($submission->file_jawaban), 404, 'Berkas pengumpulan tidak tersedia.');
        abort_unless(Storage::disk('local')->exists($submission->file_jawaban), 404, 'Berkas pengumpulan tidak ditemukan.');

        return Storage::disk('local')->download(
            $submission->file_jawaban,
            basename($submission->file_jawaban),
        );
    }

    /** Download one attachment for an Admin reviewing a task submission. */
    public function submissionAttachmentFile(int $submissionId, int $fileId)
    {
        $submission = PengumpulanTugas::findOrFail($submissionId);
        $attachment = $submission->files()->whereKey($fileId)->firstOrFail();
        $disk = Storage::disk($attachment->disk ?: 'local');
        abort_unless($disk->exists($attachment->file_path), 404, 'Berkas pengumpulan tidak ditemukan.');

        return $disk->download($attachment->file_path, $attachment->original_name);
    }

    public function store(Request $request)
    {
        $request->validate([
            "tugas_id" => "required|exists:penugasan,id",
            "nilai" => "array",
            "catatan" => "array",
        ]);

        $tugas = Penugasan::findOrFail($request->tugas_id);
        $bobot = $tugas->bobot;

        foreach ($request->nilai as $pengumpulanId => $nilaiValue) {
            if ($nilaiValue === null || $nilaiValue === "") {
                continue;
            }

            $nilaiNum = (float) $nilaiValue;
            if ($nilaiNum < 0 || $nilaiNum > $tugas->bobot) {
                continue;
            }

            Nilai::updateOrCreate(
                ["pengumpulan_id" => $pengumpulanId],
                [
                    "nilai" => $nilaiNum,
                    "catatan" => $request->catatan[$pengumpulanId] ?? null,
                    "guru_id" => auth()->id(),
                    "tanggal_penilaian" => now(),
                ]
            );
        }

        return redirect()->back()
            ->with("success", "Nilai berhasil disimpan");
    }
}