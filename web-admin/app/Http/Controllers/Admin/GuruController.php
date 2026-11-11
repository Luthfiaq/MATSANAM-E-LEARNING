<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Guru;
use App\Models\User;
use App\Models\UserAccountLog;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class GuruController extends Controller
{
    public function index(): View
    {
        $guru = Guru::query()
            ->whereHas('user')
            ->with('user')
            ->orderBy('nama_lengkap')
            ->paginate(15)
            ->withQueryString();

        return view('admin.master-data.guru.index', compact('guru'));
    }

    public function create(): View
    {
        return view('admin.master-data.guru.create');
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'nip' => ['required', 'string', 'max:20', 'unique:guru,nip'],
            'nama_lengkap' => ['required', 'string', 'max:150'],
            'jenis_kelamin' => ['required', Rule::in(['L', 'P'])],
            'telepon' => ['nullable', 'string', 'max:15'],
            'alamat' => ['nullable', 'string', 'max:2000'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:10', 'confirmed'],
            'is_active' => ['required', 'boolean'],
        ]);

        $guru = DB::transaction(function () use ($validated) {
            $user = User::create([
                'name' => $validated['nama_lengkap'],
                'email' => $validated['email'],
                'password' => $validated['password'],
                'role' => 'guru',
                'is_active' => (bool) $validated['is_active'],
                'must_change_password' => true,
            ]);

            $guru = Guru::create([
                'user_id' => $user->id,
                'nip' => $validated['nip'],
                'nama_lengkap' => $validated['nama_lengkap'],
                'jenis_kelamin' => $validated['jenis_kelamin'],
                'telepon' => $validated['telepon'] ?? null,
                'alamat' => $validated['alamat'] ?? null,
            ]);

            UserAccountLog::create([
                'actor_id' => auth()->id(),
                'target_user_id' => $user->id,
                'action' => 'account_created',
                'description' => 'Akun Guru dibuat melalui Master Data Guru.',
                'metadata' => ['source' => 'master_data_guru'],
            ]);

            return $guru;
        });

        return redirect()->route('admin.master-data.guru.index')
            ->with('success', 'Data Guru dan akun login berhasil ditambahkan. Pengguna wajib mengganti password awal saat login.');
    }

    public function edit(int $id): View
    {
        $guru = Guru::with('user')->whereHas('user')->findOrFail($id);
        return view('admin.master-data.guru.edit', compact('guru'));
    }

    public function update(Request $request, int $id): RedirectResponse
    {
        $guru = Guru::with('user')->whereHas('user')->findOrFail($id);
        $validated = $request->validate([
            'nip' => ['required', 'string', 'max:20', Rule::unique('guru', 'nip')->ignore($guru->id)],
            'nama_lengkap' => ['required', 'string', 'max:150'],
            'jenis_kelamin' => ['required', Rule::in(['L', 'P'])],
            'telepon' => ['nullable', 'string', 'max:15'],
            'alamat' => ['nullable', 'string', 'max:2000'],
            'email' => ['required', 'email', 'max:255', Rule::unique('users', 'email')->ignore($guru->user_id)],
            'is_active' => ['required', 'boolean'],
        ]);

        DB::transaction(function () use ($guru, $validated) {
            $wasActive = (bool) $guru->user->is_active;
            $guru->update([
                'nip' => $validated['nip'],
                'nama_lengkap' => $validated['nama_lengkap'],
                'jenis_kelamin' => $validated['jenis_kelamin'],
                'telepon' => $validated['telepon'] ?? null,
                'alamat' => $validated['alamat'] ?? null,
            ]);
            $guru->user->update([
                'name' => $validated['nama_lengkap'],
                'email' => $validated['email'],
                'is_active' => (bool) $validated['is_active'],
            ]);

            if ($wasActive && ! $validated['is_active']) {
                $guru->user->tokens()->delete();
            }

            UserAccountLog::create([
                'actor_id' => auth()->id(),
                'target_user_id' => $guru->user_id,
                'action' => 'account_updated',
                'description' => 'Data Guru diperbarui melalui Master Data Guru.',
                'metadata' => ['source' => 'master_data_guru'],
            ]);
        });

        return redirect()->route('admin.master-data.guru.index')->with('success', 'Data Guru berhasil diperbarui.');
    }

    /** Soft-delete login only; retain teacher profile for class and academic history. */
    public function destroy(int $id): RedirectResponse
    {
        $guru = Guru::with('user')->whereHas('user')->findOrFail($id);
        $user = $guru->user;

        abort_if($user->id === auth()->id(), 422, 'Admin tidak dapat menghapus akun yang sedang digunakan.');

        DB::transaction(function () use ($user) {
            $user->tokens()->delete();
            $user->update(['is_active' => false]);
            UserAccountLog::create([
                'actor_id' => auth()->id(),
                'target_user_id' => $user->id,
                'action' => 'account_deleted',
                'description' => 'Akun Guru dihapus secara soft-delete dari Master Data Guru; profil akademik dipertahankan.',
                'metadata' => ['source' => 'master_data_guru', 'was_active' => (bool) $user->getOriginal('is_active')],
            ]);
            $user->delete();
        });

        return redirect()->route('admin.master-data.guru.index')
            ->with('success', 'Akses akun Guru dihapus. Riwayat dan relasi akademiknya tetap dipertahankan; akun dapat dipulihkan dari Manajemen Akun.');
    }
}
