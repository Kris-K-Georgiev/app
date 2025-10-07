<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AppVersion;
use Illuminate\Http\Request;

class AppVersionAdminController extends Controller
{
    public function index(){
        $items = AppVersion::orderByDesc('version_code')->paginate(20);
        return view('admin.versions.index', compact('items'));
    }
    public function create(){ return view('admin.versions.create'); }
    public function store(Request $r){
        $data = $r->validate([
            'version_code'=>'required|integer|min:1',
            'version_name'=>'required|string',
            'release_notes'=>'nullable|string',
            'is_mandatory'=>'nullable|boolean',
            'download_url'=>'nullable|url'
        ]);
        $data['is_mandatory'] = (bool)($data['is_mandatory'] ?? false);
        AppVersion::create($data);
        return redirect()->route('admin.versions.index')->with('ok','Version created');
    }
    public function edit(AppVersion $version){ return view('admin.versions.edit', compact('version')); }
    public function update(Request $r, AppVersion $version){
        $data = $r->validate([
            'version_code'=>'required|integer|min:1',
            'version_name'=>'required|string',
            'release_notes'=>'nullable|string',
            'is_mandatory'=>'nullable|boolean',
            'download_url'=>'nullable|url'
        ]);
        $data['is_mandatory'] = (bool)($data['is_mandatory'] ?? false);
        $version->update($data);
        return redirect()->route('admin.versions.index')->with('ok','Updated');
    }
    public function destroy(AppVersion $version){ $version->delete(); return back()->with('ok','Deleted'); }
}
