<?php

namespace App\Providers;

use Illuminate\Support\Facades\Blade;
use Illuminate\Support\ServiceProvider;

class IconServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        Blade::directive('icon', function ($expression) {
            return "<?php echo view('components.admin.icon', ['name' => $expression])->render(); ?>";
        });
    }
}
