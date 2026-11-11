<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\JadwalPelajaran;
use App\Models\PeriodeAkademik;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class PeriodeAkademikController extends Controller
{
    public function index(): View
    {
        $periode = PeriodeAkademik::orderByDesc('tanggal_mulai')->paginate(20);
        return view('admin.master-data.periode-akademik.index', compact('periode'));
    }

    public function create(): View
    {
        return view('admin.master-data.periode-akademik.create');
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'nama' => ['required', 'string', 'max:100'],
            'tahun_ajaran' => ['required', 'string', 'max:10'],
            'semester' => ['required', Rule::in(['ganjil', 'genap'])],
            'tanggal_mulai' => ['required', 'date'],
            'tanggal_selesai' => ['required', 'date', 'after_or_equal:tanggal_mulai'],
            'is_active' => ['required', 'boolean'],
        ]);

        DB::transaction(function () use ($validated) {
            if ((bool) $validated['is_active']) {
                PeriodeAkademik::query()->update(['is_active' => false]);
            }
            PeriodeAkademik::create($validated);
        });

        return redirect()->route('admin.master-data.periode-akademik.index')->with('success', 'Periode akademik berhasil ditambahkan.');
    }

    public function edit(int $id): View
    {
        $periode = PeriodeAkademik::findOrFail($id);
        return view('admin.master-data.periode-akademik.edit', compact('periode'));
    }

    public function update(Request $request, int $id): RedirectResponse
    {
        $periode = PeriodeAkademik::findOrFail($id);
        $validated = $request->validate([
            'nama' => ['required', 'string', 'max:100'],
            'tahun_ajaran' => ['required', 'string', 'max:10'],
            'semester' => ['required', Rule::in(['ganjil', 'genap'])],
            'tanggal_mulai' => ['required', 'date'],
            'tanggal_selesai' => ['required', 'date', 'after_or_equal:tanggal_mulai'],
            'is_active' => ['required', 'boolean'],
        ]);

        DB::transaction(function () use ($periode, $validated) {
            if ((bool) $validated['is_active']) {
                PeriodeAkademik::where('id', '!=', $periode->id)->update(['is_active' => false]);
            }
            $periode->update($validated);
        });

        return redirect()->route('admin.master-data.periode-akademik.index')->with('success', 'Periode akademik berhasil diperbarui.');
    }

    public function destroy(int $id): RedirectResponse
    {
        $periode = PeriodeAkademik::findOrFail($id);
        if (JadwalPelajaran::where('periode_id', $periode->id)->exists()) {
            return redirect()->route('admin.master-data.periode-akademik.index')
                ->with('error', 'Periode tidak dapat dihapus karena masih memiliki jadwal pelajaran.');
        }
        $periode->delete();
        return redirect()->route('admin.master-data.periode-akademik.index')->with('success', 'Periode akademik berhasil dihapus.');
    }
}
