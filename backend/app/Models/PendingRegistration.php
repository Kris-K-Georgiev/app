<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PendingRegistration extends Model
{
    protected $fillable = [
        'first_name','last_name','email','password_hash','city','code','attempts','expires_at','last_sent_at'
    ];
    protected $casts = [
        'expires_at' => 'datetime',
        'last_sent_at' => 'datetime'
    ];

    public function getFullNameAttribute(): string
    {
        return trim(($this->first_name ?? '').' '.($this->last_name ?? ''));
    }
}
