<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class News extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'title', 'content', 'image', 'cover','status','created_by'
    ];

    public function images()
    {
        return $this->hasMany(NewsImage::class)->orderBy('position');
    }

    public function author()
    {
        return $this->belongsTo(User::class,'created_by');
    }

    public function likes()
    {
        return $this->hasMany(NewsLike::class);
    }

    public function comments()
    {
        return $this->hasMany(NewsComment::class);
    }
}
