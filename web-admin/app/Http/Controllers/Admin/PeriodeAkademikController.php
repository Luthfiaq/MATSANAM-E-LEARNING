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
    public function index(Request $request): View
    {
        $validated = $request->validate([
            'q' => ['nullable', 'string', 'max:100'],
            'semester' => ['nullable', Rule::in(['ganjil', 'genap'])],
            'status' => ['nullable', Rule::in(['aktif', 'nonaktif'])],
        ]);

        $search = trim((string) ($validated['q'] ?? ''));
        $semester = $validated['semester'] ?? '';
        $status = $validated['status'] ?? '';

        $query = PeriodeAkademik::query();

        if ($search !== '') {
            $query->where(function ($builder) use ($search) {
                $builder->where('nama', 'like', "%{$search}%")
                    ->orWhere('tahun_ajaran', 'like', "%{$search}%");
            });
        }

        if ($semester !== '') {
            $query->where('semester', $semester);
        }

        if ($status !== '') {
            $query->where('is_active', $status === 'aktif');
        }

        $periode = $query->orderByDesc('tanggal_mulai')->paginate(20)->withQueryString();

        return view('admin.master-data.periode-akademik.index', compact('periode', 'search', 'semester', 'status'));
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
