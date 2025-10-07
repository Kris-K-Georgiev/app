<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class VerificationCodeMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(public string $code) {}

    public function build()
    {
        // If you later want to embed the image inline (cid), you could use: ->attach(public_path('logo.png')) and reference cid.
        return $this->subject('BHSS Connect - Вашият код за потвърждение')
            ->view('emails.verify_code')
            ->with(['code' => $this->code]);
    }
}
