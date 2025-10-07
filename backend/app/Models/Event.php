<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Event extends Model
{
    use HasFactory;

    protected $fillable = [
        'title', 'description', 'location', 'start_date','end_date','start_time','images','cover','city','audience','limit','registrations_count','event_type_id','status','created_by'
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'images' => 'array',
    ];

    // Accessor synonyms for spec alignment
    public function getMaxParticipantsAttribute(): ?int { return $this->limit; }
    public function getCoverImageAttribute(): ?string { return $this->cover; }

    // Relationships
    public function type()
    {
        return $this->belongsTo(EventType::class, 'event_type_id');
    }

    public function author()
    {
        return $this->belongsTo(User::class,'created_by');
    }
}
