<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pengumpulan_tugas_files', function (Blueprint $table) {
            $table->id();
            $table->foreignId('pengumpulan_id')
                ->constrained('pengumpulan_tugas')
                ->cascadeOnDelete();
            $table->string('disk', 32)->default('local');
            $table->string('file_path');
            $table->string('original_name');
            $table->string('mime_type', 150)->nullable();
            $table->unsignedBigInteger('size_bytes')->default(0);
            $table->timestamps();

            $table->index(['pengumpulan_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pengumpulan_tugas_files');
    }
};
