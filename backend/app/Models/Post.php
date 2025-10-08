<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Post extends Model
{
    use HasFactory;

    protected $fillable = [ 'user_id','content','image' ];
    
    /**
     * User who created the post.
     * @return BelongsTo<User,Post>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Likes on this post.
     * @return HasMany<PostLike>
     */
    public function likes(): HasMany
    {
        return $this->hasMany(PostLike::class);
    }

    /**
     * Comments on this post.
     * @return HasMany<PostComment>
     */
    public function comments(): HasMany
    {
        return $this->hasMany(PostComment::class);
    }
}
