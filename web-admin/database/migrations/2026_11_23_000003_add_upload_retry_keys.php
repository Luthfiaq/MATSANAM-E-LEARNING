<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('penugasan', function (Blueprint $table) {
            $table->string('client_request_id', 80)->nullable()->unique();
            $table->string('last_attachment_batch_id', 80)->nullable();
        });

        Schema::table('pengumpulan_tugas', function (Blueprint $table) {
            $table->string('last_upload_batch_id', 80)->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('pengumpulan_tugas', function (Blueprint $table) {
            $table->dropColumn('last_upload_batch_id');
        });

        Schema::table('penugasan', function (Blueprint $table) {
            $table->dropUnique(['client_request_id']);
            $table->dropColumn(['client_request_id', 'last_attachment_batch_id']);
        });
    }
};
