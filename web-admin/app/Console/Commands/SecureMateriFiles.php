<?php

namespace App\Console\Commands;

use App\Models\Materi;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;

class SecureMateriFiles extends Command
{
    protected $signature = 'materi:secure-files {--dry-run : Tampilkan rencana pemindahan tanpa mengubah file}';

    protected $description = 'Pindahkan lampiran materi lama dari disk public ke disk local privat.';

    public function handle(): int
    {
        $dryRun = (bool) $this->option('dry-run');
        $counts = [
            'moved' => 0,
            'already_private' => 0,
            'missing' => 0,
            'conflicts' => 0,
        ];

        if ($dryRun) {
            $this->warn('Mode dry-run aktif. Tidak ada file yang diubah.');
        }

        Materi::query()
            ->whereNotNull('file_path')
            ->orderBy('id')
            ->chunkById(100, function ($items) use (&$counts, $dryRun) {
                foreach ($items as $materi) {
                    $path = ltrim((string) $materi->file_path, '/');
                    if ($path === '') {
                        $counts['missing']++;
                        $this->warn("Materi #{$materi->id}: path file kosong.");
                        continue;
                    }
                    if ($path !== $materi->file_path || ! str_starts_with($path, 'materi/') || str_contains($path, '..')) {
                        $counts['conflicts']++;
                        $this->error("Materi #{$materi->id}: path di luar direktori materi; file dilewati untuk pemeriksaan manual.");
                        continue;
                    }

                    $local = Storage::disk('local');
                    $public = Storage::disk('public');
                    $localExists = $local->exists($path);
                    $publicExists = $public->exists($path);

                    if ($localExists && $publicExists) {
                        if (! $this->sameContent($local, $public, $path)) {
                            $counts['conflicts']++;
                            $this->error("Materi #{$materi->id}: checksum file local/public berbeda; kedua salinan dipertahankan.");
                            continue;
                        }

                        $counts['already_private']++;
                        if ($dryRun) {
                            $this->line("Materi #{$materi->id}: salinan local/public identik; salinan public akan dihapus.");
                        } elseif (! $public->delete($path) || $public->exists($path)) {
                            $counts['conflicts']++;
                            $this->error("Materi #{$materi->id}: salinan publik identik tidak dapat dihapus; keduanya dipertahankan.");
                        }
                        continue;
                    }

                    if ($localExists) {
                        $counts['already_private']++;
                        continue;
                    }

                    if (! $publicExists) {
                        $counts['missing']++;
                        $this->warn("Materi #{$materi->id}: file tidak ditemukan di disk local maupun public.");
                        continue;
                    }

                    if ($dryRun) {
                        $counts['moved']++;
                        $this->line("Materi #{$materi->id}: akan dipindahkan {$path}");
                        continue;
                    }

                    $stream = $public->readStream($path);
                    if (! is_resource($stream)) {
                        $counts['conflicts']++;
                        $this->error("Materi #{$materi->id}: stream file public tidak dapat dibaca; file dipertahankan.");
                        continue;
                    }

                    try {
                        $written = $local->writeStream($path, $stream);
                    } catch (\Throwable $exception) {
                        $written = false;
                    } finally {
                        if (is_resource($stream)) {
                            fclose($stream);
                        }
                    }

                    if (! $written || ! $local->exists($path) || ! $this->sameContent($local, $public, $path)) {
                        $local->delete($path);
                        $counts['conflicts']++;
                        $this->error("Materi #{$materi->id}: verifikasi checksum salinan gagal; file public dipertahankan.");
                        continue;
                    }

                    if (! $public->delete($path) || $public->exists($path)) {
                        $counts['conflicts']++;
                        $this->error("Materi #{$materi->id}: salinan privat terverifikasi, tetapi salinan publik tidak dapat dihapus.");
                        continue;
                    }

                    $counts['moved']++;
                }
            });

        $this->newLine();
        $this->table(
            ['Status', 'Jumlah'],
            [
                ['Dipindahkan / akan dipindahkan', $counts['moved']],
                ['Sudah privat', $counts['already_private']],
                ['File tidak ditemukan', $counts['missing']],
                ['Konflik salinan', $counts['conflicts']],
            ],
        );

        if ($counts['conflicts'] > 0 || $counts['missing'] > 0) {
            $this->warn('Periksa materi yang bermasalah sebelum menghapus backup atau menganggap migrasi file selesai.');
        }

        return ($counts['conflicts'] > 0 || $counts['missing'] > 0)
            ? self::FAILURE
            : self::SUCCESS;
    }

    private function sameContent($firstDisk, $secondDisk, string $path): bool
    {
        $first = $firstDisk->readStream($path);
        $second = $secondDisk->readStream($path);

        if (! is_resource($first) || ! is_resource($second)) {
            if (is_resource($first)) fclose($first);
            if (is_resource($second)) fclose($second);
            return false;
        }

        try {
            return hash_equals($this->streamHash($first), $this->streamHash($second));
        } catch (\Throwable $exception) {
            return false;
        } finally {
            fclose($first);
            fclose($second);
        }
    }

    private function streamHash($stream): string
    {
        $context = hash_init('sha256');
        while (! feof($stream)) {
            $chunk = fread($stream, 1024 * 1024);
            if ($chunk === false) {
                throw new \RuntimeException('Gagal membaca stream saat menghitung checksum.');
            }
            if ($chunk !== '') {
                hash_update($context, $chunk);
            }
        }

        return hash_final($context);
    }
}
