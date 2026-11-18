<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Penugasan;
use App\Models\JadwalPelajaran;
use Carbon\Carbon;
use App\Services\MatsanamNotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class TugasController extends Controller
{
    public function show($id)
    {
        $tugas = Penugasan::with(['jadwal.kelas', 'jadwal.mataPelajaran', 'guru'])->findOrFail($id);
        return view('admin.tugas.show', compact('tugas'));
    }

    public function index(Request $request)
    {
        $query = Penugasan::with(['jadwal.kelas', 'jadwal.mataPelajaran'])
            ->latest();

        if ($request->filled('search')) {
            $query->where('judul', 'like', '%' . $request->search . '%');
        }

        $tugas = $query->paginate(15);

        return view('admin.tugas.index', compact('tugas'));
    }

    public function create()
    {
        $jadwal = JadwalPelajaran::with(['kelas', 'mataPelajaran'])->get();

        return view('admin.tugas.create', compact('jadwal'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'jadwal_id' => 'required|exists:jadwal_pelajaran,id',
            'judul' => 'required|string|max:255',
            'deskripsi' => 'nullable|string',
            'jenis' => 'required|in:tugas,quiz,uts,uas',
            'deadline' => 'required|date',
            'file_materi' => 'nullable|file|mimes:pdf,doc,docx,ppt,pptx,zip,rar|max:10240',
            'bobot' => 'required|integer|min:1|max:100',
        ]);

        $jadwal = JadwalPelajaran::findOrFail($validated['jadwal_id']);
        $validated['deadline'] = Carbon::parse($validated['deadline'], 'Asia/Jakarta')->utc();
        $data = collect($validated)->except('file_materi')->all();
        $data['guru_id'] = $jadwal->guru_id;
        $data['deskripsi'] = $data['deskripsi'] ?? '';
        $filePath = null;

        if ($request->hasFile('file_materi')) {
            $filePath = $request->file('file_materi')->store('tugas', 'public');
            $data['file_materi'] = $filePath;
        }

        try {
            $tugas = Penugasan::create($data)->load(['jadwal.kelas', 'jadwal.mataPelajaran']);
        } catch (\Throwable $exception) {
            if ($filePath) {
                Storage::disk('public')->delete($filePath);
            }
            throw $exception;
        }

        if ($tugas->jadwal) {
            app(MatsanamNotificationService::class)->notifyClassStudents(
                (int) $tugas->jadwal->kelas_id,
                'tugas_baru',
                'Tugas baru diberikan',
                (auth()->user()?->name ?? 'Admin TU') . ' memberikan tugas "' . $tugas->judul . '" untuk ' . ($tugas->jadwal->mataPelajaran?->nama ?? 'mata pelajaran') . '.',
                [
                    'tugas_id' => $tugas->id,
                    'mapel_id' => $tugas->jadwal->mapel_id,
                    'jadwal_id' => $tugas->jadwal_id,
                    'class_id' => $tugas->jadwal->kelas_id,
                    'deadline' => $tugas->deadline?->toIso8601String(),
                ],
            );
        }

        return redirect()->route('admin.tugas.index')
            ->with('success', 'Tugas berhasil ditambahkan');
    }

    public function edit($id)
    {
        $tugas = Penugasan::with(['jadwal.kelas', 'jadwal.mataPelajaran'])->findOrFail($id);
        $jadwal = JadwalPelajaran::with(['kelas', 'mataPelajaran'])->get();

        return view('admin.tugas.edit', compact('tugas', 'jadwal'));
    }

    public function update(Request $request, $id)
    {
        $tugas = Penugasan::findOrFail($id);

        $validated = $request->validate([
            'jadwal_id' => 'required|exists:jadwal_pelajaran,id',
            'judul' => 'required|string|max:255',
            'deskripsi' => 'nullable|string',
            'jenis' => 'required|in:tugas,quiz,uts,uas',
            'deadline' => 'required|date',
            'file_materi' => 'nullable|file|mimes:pdf,doc,docx,ppt,pptx,zip,rar|max:10240',
            'bobot' => 'required|integer|min:1|max:100',
        ]);

        $jadwal = JadwalPelajaran::findOrFail($validated['jadwal_id']);
        $validated['deadline'] = Carbon::parse($validated['deadline'], 'Asia/Jakarta')->utc();
        $data = collect($validated)->except('file_materi')->all();
        $data['guru_id'] = $jadwal->guru_id;
        $data['deskripsi'] = $data['deskripsi'] ?? '';
        $oldFilePath = $tugas->file_materi;
        $newFilePath = null;

        if ($request->hasFile('file_materi')) {
            $newFilePath = $request->file('file_materi')->store('tugas', 'public');
            $data['file_materi'] = $newFilePath;
        }

        try {
            $tugas->fill($data);
            $tugas->save();
        } catch (\Throwable $exception) {
            if ($newFilePath) {
                Storage::disk('public')->delete($newFilePath);
            }
            throw $exception;
        }

        if ($newFilePath && $oldFilePath && $oldFilePath !== $newFilePath) {
            Storage::disk('public')->delete($oldFilePath);
        }

        return redirect()->route('admin.tugas.index')
            ->with('success', 'Tugas berhasil diperbarui');
    }

    public function destroy($id)
    {
        $result = DB::transaction(function () use ($id) {
            $tugas = Penugasan::query()
                ->lockForUpdate()
                ->findOrFail($id);

            // Keep submissions and their grades intact; the task cannot be removed
            // after a student has submitted work.
            if ($tugas->pengumpulan()->exists()) {
                return ['deleted' => false, 'file' => null];
            }

            $filePath = $tugas->file_materi;
            $tugas->delete();

            return ['deleted' => true, 'file' => $filePath];
        });

        if (! $result['deleted']) {
            return redirect()->route('admin.tugas.index')
                ->with('error', 'Tugas tidak dapat dihapus karena sudah memiliki pengumpulan siswa.');
        }

        if ($result['file']) {
            Storage::disk('public')->delete($result['file']);
        }

        return redirect()->route('admin.tugas.index')
            ->with('success', 'Tugas berhasil dihapus');
    }
}