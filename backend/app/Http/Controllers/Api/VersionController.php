<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppVersion;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;

class VersionController extends Controller
{
    public function latest()
    {
        try {
            // Ensure table exists
            if(!Schema::hasTable('app_versions')) {
                return response()->json([
                    'message' => 'Version table missing. Run: php artisan migrate'
                ], 500);
            }

            $version = AppVersion::orderByDesc('version_code')->first();

            // Auto-seed a default version if table empty (safety net)
            if(!$version) {
                $version = AppVersion::create([
                    'version_code' => 1,
                    'version_name' => '1.0.0',
                    'release_notes' => 'Auto-seeded initial version',
                    'is_mandatory' => false,
                    'download_url' => null,
                ]);
                Log::info('Auto-seeded initial app version (1.0.0).');
            }
            return response()->json($version);
        } catch(\Throwable $e) {
            // Log and return diagnostic JSON (more verbose in local debug)
            Log::error('Version latest failed: '.$e->getMessage(), [
                'exception' => get_class($e),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString()
            ]);
            $payload = ['message' => 'Server error fetching version'];
            if(config('app.debug')) {
                $payload['error'] = [
                    'type' => get_class($e),
                    'msg' => $e->getMessage(),
                    'file' => $e->getFile(),
                    'line' => $e->getLine(),
                ];
            }
            return response()->json($payload, 500);
        }
    }
}
