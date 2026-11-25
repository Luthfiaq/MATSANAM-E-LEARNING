<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('absensi_sesi', function (Blueprint $table) {
            $table->decimal('lokasi_latitude', 10, 8)->nullable()->change();
            $table->decimal('lokasi_longitude', 11, 8)->nullable()->change();
        });
    }

    public function down(): void
    {
        // Restore valid school coordinates before making the fields required.
        DB::table('absensi_sesi')->whereNull('lokasi_latitude')->update([
            'lokasi_latitude' => -7.6722077,
        ]);
        DB::table('absensi_sesi')->whereNull('lokasi_longitude')->update([
            'lokasi_longitude' => 112.0538249,
        ]);

        Schema::table('absensi_sesi', function (Blueprint $table) {
            $table->decimal('lokasi_latitude', 10, 8)->nullable(false)->change();
            $table->decimal('lokasi_longitude', 11, 8)->nullable(false)->change();
        });
    }
};
