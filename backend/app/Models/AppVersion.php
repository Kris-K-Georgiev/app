<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AppVersion extends Model
{
    use HasFactory;

    protected $fillable = [
        'version_code', 'version_name', 'release_notes', 'is_mandatory', 'download_url'
    ];

    protected $casts = [
        'is_mandatory' => 'boolean',
    ];
}
