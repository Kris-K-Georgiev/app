<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Prayer extends Model
{
    use HasFactory;
    protected $fillable = ['user_id','content','is_anonymous','answered'];
    protected $casts = [ 'is_anonymous' => 'boolean', 'answered' => 'boolean' ];
    public function user(){ return $this->belongsTo(User::class); }
    public function likes(){ return $this->hasMany(PrayerLike::class); }
}
