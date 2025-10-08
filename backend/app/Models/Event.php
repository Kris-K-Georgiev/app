<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

/**
 * @property int $id
 * @property string|null $title
 * @property string|null $description
 * @property string|null $location
 * @property string|null $city
 * @property string|null $audience
 * @property string|null $status
 * @property string|null $cover
 * @property array<int,string>|null $images
 * @property \Carbon\Carbon|null $start_date
 * @property \Carbon\Carbon|null $end_date
 * @property int|null $limit
 * @property int|null $registrations_count
 */
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

    // Provide a normalized city_name attribute (could later map IDs to names)
    public function getCityNameAttribute(): ?string
    {
        return $this->city; // direct passthrough for now
    }
}
