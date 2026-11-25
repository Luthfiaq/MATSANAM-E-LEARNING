<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('penugasan_files', function (Blueprint $table) {
            $table->id();
            $table->foreignId('penugasan_id')->constrained('penugasan')->cascadeOnDelete();
            $table->string('disk', 40)->default('public');
            $table->string('file_path');
            $table->string('original_name');
            $table->string('mime_type', 150)->nullable();
            $table->unsignedBigInteger('size_bytes')->default(0);
            $table->timestamps();
            $table->index(['penugasan_id', 'id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('penugasan_files');
    }
};
