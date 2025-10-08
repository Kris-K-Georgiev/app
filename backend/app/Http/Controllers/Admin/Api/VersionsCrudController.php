<?php
namespace App\Http\Controllers\Admin\Api;

use App\Http\Controllers\Controller;
use App\Models\AppVersion;
use Illuminate\Http\Request;

class VersionsCrudController extends Controller
{
    public function index(Request $r){
        $q = AppVersion::query();
        $q->orderByDesc('version_code');
        return $q->paginate((int)$r->query('per_page',30));
    }
    public function show(AppVersion $version){ return ['data'=>$version]; }
    public function store(Request $r){
        $data=$r->validate([
            'version_code'=>'required|integer|min:1',
            'version_name'=>'required|string',
            'release_notes'=>'nullable|string',
            'is_mandatory'=>'nullable|boolean',
            'download_url'=>'nullable|url'
        ]);
        $data['is_mandatory']=(bool)($data['is_mandatory']??false);
        $v=AppVersion::create($data);
        return response()->json(['data'=>$v],201);
    }
    public function update(Request $r, AppVersion $version){
        $data=$r->validate([
            'version_code'=>'sometimes|required|integer|min:1',
            'version_name'=>'sometimes|required|string',
            'release_notes'=>'sometimes|nullable|string',
            'is_mandatory'=>'sometimes|boolean',
            'download_url'=>'sometimes|nullable|url'
        ]);
        $version->update($data);
        return ['data'=>$version];
    }
    public function destroy(AppVersion $version){ $version->delete(); return ['ok'=>true]; }
}
