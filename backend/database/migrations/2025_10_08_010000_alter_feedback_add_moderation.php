<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if(!Schema::hasTable('feedback')) return; // table will be created by initial migration
        Schema::table('feedback', function(Blueprint $table){
            if(!Schema::hasColumn('feedback','status')) $table->enum('status',['new','reviewed','closed'])->default('new')->after('ip');
            if(!Schema::hasColumn('feedback','severity')) $table->tinyInteger('severity')->nullable()->after('status');
            if(!Schema::hasColumn('feedback','handled_by')) $table->foreignId('handled_by')->nullable()->after('severity')->constrained('users')->nullOnDelete();
            if(!Schema::hasColumn('feedback','handled_at')) $table->timestamp('handled_at')->nullable()->after('handled_by');
            if(!Schema::hasColumn('feedback','context')) $table->json('context')->nullable()->after('handled_at');
            if(!Schema::hasColumn('feedback','deleted_at')) $table->softDeletes();
        });
        // Add indexes separately to avoid duplicates
        Schema::table('feedback', function(Blueprint $table){
            $indexes = Schema::getConnection()->getDoctrineSchemaManager()->listTableIndexes('feedback');
            $hasStatusCreated = array_key_exists('feedback_status_created_at_index', $indexes) || array_key_exists('status_created_at_index',$indexes);
            if(!$hasStatusCreated) $table->index(['status','created_at']);
            if(!array_key_exists('feedback_handled_by_index',$indexes)) $table->index('handled_by');
            $hasUserCreated = false;
            foreach($indexes as $name=>$idx){ if($idx->isComposite() && $idx->getColumns()===['user_id','created_at']) { $hasUserCreated=true; break; } }
            if(!$hasUserCreated) $table->index(['user_id','created_at']);
        });
    }
    public function down(): void
    {
        // Non-destructive down (leave columns), or optionally implement drops.
    }
};