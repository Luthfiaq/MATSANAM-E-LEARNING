<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Penugasan;
use App\Models\JadwalPelajaran;
use Illuminate\Http\Request;
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

        $data = $request->except('file_materi');
        
        if ($request->hasFile('file_materi')) {
            $file = $request->file('file_materi');
            $path = $file->store('tugas', 'public');
            $data['file_materi'] = $path;
        }

        Penugasan::create($data);

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

        $data = $request->except('file_materi');
        
        if ($request->hasFile('file_materi')) {
            if ($tugas->file_materi) {
                Storage::disk('public')->delete($tugas->file_materi);
            }
            
            $file = $request->file('file_materi');
            $path = $file->store('tugas', 'public');
            $data['file_materi'] = $path;
        }

        $tugas->update($data);

        return redirect()->route('admin.tugas.index')
            ->with('success', 'Tugas berhasil diperbarui');
    }

    public function destroy($id)
    {
        $tugas = Penugasan::findOrFail($id);
        
        if ($tugas->file_materi) {
            Storage::disk('public')->delete($tugas->file_materi);
        }
        
        $tugas->delete();

        return redirect()->route('admin.tugas.index')
            ->with('success', 'Tugas berhasil dihapus');
    }
}