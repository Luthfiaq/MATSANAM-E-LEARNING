<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Guru;
use App\Models\Kelas;
use App\Models\MataPelajaran;
use App\Models\PeriodeAkademik;
use App\Models\JadwalPelajaran;
use Illuminate\Http\Request;

class PenugasanController extends Controller
{
    private const JAM_PELAJARAN = [
    1 => ['mulai' => '07:15', 'selesai' => '07:55'],
    2 => ['mulai' => '07:55', 'selesai' => '08:35'],
    3 => ['mulai' => '08:35', 'selesai' => '09:15'],
    4 => ['mulai' => '09:15', 'selesai' => '09:55'],
    5 => ['mulai' => '10:30', 'selesai' => '11:10'],
    6 => ['mulai' => '11:10', 'selesai' => '11:50'],
    7 => ['mulai' => '11:50', 'selesai' => '12:30'],
    8 => ['mulai' => '12:30', 'selesai' => '13:10'],
];
    public function index()
    {
        $jadwal = JadwalPelajaran::with(['guru', 'kelas', 'mataPelajaran', 'periode'])
            ->paginate(15);

        return view('admin.penugasan.index', compact('jadwal'));
    }

    public function create()
    {
        $guru = Guru::with('user')->get();
        $kelas = Kelas::all();
        $mataPelajaran = MataPelajaran::all();
        $periode = PeriodeAkademik::where('is_active', true)->get();

        return view('admin.penugasan.create', compact(
            'guru',
            'kelas',
            'mataPelajaran',
            'periode'
        ));
    }

    public function store(Request $request)
{
    $validated = $request->validate([
        'periode_id' => 'required|exists:periode_akademik,id',
        'kelas_id' => 'required|exists:kelas,id',
        'mapel_id' => 'required|exists:mata_pelajaran,id',
        'guru_id' => 'required|exists:guru,id',
        'hari' => 'required|in:Senin,Selasa,Rabu,Kamis,Jumat,Sabtu',
        'jam_mulai_ke' => 'required|integer|min:1|max:8',
        'jam_selesai_ke' => 'required|integer|min:1|max:8',
        'ruangan' => 'nullable|string|max:20',
    ]);

    if ((int) $validated['jam_selesai_ke'] < (int) $validated['jam_mulai_ke']) {
        return back()
            ->withErrors(['jam_selesai_ke' => 'Jam selesai tidak boleh sebelum jam mulai.'])
            ->withInput();
    }

    $validated['jam_mulai'] = self::JAM_PELAJARAN[$validated['jam_mulai_ke']]['mulai'];
    $validated['jam_selesai'] = self::JAM_PELAJARAN[$validated['jam_selesai_ke']]['selesai'];

    unset($validated['jam_mulai_ke'], $validated['jam_selesai_ke']);

    JadwalPelajaran::create($validated);

    return redirect()->route('admin.penugasan.index')
        ->with('success', 'Penugasan berhasil ditambahkan');
}

    public function edit($id)
{
    $jadwal = JadwalPelajaran::findOrFail($id);

    $jamMulaiKe = array_search(
        substr($jadwal->jam_mulai, 0, 5),
        array_map(fn($jam) => $jam['mulai'], self::JAM_PELAJARAN),
        true
    );

    $jamSelesaiKe = array_search(
        substr($jadwal->jam_selesai, 0, 5),
        array_map(fn($jam) => $jam['selesai'], self::JAM_PELAJARAN),
        true
    );

    $guru = Guru::with('user')->get();
    $kelas = Kelas::all();
    $mataPelajaran = MataPelajaran::all();
    $periode = PeriodeAkademik::where('is_active', true)->get();

    return view('admin.penugasan.edit', compact(
        'jadwal',
        'guru',
        'kelas',
        'mataPelajaran',
        'periode',
        'jamMulaiKe',
        'jamSelesaiKe'
    ));
}

    public function update(Request $request, $id)
{
    $validated = $request->validate([
        'periode_id' => 'required|exists:periode_akademik,id',
        'kelas_id' => 'required|exists:kelas,id',
        'mapel_id' => 'required|exists:mata_pelajaran,id',
        'guru_id' => 'required|exists:guru,id',
        'hari' => 'required|in:Senin,Selasa,Rabu,Kamis,Jumat,Sabtu',
        'jam_mulai_ke' => 'required|integer|min:1|max:8',
        'jam_selesai_ke' => 'required|integer|min:1|max:8',
        'ruangan' => 'nullable|string|max:20',
    ]);

    if ((int) $validated['jam_selesai_ke'] < (int) $validated['jam_mulai_ke']) {
        return back()
            ->withErrors(['jam_selesai_ke' => 'Jam selesai tidak boleh sebelum jam mulai.'])
            ->withInput();
    }

    $validated['jam_mulai'] = self::JAM_PELAJARAN[$validated['jam_mulai_ke']]['mulai'];
    $validated['jam_selesai'] = self::JAM_PELAJARAN[$validated['jam_selesai_ke']]['selesai'];

    unset($validated['jam_mulai_ke'], $validated['jam_selesai_ke']);

    $jadwal = JadwalPelajaran::findOrFail($id);
    $jadwal->update($validated);

    return redirect()->route('admin.penugasan.index')
        ->with('success', 'Penugasan berhasil diperbarui');
}

    public function destroy($id)
    {
        $jadwal = JadwalPelajaran::findOrFail($id);
        $jadwal->delete();

        return redirect()->route('admin.penugasan.index')
            ->with('success', 'Penugasan berhasil dihapus');
    }
}
