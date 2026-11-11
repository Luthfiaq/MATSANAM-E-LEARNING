<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Guru;
use App\Models\Kelas;
use App\Models\MataPelajaran;
use App\Models\Siswa;
use App\Models\User;
use App\Models\UserAccountLog;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class AccountManagementController extends Controller
{
    public function index(Request $request): View
    {
        $role = $request->string('role')->toString() ?: 'all';
        abort_unless(in_array($role, ['all', 'guru', 'siswa'], true), 404);

        $showDeleted = $request->boolean('show_deleted');
        $query = ($showDeleted ? User::onlyTrashed() : User::query())
            ->whereIn('role', ['guru', 'siswa'])
            ->with([
                'guru.jadwalPelajaran.mataPelajaran',
                'siswa.kelas',
            ]);

        if ($role !== 'all') {
            $query->where('role', $role);
        }

        if ($request->filled('q')) {
            $term = trim((string) $request->input('q'));
            $query->where(function ($builder) use ($term) {
                $builder->where('name', 'like', "%{$term}%")
                    ->orWhere('email', 'like', "%{$term}%")
                    ->orWhereHas('guru', fn ($q) => $q->where('nip', 'like', "%{$term}%"))
                    ->orWhereHas('siswa', fn ($q) => $q->where('nis', 'like', "%{$term}%")
                        ->orWhere('nisn', 'like', "%{$term}%"));
            });
        }

        if ($request->filled('status')) {
            abort_unless(in_array($request->input('status'), ['active', 'inactive'], true), 422);
            $query->where('is_active', $request->input('status') === 'active');
        }

        if ($request->filled('class_id')) {
            $query->whereHas('siswa', fn ($q) => $q->where('kelas_id', $request->integer('class_id')));
        }

        if ($request->filled('subject_id')) {
            $query->whereHas('guru.jadwalPelajaran', fn ($q) => $q->where('mapel_id', $request->integer('subject_id')));
        }

        $accounts = $query->orderBy('role')->orderBy('name')->paginate(12)->withQueryString();

        $stats = [
            'guru' => User::where('role', 'guru')->count(),
            'siswa' => User::where('role', 'siswa')->count(),
            'active' => User::whereIn('role', ['guru', 'siswa'])->where('is_active', true)->count(),
            'inactive' => User::whereIn('role', ['guru', 'siswa'])->where('is_active', false)->count(),
        ];

        return view('admin.accounts.index', [
            'accounts' => $accounts,
            'stats' => $stats,
            'role' => $role,
            'showDeleted' => $showDeleted,
            'classes' => Kelas::orderBy('tingkat')->orderBy('nama_kelas')->get(),
            'subjects' => MataPelajaran::orderBy('nama')->get(),
        ]);
    }

    public function create(string $role): View
    {
        $this->assertManagedRole($role);

        return view('admin.accounts.create', [
            'role' => $role,
            'classes' => Kelas::orderBy('tingkat')->orderBy('nama_kelas')->get(),
        ]);
    }

    public function store(Request $request, string $role): RedirectResponse
    {
        $this->assertManagedRole($role);
        $validated = $this->validateAccount($request, $role);

        $user = DB::transaction(function () use ($validated, $role) {
            $user = User::create([
                'name' => $validated['nama_lengkap'],
                'email' => $validated['email'],
                'password' => $validated['password'],
                'role' => $role,
                'is_active' => (bool) ($validated['is_active'] ?? true),
                'must_change_password' => (bool) ($validated['must_change_password'] ?? true),
            ]);

            if ($role === 'guru') {
                Guru::create([
                    'user_id' => $user->id,
                    'nip' => $validated['nip'],
                    'nama_lengkap' => $validated['nama_lengkap'],
                    'jenis_kelamin' => $validated['jenis_kelamin'],
                    'telepon' => $validated['telepon'] ?? null,
                    'alamat' => $validated['alamat'] ?? null,
                ]);
            } else {
                Siswa::create([
                    'user_id' => $user->id,
                    'nis' => $validated['nis'],
                    'nisn' => $validated['nisn'],
                    'nama_lengkap' => $validated['nama_lengkap'],
                    'jenis_kelamin' => $validated['jenis_kelamin'],
                    'tanggal_lahir' => $validated['tanggal_lahir'],
                    'tempat_lahir' => $validated['tempat_lahir'],
                    'kelas_id' => $validated['kelas_id'],
                    'nama_wali' => $validated['nama_wali'] ?? null,
                    'telepon_wali' => $validated['telepon_wali'] ?? null,
                    'alamat' => $validated['alamat'] ?? null,
                ]);
            }

            $this->record($user, 'account_created', 'Akun ' . strtoupper($role) . ' dibuat oleh Admin.', [
                'role' => $role,
                'is_active' => $user->is_active,
            ]);

            return $user;
        });

        // Password sementara hanya ditampilkan satu kali pada halaman sukses/detail.
        return redirect()->route('admin.accounts.show', $user)
            ->with('created_credentials', [
                'email' => $user->email,
                'password' => $validated['password'],
                'must_change_password' => $user->must_change_password,
            ])
            ->with('success', 'Akun berhasil dibuat. Simpan kredensial sementara berikut.');
    }

    public function show(User $user): View
    {
        $this->assertManagedUser($user);
        $user->load([
            'guru.jadwalPelajaran.mataPelajaran',
            'guru.jadwalPelajaran.kelas',
            'siswa.kelas',
        ]);

        $logs = UserAccountLog::with('actor')
            ->where('target_user_id', $user->id)
            ->latest()
            ->paginate(8);

        return view('admin.accounts.show', compact('user', 'logs'));
    }

    public function edit(User $user): View
    {
        $this->assertManagedUser($user);
        $user->load(['guru', 'siswa']);

        return view('admin.accounts.edit', [
            'user' => $user,
            'classes' => Kelas::orderBy('tingkat')->orderBy('nama_kelas')->get(),
        ]);
    }

    public function update(Request $request, User $user): RedirectResponse
    {
        $this->assertManagedUser($user);
        $role = $user->role;

        $rules = [
            'nama_lengkap' => ['required', 'string', 'max:150'],
            'email' => ['required', 'email', 'max:255', Rule::unique('users', 'email')->ignore($user->id)],
            'is_active' => ['required', 'boolean'],
            'jenis_kelamin' => ['required', Rule::in(['L', 'P'])],
            'alamat' => ['nullable', 'string', 'max:2000'],
        ];

        if ($role === 'guru') {
            $rules += [
                'nip' => ['required', 'string', 'max:20', Rule::unique('guru', 'nip')->ignore($user->guru?->id)],
                'telepon' => ['nullable', 'string', 'max:20'],
            ];
        } else {
            $rules += [
                'nis' => ['required', 'string', 'max:20', Rule::unique('siswa', 'nis')->ignore($user->siswa?->id)],
                'nisn' => ['required', 'string', 'max:20', Rule::unique('siswa', 'nisn')->ignore($user->siswa?->id)],
                'tanggal_lahir' => ['required', 'date'],
                'tempat_lahir' => ['required', 'string', 'max:100'],
                'kelas_id' => ['required', 'exists:kelas,id'],
                'nama_wali' => ['nullable', 'string', 'max:150'],
                'telepon_wali' => ['nullable', 'string', 'max:20'],
            ];
        }

        $validated = $request->validate($rules);

        DB::transaction(function () use ($user, $role, $validated) {
            $wasActive = (bool) $user->is_active;
            $user->update([
                'name' => $validated['nama_lengkap'],
                'email' => $validated['email'],
                'is_active' => (bool) $validated['is_active'],
            ]);
            if ($wasActive && ! $user->is_active) {
                $user->tokens()->delete();
                $this->record($user, 'account_deactivated', 'Akun dinonaktifkan melalui form edit Admin.');
            } elseif (! $wasActive && $user->is_active) {
                $this->record($user, 'account_activated', 'Akun diaktifkan melalui form edit Admin.');
            }

            if ($role === 'guru') {
                $user->guru()->updateOrCreate(['user_id' => $user->id], [
                    'nip' => $validated['nip'],
                    'nama_lengkap' => $validated['nama_lengkap'],
                    'jenis_kelamin' => $validated['jenis_kelamin'],
                    'telepon' => $validated['telepon'] ?? null,
                    'alamat' => $validated['alamat'] ?? null,
                ]);
            } else {
                $user->siswa()->updateOrCreate(['user_id' => $user->id], [
                    'nis' => $validated['nis'],
                    'nisn' => $validated['nisn'],
                    'nama_lengkap' => $validated['nama_lengkap'],
                    'jenis_kelamin' => $validated['jenis_kelamin'],
                    'tanggal_lahir' => $validated['tanggal_lahir'],
                    'tempat_lahir' => $validated['tempat_lahir'],
                    'kelas_id' => $validated['kelas_id'],
                    'nama_wali' => $validated['nama_wali'] ?? null,
                    'telepon_wali' => $validated['telepon_wali'] ?? null,
                    'alamat' => $validated['alamat'] ?? null,
                ]);
            }

            $this->record($user, 'account_updated', 'Informasi akun diperbarui oleh Admin.', [
                'role' => $role,
                'is_active' => $user->is_active,
            ]);
        });

        return redirect()->route('admin.accounts.show', $user)->with('success', 'Informasi akun berhasil diperbarui.');
    }

    public function resetPassword(Request $request, User $user): RedirectResponse
    {
        $this->assertManagedUser($user);
        $validated = $request->validate([
            'password' => ['required', 'string', 'min:10', 'confirmed'],
            'must_change_password' => ['nullable', 'boolean'],
        ], [
            'password.min' => 'Password sementara minimal 10 karakter.',
            'password.confirmed' => 'Konfirmasi password tidak cocok.',
        ]);

        DB::transaction(function () use ($user, $validated) {
            $user->update([
                'password' => $validated['password'],
                'must_change_password' => (bool) ($validated['must_change_password'] ?? false),
                'last_password_reset_at' => now(),
            ]);
            $user->tokens()->delete();
            $this->record($user, 'password_reset', 'Password akun direset oleh Admin.', [
                'must_change_password' => $user->must_change_password,
                'sessions_revoked' => true,
            ]);
        });

        return redirect()->route('admin.accounts.show', $user)
            ->with('reset_credentials', ['email' => $user->email, 'password' => $validated['password']])
            ->with('success', 'Password berhasil direset. Sesi aplikasi lama telah dicabut.');
    }

    public function toggleStatus(Request $request, User $user): RedirectResponse
    {
        $this->assertManagedUser($user);
        abort_if($user->id === $request->user()->id, 422, 'Admin tidak dapat menonaktifkan akun yang sedang digunakan.');

        $validated = $request->validate([
            'is_active' => ['required', 'boolean'],
            'reason' => ['nullable', 'string', 'max:500'],
        ]);

        DB::transaction(function () use ($user, $validated) {
            $user->update(['is_active' => (bool) $validated['is_active']]);
            if (! $user->is_active) {
                $user->tokens()->delete();
            }

            $action = $user->is_active ? 'account_activated' : 'account_deactivated';
            $description = $user->is_active ? 'Akun diaktifkan oleh Admin.' : 'Akun dinonaktifkan oleh Admin.';
            if (! empty($validated['reason'])) {
                $description .= ' Alasan: ' . $validated['reason'];
            }
            $this->record($user, $action, $description, ['reason' => $validated['reason'] ?? null]);
        });

        return redirect()->route('admin.accounts.show', $user)->with('success', $user->is_active ? 'Akun berhasil diaktifkan.' : 'Akun berhasil dinonaktifkan.');
    }

    /**
     * Hapus akun secara soft-delete agar histori akademik, nilai, absensi,
     * penugasan, dan jejak audit tetap utuh serta akun dapat dipulihkan.
     */
    public function destroy(Request $request, User $user): RedirectResponse
    {
        $this->assertManagedUser($user);
        abort_if($user->id === $request->user()->id, 422, 'Admin tidak dapat menghapus akun yang sedang digunakan.');

        $role = $user->role;
        $name = $user->name;

        DB::transaction(function () use ($user, $request) {
            $wasActive = (bool) $user->is_active;
            $user->tokens()->delete();
            $user->update(['is_active' => false]);
            $this->record($user, 'account_deleted', 'Akun dipindahkan ke daftar akun terhapus oleh Admin.', [
                'was_active' => $wasActive,
                'sessions_revoked' => true,
            ]);
            $user->delete();
        });

        return redirect()->route('admin.accounts.index', ['role' => $role])
            ->with('success', 'Akun ' . $name . ' berhasil dihapus. Data akademik tetap dipertahankan dan akun dapat dipulihkan dari daftar akun terhapus.');
    }

    /** Pulihkan akun yang sebelumnya dihapus, dengan status akses semula. */
    public function restore(Request $request, int $userId): RedirectResponse
    {
        $user = User::withTrashed()->findOrFail($userId);
        $this->assertManagedUser($user);
        abort_unless($user->trashed(), 404);

        $deleteMetadata = UserAccountLog::where('target_user_id', $user->id)
            ->where('action', 'account_deleted')
            ->latest('id')
            ->value('metadata');
        $metadata = is_array($deleteMetadata) ? $deleteMetadata : (is_string($deleteMetadata) ? json_decode($deleteMetadata, true) : []);
        $restoreActive = (bool) ($metadata['was_active'] ?? true);

        DB::transaction(function () use ($user, $restoreActive) {
            $user->restore();
            $user->update(['is_active' => $restoreActive]);
            $this->record($user, 'account_restored', 'Akun dipulihkan oleh Admin.', [
                'is_active' => $restoreActive,
            ]);
        });

        return redirect()->route('admin.accounts.index', ['role' => $user->role])
            ->with('success', 'Akun ' . $user->name . ' berhasil dipulihkan.');
    }

    private function validateAccount(Request $request, string $role): array
    {
        $rules = [
            'nama_lengkap' => ['required', 'string', 'max:150'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:10', 'confirmed'],
            'jenis_kelamin' => ['required', Rule::in(['L', 'P'])],
            'alamat' => ['nullable', 'string', 'max:2000'],
            'is_active' => ['nullable', 'boolean'],
            'must_change_password' => ['nullable', 'boolean'],
        ];

        if ($role === 'guru') {
            $rules += [
                'nip' => ['required', 'string', 'max:20', 'unique:guru,nip'],
                'telepon' => ['nullable', 'string', 'max:20'],
            ];
        } else {
            $rules += [
                'nis' => ['required', 'string', 'max:20', 'unique:siswa,nis'],
                'nisn' => ['required', 'string', 'max:20', 'unique:siswa,nisn'],
                'tanggal_lahir' => ['required', 'date'],
                'tempat_lahir' => ['required', 'string', 'max:100'],
                'kelas_id' => ['required', 'exists:kelas,id'],
                'nama_wali' => ['nullable', 'string', 'max:150'],
                'telepon_wali' => ['nullable', 'string', 'max:20'],
            ];
        }

        return $request->validate($rules);
    }

    private function assertManagedRole(string $role): void
    {
        abort_unless(in_array($role, ['guru', 'siswa'], true), 404);
    }

    private function assertManagedUser(User $user): void
    {
        abort_unless(in_array($user->role, ['guru', 'siswa'], true), 404);
    }

    private function record(User $target, string $action, string $description, array $metadata = []): void
    {
        UserAccountLog::create([
            'actor_id' => auth()->id(),
            'target_user_id' => $target->id,
            'action' => $action,
            'description' => $description,
            'metadata' => $metadata,
        ]);
    }
}
