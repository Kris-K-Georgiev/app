<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\NewsController;
use App\Http\Controllers\Api\EventController;
use App\Http\Controllers\Api\VersionController;
use App\Http\Controllers\Api\HeartbeatController;
use App\Http\Controllers\Api\EventRegistrationController;
use App\Http\Controllers\Api\StreamController;
use App\Http\Controllers\Api\PostController;
use App\Http\Controllers\Api\PrayerController;
use App\Http\Controllers\Api\UserPublicController;
use App\Http\Controllers\Api\FeedbackController;

Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:6,1'); // limit new registration attempts
    Route::post('/register/verify', [AuthController::class, 'verifyRegistration']);
    Route::post('/register/resend-code', [AuthController::class, 'resendCode'])->middleware('throttle:6,1'); // 6 requests per minute
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/social', [AuthController::class, 'socialLogin']);
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword'])->middleware('throttle:5,1'); // limit reset requests
    Route::post('/reset-password', [AuthController::class, 'resetPassword']);
});

Route::get('/version/latest', [VersionController::class, 'latest']);
Route::get('/health', function() {
    $nowIso = date(DATE_ATOM); // Native ISO8601 timestamp (avoids Carbon dependency here)
    $dbStatus = [
        'connected' => false,
        'error' => null,
    ];
    $appVersions = null;
    try {
        $probe = \Illuminate\Support\Facades\DB::select('SELECT 1 as ok');
        $dbStatus['connected'] = isset($probe[0]) && ($probe[0]->ok ?? 0) == 1;
        // Only attempt versions count if basic DB connectivity succeeded
        if($dbStatus['connected']) {
            try { $appVersions = \App\Models\AppVersion::count(); } catch(\Throwable $inner) { /* ignore */ }
        }
    } catch(\Throwable $e) {
        $dbStatus['error'] = $e->getMessage();
    }

    $overall = $dbStatus['connected'] ? 'ok' : 'degraded';
    $payload = [
        'status' => $overall,
        'time' => $nowIso,
        'db' => $dbStatus,
        'app_versions_count' => $appVersions,
    ];

    // Always 200 so clients can distinguish network vs service degraded states
    return response()->json($payload, 200);
});
Route::get('/news', [NewsController::class, 'index']);
Route::get('/news/{news}', [NewsController::class, 'show']);
Route::get('/events', [EventController::class, 'index']);
Route::get('/events/{event}', [EventController::class, 'show']);
Route::get('/heartbeat', HeartbeatController::class);
Route::get('/stream', StreamController::class);
Route::get('/users/{user}', [UserPublicController::class, 'show']);
// Community public lists
Route::get('/posts', [PostController::class, 'index']);
Route::get('/prayers', [PrayerController::class, 'index']);
Route::get('/posts/{post}/comments', [PostController::class, 'listComments']);
Route::post('/feedback', [FeedbackController::class, 'store'])->middleware(['auth:sanctum','throttle:3,1']);
Route::middleware('auth:sanctum')->group(function(){
    Route::post('/events', [EventController::class, 'store']);
    Route::post('/events/{event}/register',[EventRegistrationController::class,'register']);
    Route::post('/events/{event}/unregister',[EventRegistrationController::class,'unregister']);
    Route::post('/events/{event}/promote',[EventRegistrationController::class,'promote']);
    Route::get('/events/{event}/waitlist',[EventRegistrationController::class,'waitlist']);
    // Social actions for news
    Route::post('/news/{news}/like', [NewsController::class, 'toggleLike']);
    Route::post('/news/{news}/comment', [NewsController::class, 'addComment']);
    // Posts (community)
    Route::post('/posts', [PostController::class, 'store']);
    Route::post('/posts/{post}/like', [PostController::class, 'toggleLike']);
    Route::post('/posts/{post}/comment', [PostController::class, 'addComment']);
    Route::post('/prayers', [PrayerController::class, 'store']);
    Route::put('/posts/{post}', [PostController::class, 'update']);
    Route::put('/prayers/{prayer}', [PrayerController::class, 'update']);
    Route::post('/prayers/{prayer}/like', [PrayerController::class, 'toggleLike']);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::put('/auth/profile', [AuthController::class, 'updateProfile']);
    Route::get('/auth/email-status', [AuthController::class, 'emailStatus']);
    Route::post('/auth/resend-verification', [AuthController::class, 'resendVerification']);
    Route::get('/auth/verify-email', [AuthController::class, 'verifyEmail'])->middleware('signed');
});
