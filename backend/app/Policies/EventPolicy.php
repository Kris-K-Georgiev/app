<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Event;

class EventPolicy
{
    public function promote(User $user, Event $event): bool
    {
        return $user->role === 'admin';
    }

    public function viewWaitlist(User $user, Event $event): bool
    {
        return $user->role === 'admin';
    }
}
