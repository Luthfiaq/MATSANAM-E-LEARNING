<?php

$content = '<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Penugasan;
use App\Models\PengumpulanTugas;
use App\Models\Nilai;
use Illuminate\Http\Request;

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
            "pengumpulan.nilai"
        ])->findOrFail($tugasId);

        $pengumpulan = $tugas->pengumpulan;

        return view("admin.nilai.detail", compact("tugas", "pengumpulan"));
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
                ]);
            }
        }

        return redirect()->back()
            ->with("success", "Nilai berhasil disimpan");
    }
}
';

file_put_contents(
    'C:/Users/Chrisna/Documents/Projek S3/Projek/MATSANAM-E-LEARNING/web-admin/app/Http/Controllers/Admin/NilaiController.php',
    $content
);

echo "File written successfully\n";