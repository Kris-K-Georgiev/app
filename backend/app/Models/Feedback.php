<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Feedback extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'feedback';

    protected $fillable = [
        'user_id','message','contact','user_agent','ip',
        'status','severity','handled_by','handled_at','context'
    ];

    protected $casts = [
        'handled_at' => 'datetime',
        'severity' => 'integer',
        'context' => 'array'
    ];

    // Relationships
    public function user(){ return $this->belongsTo(User::class); }
    public function handler(){ return $this->belongsTo(User::class,'handled_by'); }

    // Scopes
    public function scopeStatus($q,$status){ if($status!==null && $status!=='') $q->where('status',$status); }
    public function scopeSeverity($q,$min,$max=null){
        if($min!==null && $min!=='') $q->where('severity','>=',(int)$min);
        if($max!==null && $max!=='') $q->where('severity','<=',(int)$max);
    }
    public function scopeDateBetween($q,$from,$to){
        if($from) $q->where('created_at','>=',$from);
        if($to) $q->where('created_at','<=',$to);
    }
}
