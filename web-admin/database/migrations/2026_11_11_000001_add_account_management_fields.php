<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $missingColumns = [];
        foreach (['last_login_at', 'must_change_password', 'last_password_reset_at'] as $column) {
            if (! Schema::hasColumn('users', $column)) {
                $missingColumns[] = $column;
            }
        }

        if ($missingColumns !== []) {
            Schema::table('users', function (Blueprint $table) use ($missingColumns) {
                if (in_array('last_login_at', $missingColumns, true)) {
                    $table->timestamp('last_login_at')->nullable();
                }
                if (in_array('must_change_password', $missingColumns, true)) {
                    $table->boolean('must_change_password')->default(false);
                }
                if (in_array('last_password_reset_at', $missingColumns, true)) {
                    $table->timestamp('last_password_reset_at')->nullable();
                }
            });
        }

        if (! Schema::hasTable('user_account_logs')) {
            Schema::create('user_account_logs', function (Blueprint $table) {
                $table->id();
                $table->foreignId('actor_id')->nullable()->constrained('users')->nullOnDelete();
                $table->foreignId('target_user_id')->nullable()->constrained('users')->nullOnDelete();
                $table->string('action', 60);
                $table->text('description');
                $table->json('metadata')->nullable();
                $table->timestamps();
                $table->index(['target_user_id', 'created_at']);
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('user_account_logs');

        $existingColumns = array_values(array_filter(
            ['last_password_reset_at', 'must_change_password', 'last_login_at'],
            fn (string $column) => Schema::hasColumn('users', $column)
        ));

        if ($existingColumns !== []) {
            Schema::table('users', fn (Blueprint $table) => $table->dropColumn($existingColumns));
        }
    }
};
