<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Materi;
use App\Models\JadwalPelajaran;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

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

    public function store(Request $request)
    {
        $validated = $request->validate([
            'jadwal_id' => 'required|exists:jadwal_pelajaran,id',
            'judul' => 'required|string|max:255',
            'deskripsi' => 'nullable|string',
            'tipe' => 'required|in:pdf,video,link',
            'file_path' => 'nullable|file|mimes:pdf,doc,docx,ppt,pptx,mp4,mov,avi|max:10240',
            'link' => 'nullable|url',
        ]);

        $data = $request->except('file_path');
        
        if ($request->hasFile('file_path')) {
            $file = $request->file('file_path');
            $path = $file->store('materi', 'public');
            $data['file_path'] = $path;
        }

        Materi::create($data);

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
        $materi = Materi::findOrFail($id);

        $validated = $request->validate([
            'jadwal_id' => 'required|exists:jadwal_pelajaran,id',
            'judul' => 'required|string|max:255',
            'deskripsi' => 'nullable|string',
            'tipe' => 'required|in:pdf,video,link',
            'file_path' => 'nullable|file|mimes:pdf,doc,docx,ppt,pptx,mp4,mov,avi|max:10240',
            'link' => 'nullable|url',
        ]);

        $data = $request->except('file_path');
        
        if ($request->hasFile('file_path')) {
            // Delete old file
            if ($materi->file_path) {
                Storage::disk('public')->delete($materi->file_path);
            }
            
            $file = $request->file('file_path');
            $path = $file->store('materi', 'public');
            $data['file_path'] = $path;
        }

        $materi->update($data);

        return redirect()->route('admin.materi.index')
            ->with('success', 'Materi berhasil diperbarui');
    }

    public function destroy($id)
    {
        $materi = Materi::findOrFail($id);
        
        if ($materi->file_path) {
            Storage::disk('public')->delete($materi->file_path);
        }
        
        $materi->delete();

        return redirect()->route('admin.materi.index')
            ->with('success', 'Materi berhasil dihapus');
    }
}