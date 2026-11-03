<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\PeriodeAkademik;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class PeriodeAkademikController extends Controller
{
    public function index()
    {
        $periode = PeriodeAkademik::orderByDesc('tanggal_mulai')->get();

        return view(
            'admin.master-data.periode-akademik.index',
            compact('periode')
        );
    }

    public function create()
    {
        return view('admin.master-data.periode-akademik.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama' => 'required|string|max:100',
            'tahun_ajaran' => 'required|string|max:50',
            'semester' => 'required|in:Ganjil,Genap',
            'tanggal_mulai' => 'required|date',
            'tanggal_selesai' => 'required|date|after_or_equal:tanggal_mulai',
            'is_active' => 'required|boolean',
        ]);

        DB::transaction(function () use ($request) {

            if ($request->is_active) {
                PeriodeAkademik::query()->update([
                    'is_active' => false
                ]);
            }

            PeriodeAkademik::create([
                'nama' => $request->nama,
                'tahun_ajaran' => $request->tahun_ajaran,
                'semester' => $request->semester,
                'tanggal_mulai' => $request->tanggal_mulai,
                'tanggal_selesai' => $request->tanggal_selesai,
                'is_active' => $request->is_active,
            ]);
        });

        return redirect()
            ->route('admin.master-data.periode-akademik.index')
            ->with('success', 'Periode akademik berhasil ditambahkan.');
    }

    public function edit($id)
    {
        $periode = PeriodeAkademik::findOrFail($id);

        return view(
            'admin.master-data.periode-akademik.edit',
            compact('periode')
        );
    }

    public function update(Request $request, $id)
    {
        $periode = PeriodeAkademik::findOrFail($id);

        $request->validate([
            'nama' => 'required|string|max:100',
            'tahun_ajaran' => 'required|string|max:50',
            'semester' => 'required|in:Ganjil,Genap',
            'tanggal_mulai' => 'required|date',
            'tanggal_selesai' => 'required|date|after_or_equal:tanggal_mulai',
            'is_active' => 'required|boolean',
        ]);

        DB::transaction(function () use ($request, $periode) {

            if ($request->is_active) {
                PeriodeAkademik::where('id', '!=', $periode->id)
                    ->update(['is_active' => false]);
            }

            $periode->update([
                'nama' => $request->nama,
                'tahun_ajaran' => $request->tahun_ajaran,
                'semester' => $request->semester,
                'tanggal_mulai' => $request->tanggal_mulai,
                'tanggal_selesai' => $request->tanggal_selesai,
                'is_active' => $request->is_active,
            ]);
        });

        return redirect()
            ->route('admin.master-data.periode-akademik.index')
            ->with('success', 'Periode akademik berhasil diperbarui.');
    }

    public function destroy($id)
    {
        $periode = PeriodeAkademik::findOrFail($id);

        $periode->delete();

        return redirect()
            ->route('admin.master-data.periode-akademik.index')
            ->with('success', 'Periode akademik berhasil dihapus.');
    }
}