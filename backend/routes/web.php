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

        // Admin SPA entry (serves Vue root). Use a single blade that loads Vite entrypoint admin-spa/main.js
        Route::get('spa', function(){
            return view('admin.spa');
        })->name('spa');

        // JSON API for SPA under /admin/api/* now session (web guard) protected
        Route::prefix('api')->group(function(){
            Route::get('metrics', function(){
                return [
                    'users' => \App\Models\User::count(),
                    'posts' => \App\Models\Post::count(),
                    'prayers' => \App\Models\Prayer::count(),
                    'events' => \App\Models\Event::count(),
                    'news' => \App\Models\News::count(),
                    'feedback' => \App\Models\Feedback::count(),
                    'versions' => \App\Models\AppVersion::count(),
                ];
            });
            Route::get('users', function(){
                $q=\App\Models\User::query();
                if($s=request('search')){ $q->where(function($qq) use ($s){ $qq->where('name','like',"%$s%") ->orWhere('email','like',"%$s% "); }); }
                return $q->latest()->paginate((int)request('per_page',50));
            });
            Route::get('posts', function(){
                $p=\App\Models\Post::with('user:id,name')->withCount(['likes','comments'])->latest()->paginate((int)request('per_page',50));
                $p->getCollection()->transform(function($r){ return [ 'id'=>$r->id,'content'=>$r->content,'author'=>$r->user?->only(['id','name']),'likes_count'=>$r->likes_count,'comments_count'=>$r->comments_count,'created_at'=>$r->created_at ]; });
                return $p;
            });
            Route::get('prayers', function(){
                $p=\App\Models\Prayer::with('user:id,name')->latest()->paginate((int)request('per_page',50));
                $p->getCollection()->transform(function($r){ return [ 'id'=>$r->id,'content'=>$r->content,'user'=>$r->user?->only(['id','name']),'is_anonymous'=>$r->is_anonymous,'answered'=>$r->answered,'created_at'=>$r->created_at ]; });
                return $p;
            });
            Route::get('feedback', function(){
                return \App\Models\Feedback::with('user:id,name')->latest()->paginate((int)request('per_page',50));
            });
            Route::get('events', function(){
                return \App\Models\Event::with('type:id,name')->latest()->paginate((int)request('per_page',50));
            });
            Route::get('news', function(){
                return \App\Models\News::with('author:id,name')->latest()->paginate((int)request('per_page',50));
            });
            Route::get('feedback-items',[\App\Http\Controllers\Admin\Api\FeedbackApiController::class,'index']);
            Route::patch('feedback-items/{feedback}/status',[\App\Http\Controllers\Admin\Api\FeedbackApiController::class,'updateStatus']);
            Route::get('feedback-items/{feedback}',[\App\Http\Controllers\Admin\Api\FeedbackApiController::class,'show']);
            // CRUD Users
            Route::get('crud/users',[\App\Http\Controllers\Admin\Api\UsersCrudController::class,'index']);
            Route::post('crud/users',[\App\Http\Controllers\Admin\Api\UsersCrudController::class,'store']);
            Route::get('crud/users/{user}',[\App\Http\Controllers\Admin\Api\UsersCrudController::class,'show']);
            Route::put('crud/users/{user}',[\App\Http\Controllers\Admin\Api\UsersCrudController::class,'update']);
            Route::delete('crud/users/{user}',[\App\Http\Controllers\Admin\Api\UsersCrudController::class,'destroy']);
            Route::patch('crud/users/{id}/restore',[\App\Http\Controllers\Admin\Api\UsersCrudController::class,'restore']);
            // CRUD Posts
            Route::get('crud/posts',[\App\Http\Controllers\Admin\Api\PostsCrudController::class,'index']);
            Route::post('crud/posts',[\App\Http\Controllers\Admin\Api\PostsCrudController::class,'store']);
            Route::get('crud/posts/{post}',[\App\Http\Controllers\Admin\Api\PostsCrudController::class,'show']);
            Route::put('crud/posts/{post}',[\App\Http\Controllers\Admin\Api\PostsCrudController::class,'update']);
            Route::delete('crud/posts/{post}',[\App\Http\Controllers\Admin\Api\PostsCrudController::class,'destroy']);
            Route::patch('crud/posts/{id}/restore',[\App\Http\Controllers\Admin\Api\PostsCrudController::class,'restore']);
            // CRUD Prayers
            Route::get('crud/prayers',[\App\Http\Controllers\Admin\Api\PrayersCrudController::class,'index']);
            Route::post('crud/prayers',[\App\Http\Controllers\Admin\Api\PrayersCrudController::class,'store']);
            Route::get('crud/prayers/{prayer}',[\App\Http\Controllers\Admin\Api\PrayersCrudController::class,'show']);
            Route::put('crud/prayers/{prayer}',[\App\Http\Controllers\Admin\Api\PrayersCrudController::class,'update']);
            Route::delete('crud/prayers/{prayer}',[\App\Http\Controllers\Admin\Api\PrayersCrudController::class,'destroy']);
            Route::patch('crud/prayers/{id}/restore',[\App\Http\Controllers\Admin\Api\PrayersCrudController::class,'restore']);
            // CRUD News
            Route::get('crud/news',[\App\Http\Controllers\Admin\Api\NewsCrudController::class,'index']);
            Route::post('crud/news',[\App\Http\Controllers\Admin\Api\NewsCrudController::class,'store']);
            Route::get('crud/news/{news}',[\App\Http\Controllers\Admin\Api\NewsCrudController::class,'show']);
            Route::put('crud/news/{news}',[\App\Http\Controllers\Admin\Api\NewsCrudController::class,'update']);
            Route::delete('crud/news/{news}',[\App\Http\Controllers\Admin\Api\NewsCrudController::class,'destroy']);
            Route::patch('crud/news/{id}/restore',[\App\Http\Controllers\Admin\Api\NewsCrudController::class,'restore']);
            // CRUD Events
            Route::get('crud/events',[\App\Http\Controllers\Admin\Api\EventsCrudController::class,'index']);
            Route::post('crud/events',[\App\Http\Controllers\Admin\Api\EventsCrudController::class,'store']);
            Route::get('crud/events/{event}',[\App\Http\Controllers\Admin\Api\EventsCrudController::class,'show']);
            Route::put('crud/events/{event}',[\App\Http\Controllers\Admin\Api\EventsCrudController::class,'update']);
            Route::delete('crud/events/{event}',[\App\Http\Controllers\Admin\Api\EventsCrudController::class,'destroy']);
            Route::patch('crud/events/{id}/restore',[\App\Http\Controllers\Admin\Api\EventsCrudController::class,'restore']);
            // CRUD Versions
            Route::get('crud/versions',[\App\Http\Controllers\Admin\Api\VersionsCrudController::class,'index']);
            Route::post('crud/versions',[\App\Http\Controllers\Admin\Api\VersionsCrudController::class,'store']);
            Route::get('crud/versions/{version}',[\App\Http\Controllers\Admin\Api\VersionsCrudController::class,'show']);
            Route::put('crud/versions/{version}',[\App\Http\Controllers\Admin\Api\VersionsCrudController::class,'update']);
            Route::delete('crud/versions/{version}',[\App\Http\Controllers\Admin\Api\VersionsCrudController::class,'destroy']);
        });
    });
});

