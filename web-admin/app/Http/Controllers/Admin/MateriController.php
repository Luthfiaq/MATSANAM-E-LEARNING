<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Materi;
use App\Models\JadwalPelajaran;
use App\Services\MatsanamNotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class MateriController extends Controller
{
    public function index(Request $request)
    {
        $query = Materi::with(['jadwal.kelas', 'jadwal.mataPelajaran', 'guru'])
            ->latest();

        if ($request->filled('search')) {
            $query->where('judul', 'like', '%' . $request->search . '%');
        }

        $materi = $query->paginate(15);

        return view('admin.materi.index', compact('materi'));
    }

    public function create()
    {
        $jadwal = JadwalPelajaran::with(['kelas', 'mataPelajaran', 'guru'])->get();

        return view('admin.materi.create', compact('jadwal'));
    }

    private function validateResource(Request $request, string $type, bool $fileRequired): void
    {
        if ($type === 'link') {
            $request->validate([
                'link' => 'required|url|max:2048',
                'file_path' => 'prohibited',
            ]);

            $scheme = strtolower((string) parse_url((string) $request->input('link'), PHP_URL_SCHEME));
            if (!in_array($scheme, ['http', 'https'], true)) {
                throw ValidationException::withMessages(['link' => 'Tautan materi harus menggunakan HTTP atau HTTPS.']);
            }

            return;
        }

        $mimes = $type === 'pdf' ? 'pdf' : 'mp4,mov,webm';
        $request->validate([
            'file_path' => ($fileRequired ? 'required' : 'nullable') . '|file|mimes:' . $mimes . '|max:10240',
            'link' => 'prohibited',
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'jadwal_id' => 'required|integer|exists:jadwal_pelajaran,id',
            'judul' => 'required|string|max:255',
            'deskripsi' => 'nullable|string',
            'tipe' => 'required|in:pdf,video,link',
        ]);

        $this->validateResource($request, $validated['tipe'], $validated['tipe'] !== 'link');
        $jadwal = JadwalPelajaran::findOrFail($validated['jadwal_id']);
        $filePath = null;

        if ($validated['tipe'] !== 'link') {
            $filePath = $request->file('file_path')->store('materi', 'public');
            if (!$filePath) {
                return back()->withInput()->withErrors(['file_path' => 'File materi gagal disimpan.']);
            }
        }

        try {
            $materi = DB::transaction(function () use ($validated, $jadwal, $filePath, $request) {
                return Materi::create([
                    'jadwal_id' => $jadwal->id,
                    'guru_id' => $jadwal->guru_id,
                    'judul' => $validated['judul'],
                    'deskripsi' => $validated['deskripsi'] ?? null,
                    'tipe' => $validated['tipe'],
                    'file_path' => $filePath,
                    'link' => $validated['tipe'] === 'link' ? $request->input('link') : null,
                ])->load(['jadwal.kelas', 'jadwal.mataPelajaran']);
            });
        } catch (\Throwable $exception) {
            if ($filePath) {
                Storage::disk('public')->delete($filePath);
            }
            throw $exception;
        }

        if ($materi->jadwal) {
            app(MatsanamNotificationService::class)->notifyClassStudents(
                (int) $materi->jadwal->kelas_id,
                'materi_baru',
                'Materi baru tersedia',
                (auth()->user()?->name ?? 'Admin TU') . ' menerbitkan materi "' . $materi->judul . '" untuk ' . ($materi->jadwal->mataPelajaran?->nama ?? 'mata pelajaran') . '.',
                [
                    'materi_id' => $materi->id,
                    'mapel_id' => $materi->jadwal->mapel_id,
                    'jadwal_id' => $materi->jadwal_id,
                    'class_id' => $materi->jadwal->kelas_id,
                ],
            );
        }

        return redirect()->route('admin.materi.index')
            ->with('success', 'Materi berhasil ditambahkan');
    }

    public function edit($id)
    {
        $materi = Materi::with(['jadwal.kelas', 'jadwal.mataPelajaran'])->findOrFail($id);
        $jadwal = JadwalPelajaran::with(['kelas', 'mataPelajaran', 'guru'])->get();

        return view('admin.materi.edit', compact('materi', 'jadwal'));
    }

    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'jadwal_id' => 'required|integer|exists:jadwal_pelajaran,id',
            'judul' => 'required|string|max:255',
            'deskripsi' => 'nullable|string',
            'tipe' => 'required|in:pdf,video,link',
        ]);

        $materi = Materi::findOrFail($id);
        $typeChanged = $validated['tipe'] !== $materi->tipe;
        $this->validateResource(
            $request,
            $validated['tipe'],
            $validated['tipe'] !== 'link' && ($typeChanged || blank($materi->file_path)),
        );

        $jadwal = JadwalPelajaran::findOrFail($validated['jadwal_id']);
        $newFilePath = null;
        if ($validated['tipe'] !== 'link' && $request->hasFile('file_path')) {
            $newFilePath = $request->file('file_path')->store('materi', 'public');
            if (!$newFilePath) {
                return back()->withInput()->withErrors(['file_path' => 'File materi pengganti gagal disimpan.']);
            }
        }

        try {
            $result = DB::transaction(function () use ($id, $validated, $jadwal, $newFilePath, $request) {
                $locked = Materi::whereKey($id)->lockForUpdate()->firstOrFail();
                if ($validated['tipe'] !== 'link' && !$newFilePath &&
                    ($validated['tipe'] !== $locked->tipe || blank($locked->file_path))) {
                    throw ValidationException::withMessages(['file_path' => 'Unggah file baru untuk tipe materi yang dipilih.']);
                }

                $oldFilePath = $locked->file_path;
                $locked->jadwal_id = $jadwal->id;
                $locked->guru_id = $jadwal->guru_id;
                $locked->judul = $validated['judul'];
                $locked->deskripsi = $validated['deskripsi'] ?? null;
                $locked->tipe = $validated['tipe'];

                if ($validated['tipe'] === 'link') {
                    $locked->link = $request->input('link');
                    $locked->file_path = null;
                } else {
                    $locked->link = null;
                    if ($newFilePath) {
                        $locked->file_path = $newFilePath;
                    }
                }

                $locked->save();

                return [
                    'old_file' => $oldFilePath,
                    'new_file' => $locked->file_path,
                ];
            });
        } catch (\Throwable $exception) {
            if ($newFilePath) {
                Storage::disk('public')->delete($newFilePath);
            }
            throw $exception;
        }

        if ($result['old_file'] && $result['old_file'] !== $result['new_file']) {
            Storage::disk('public')->delete($result['old_file']);
        }

        return redirect()->route('admin.materi.index')
            ->with('success', 'Materi berhasil diperbarui');
    }

    public function destroy($id)
    {
        $filePath = DB::transaction(function () use ($id) {
            $materi = Materi::whereKey($id)->lockForUpdate()->firstOrFail();
            $path = $materi->file_path;
            $materi->delete();

            return $path;
        });

        if ($filePath) {
            Storage::disk('public')->delete($filePath);
        }

        return redirect()->route('admin.materi.index')
            ->with('success', 'Materi berhasil dihapus');
    }
}
