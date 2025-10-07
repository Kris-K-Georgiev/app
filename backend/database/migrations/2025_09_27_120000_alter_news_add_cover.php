<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if(Schema::hasTable('news') && !Schema::hasColumn('news','cover')) {
            Schema::table('news', function(Blueprint $table){
                $table->string('cover')->nullable()->after('content');
            });
        }
    }
    public function down(): void
    {
        Schema::table('news', function(Blueprint $table){
            $table->dropColumn('cover');
        });
    }
};
