<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Kelas;
use App\Models\Siswa;
use App\Models\User;
use App\Models\UserAccountLog;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class SiswaController extends Controller
{
    public function index(): View
    {
        $siswa = Siswa::query()
            ->whereHas('user')
            ->with(['user', 'kelas'])
            ->orderBy('nama_lengkap')
            ->paginate(15)
            ->withQueryString();

        return view('admin.master-data.siswa.index', compact('siswa'));
    }

    public function create(): View
    {
        $kelas = Kelas::orderBy('tingkat')->orderBy('nama_kelas')->get();
        return view('admin.master-data.siswa.create', compact('kelas'));
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'nis' => ['required', 'string', 'max:20', 'unique:siswa,nis'],
            'nisn' => ['required', 'string', 'max:20', 'unique:siswa,nisn'],
            'nama_lengkap' => ['required', 'string', 'max:150'],
            'jenis_kelamin' => ['required', Rule::in(['L', 'P'])],
            'tanggal_lahir' => ['required', 'date'],
            'tempat_lahir' => ['required', 'string', 'max:100'],
            'kelas_id' => ['nullable', 'exists:kelas,id'],
            'nama_wali' => ['nullable', 'string', 'max:150'],
            'telepon_wali' => ['nullable', 'string', 'max:15'],
            'alamat' => ['nullable', 'string', 'max:2000'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:10', 'confirmed'],
            'is_active' => ['required', 'boolean'],
        ]);

        DB::transaction(function () use ($validated) {
            $user = User::create([
                'name' => $validated['nama_lengkap'],
                'email' => $validated['email'],
                'password' => $validated['password'],
                'role' => 'siswa',
                'is_active' => (bool) $validated['is_active'],
                'must_change_password' => true,
            ]);

            Siswa::create([
                'user_id' => $user->id,
                'nis' => $validated['nis'],
                'nisn' => $validated['nisn'],
                'nama_lengkap' => $validated['nama_lengkap'],
                'jenis_kelamin' => $validated['jenis_kelamin'],
                'tanggal_lahir' => $validated['tanggal_lahir'],
                'tempat_lahir' => $validated['tempat_lahir'],
                'kelas_id' => $validated['kelas_id'] ?? null,
                'nama_wali' => $validated['nama_wali'] ?? null,
                'telepon_wali' => $validated['telepon_wali'] ?? null,
                'alamat' => $validated['alamat'] ?? null,
            ]);

            UserAccountLog::create([
                'actor_id' => auth()->id(),
                'target_user_id' => $user->id,
                'action' => 'account_created',
                'description' => 'Akun Siswa dibuat melalui Master Data Siswa.',
                'metadata' => ['source' => 'master_data_siswa'],
            ]);
        });

        return redirect()->route('admin.master-data.siswa.index')
            ->with('success', 'Data Siswa dan akun login berhasil ditambahkan. Siswa wajib mengganti password awal saat login.');
    }

    public function edit(int $id): View
    {
        $siswa = Siswa::with(['user', 'kelas'])->whereHas('user')->findOrFail($id);
        $kelas = Kelas::orderBy('tingkat')->orderBy('nama_kelas')->get();
        return view('admin.master-data.siswa.edit', compact('siswa', 'kelas'));
    }

    public function update(Request $request, int $id): RedirectResponse
    {
        $siswa = Siswa::with('user')->whereHas('user')->findOrFail($id);
        $validated = $request->validate([
            'nis' => ['required', 'string', 'max:20', Rule::unique('siswa', 'nis')->ignore($siswa->id)],
            'nisn' => ['required', 'string', 'max:20', Rule::unique('siswa', 'nisn')->ignore($siswa->id)],
            'nama_lengkap' => ['required', 'string', 'max:150'],
            'jenis_kelamin' => ['required', Rule::in(['L', 'P'])],
            'tanggal_lahir' => ['required', 'date'],
            'tempat_lahir' => ['required', 'string', 'max:100'],
            'kelas_id' => ['nullable', 'exists:kelas,id'],
            'nama_wali' => ['nullable', 'string', 'max:150'],
            'telepon_wali' => ['nullable', 'string', 'max:15'],
            'alamat' => ['nullable', 'string', 'max:2000'],
            'email' => ['required', 'email', 'max:255', Rule::unique('users', 'email')->ignore($siswa->user_id)],
            'is_active' => ['required', 'boolean'],
        ]);

        DB::transaction(function () use ($siswa, $validated) {
            $wasActive = (bool) $siswa->user->is_active;
            $siswa->update([
                'nis' => $validated['nis'],
                'nisn' => $validated['nisn'],
                'nama_lengkap' => $validated['nama_lengkap'],
                'jenis_kelamin' => $validated['jenis_kelamin'],
                'tanggal_lahir' => $validated['tanggal_lahir'],
                'tempat_lahir' => $validated['tempat_lahir'],
                'kelas_id' => $validated['kelas_id'] ?? null,
                'nama_wali' => $validated['nama_wali'] ?? null,
                'telepon_wali' => $validated['telepon_wali'] ?? null,
                'alamat' => $validated['alamat'] ?? null,
            ]);
            $siswa->user->update([
                'name' => $validated['nama_lengkap'],
                'email' => $validated['email'],
                'is_active' => (bool) $validated['is_active'],
            ]);

            if ($wasActive && ! $validated['is_active']) {
                $siswa->user->tokens()->delete();
            }

            UserAccountLog::create([
                'actor_id' => auth()->id(),
                'target_user_id' => $siswa->user_id,
                'action' => 'account_updated',
                'description' => 'Data Siswa diperbarui melalui Master Data Siswa.',
                'metadata' => ['source' => 'master_data_siswa'],
            ]);
        });

        return redirect()->route('admin.master-data.siswa.index')->with('success', 'Data Siswa berhasil diperbarui.');
    }

    /** Soft-delete login only; retain student history and foreign-key references. */
    public function destroy(int $id): RedirectResponse
    {
        $siswa = Siswa::with('user')->whereHas('user')->findOrFail($id);
        $user = $siswa->user;
        abort_if($user->id === auth()->id(), 422, 'Admin tidak dapat menghapus akun yang sedang digunakan.');

        DB::transaction(function () use ($user) {
            $wasActive = (bool) $user->is_active;
            $user->tokens()->delete();
            $user->update(['is_active' => false]);
            UserAccountLog::create([
                'actor_id' => auth()->id(),
                'target_user_id' => $user->id,
                'action' => 'account_deleted',
                'description' => 'Akun Siswa dihapus secara soft-delete dari Master Data Siswa; data akademik dipertahankan.',
                'metadata' => ['source' => 'master_data_siswa', 'was_active' => $wasActive],
            ]);
            $user->delete();
        });

        return redirect()->route('admin.master-data.siswa.index')
            ->with('success', 'Akses akun Siswa dihapus. Riwayat akademik tetap disimpan dan akun dapat dipulihkan melalui Manajemen Akun.');
    }
}
