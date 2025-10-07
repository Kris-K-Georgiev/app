<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\NewsAdminController;
use App\Http\Controllers\Admin\EventAdminController;
use App\Http\Controllers\Admin\UserAdminController;
use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\StatsController;

Route::get('/', function () {
    return view('welcome');
});

// Public email verification (user clicks link in email). This uses built-in signed verification URL.
// After verification, user can return to the app which can poll /auth/email-status.
Route::get('/email/verify/{id}/{hash}', function (\Illuminate\Http\Request $request, $id, $hash) {
    $user = \App\Models\User::findOrFail($id);
    if (! hash_equals((string) $hash, sha1($user->getEmailForVerification()))) {
        abort(403, 'Invalid verification hash');
    }
    if (!$user->hasVerifiedEmail()) {
        $user->markEmailAsVerified();
    }
    return response('<html><body style="font-family:Arial;padding:24px"><h2>Email verified</h2><p>You can now return to the BHSS Connect app.</p></body></html>');
})->middleware(['signed'])->name('verification.verify');

Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('/login', [AdminAuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AdminAuthController::class, 'login'])->name('login.submit');
    Route::post('/logout', [AdminAuthController::class, 'logout'])->name('logout');

    // Authenticated admin area
    Route::middleware(['auth', \App\Http\Middleware\AdminOnly::class, \App\Http\Middleware\ReadOnlyIfWorker::class])->group(function () {
        Route::get('/', [DashboardController::class, 'index'])->name('dashboard');
        Route::resource('news', NewsAdminController::class)->except(['show']);
        Route::resource('events', EventAdminController::class)->except(['show']);
    Route::resource('users', UserAdminController::class)->except(['show','create','store']);
    Route::resource('versions', \App\Http\Controllers\Admin\AppVersionAdminController::class)->except(['show']);
        Route::post('news/reorder', [NewsAdminController::class,'reorder'])->name('news.reorder');
    Route::get('users/{user}/profile',[UserAdminController::class,'profile'])->name('users.profile');
    Route::put('users/{user}/profile',[UserAdminController::class,'profileUpdate'])->middleware('canChangeRole')->name('users.profile.update');
    Route::get('stats/summary',[StatsController::class,'summary']);
        // Bulk + export routes
        Route::post('users/bulk-delete', [UserAdminController::class,'bulkDelete'])->name('users.bulkDelete');
        Route::get('users/export', [UserAdminController::class,'export'])->name('users.export');
        Route::post('news/bulk-delete', [NewsAdminController::class,'bulkDelete'])->name('news.bulkDelete');
        Route::get('news/export', [NewsAdminController::class,'export'])->name('news.export');
        Route::post('events/bulk-delete', [EventAdminController::class,'bulkDelete'])->name('events.bulkDelete');
        Route::get('events/export', [EventAdminController::class,'export'])->name('events.export');
    });
});

