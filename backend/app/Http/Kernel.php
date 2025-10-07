<?php

namespace App\Http;

use Illuminate\Foundation\Http\Kernel as HttpKernel;

class Kernel extends HttpKernel
{
    /** @var array<int, class-string|string> */
    protected $middleware = [
        // Global middleware kept minimal for now
        \Illuminate\Http\Middleware\HandleCors::class,
        \Illuminate\Foundation\Http\Middleware\ValidatePostSize::class,
        \Illuminate\Foundation\Http\Middleware\ConvertEmptyStringsToNull::class,
    ];

    /** @var array<string, array<int, class-string|string>> */
    protected $middlewareGroups = [
        'web' => [
            // If you need sessions / CSRF later, reintroduce the standard web middleware stack.
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
        ],
        'api' => [
            // Rate limiting
            'throttle:api',
            // Bind route model parameters
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
        ],
    ];

    /**
     * Route middleware / aliases.
     * Laravel 11+ uses $middlewareAliases instead of $routeMiddleware.
     * Renamed to ensure aliases (like readOnlyWorker) register correctly.
     * @var array<string, class-string|string>
     */
    protected $middlewareAliases = [
        'auth' => \Illuminate\Auth\Middleware\Authenticate::class,
        'signed' => \Illuminate\Routing\Middleware\ValidateSignature::class,
        'throttle' => \Illuminate\Routing\Middleware\ThrottleRequests::class,
        'verified' => \Illuminate\Auth\Middleware\EnsureEmailIsVerified::class,
        'admin' => \App\Http\Middleware\AdminOnly::class,
        'canChangeRole' => \App\Http\Middleware\CanChangeUserRole::class,
        'readOnlyWorker' => \App\Http\Middleware\ReadOnlyIfWorker::class,
    ];

    // Legacy compatibility (some packages may still look for $routeMiddleware)
    protected $routeMiddleware = [];

    public function __construct(\Illuminate\Foundation\Application $app, \Illuminate\Routing\Router $router)
    {
        parent::__construct($app, $router);
        // Mirror aliases into legacy property
        $this->routeMiddleware = $this->middlewareAliases;
    }
}
