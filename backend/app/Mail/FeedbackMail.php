<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class FeedbackMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(public array $payload) {}

    public function build()
    {
        return $this->subject('New Feedback Submitted')
            ->view('emails.feedback')
            ->with($this->payload);
    }
}
