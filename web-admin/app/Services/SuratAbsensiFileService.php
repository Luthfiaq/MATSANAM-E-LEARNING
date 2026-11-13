<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Illuminate\Http\Response;

class SuratAbsensiFileService
{
    public function store(UploadedFile $file): string
    {
        return $file->store('surat-absensi', 'local');
    }

    /** Resolve private uploads first, then allow legacy public files to keep working. */
    public function diskFor(?string $path): ?string
    {
        if (! is_string($path) || $path === '') {
            return null;
        }

        $normalized = ltrim($path, '/');
        if (
            $normalized !== $path
            || ! str_starts_with($normalized, 'surat-absensi/')
            || str_contains($normalized, '..')
        ) {
            return null;
        }

        foreach (['local', 'public'] as $disk) {
            if (Storage::disk($disk)->exists($normalized)) {
                return $disk;
            }
        }

        return null;
    }

    public function download(string $path): StreamedResponse
    {
        $disk = $this->diskFor($path);
        abort_unless($disk, 404, 'Dokumen surat tidak ditemukan.');

        return Storage::disk($disk)->download($path, basename($path));
    }

    public function response(string $path): Response|StreamedResponse
    {
        $disk = $this->diskFor($path);
        abort_unless($disk, 404, 'Dokumen surat tidak ditemukan.');

        return Storage::disk($disk)->response($path, basename($path));
    }

    public function delete(?string $path): void
    {
        if ($this->diskFor($path) === null) {
            return;
        }

        Storage::disk('local')->delete($path);
        Storage::disk('public')->delete($path);
    }
}
