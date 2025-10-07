<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Auth as FacadeAuth;

class UserAdminController extends Controller
{
    public function index(Request $request)
    {
        $q = User::query();
        if($s = $request->query('search')) {
            $q->where(function($qq) use ($s){
                $qq->where('name','like',"%$s%")
                    ->orWhere('email','like',"%$s%");
            });
        }
        if($role = $request->query('role')) { $q->where('role',$role); }
        // Sorting
        $sortable=['id','name','email','created_at'];
        $sort=$request->query('sort'); $dir=$request->query('dir')==='asc'?'asc':($request->query('dir')==='desc'?'desc':null);
        if($sort && in_array($sort,$sortable) && $dir){ $q->orderBy($sort,$dir); } else { $q->latest(); }
        $items = $q->paginate(15)->withQueryString();
        $counts = [
            'total' => User::count(),
            'admins' => User::where('role','admin')->count(),
        ];

        if ($request->wantsJson()) {
            return response()->json([
                'html' => view('admin.users._table', compact('items'))->render(),
                'pagination' => (string) $items->links(),
                'sort'=>$sort,
                'dir'=>$dir,
                'counts' => $counts,
            ]);
        }
        if ($request->query('fragment') === 'table') {
            return view('admin.users._table', compact('items'));
        }
        return view('admin.users.index', compact('items','counts'));
    }

    public function edit(User $user)
    {
        return view('admin.users.edit', compact('user'));
    }

    public function update(Request $request, User $user)
    {
        $data = $request->validate([
            'name' => 'required',
            'role' => 'nullable|string|max:50',
        ]);
        $user->update($data);
        if($request->wantsJson()) return response()->json(['ok'=>true]);
        return redirect()->route('admin.users.index')->with('ok', 'User updated');
    }

    public function destroy(User $user)
    {
        // Prevent self-delete to avoid locking yourself out
    if (Auth::id() === $user->id) {
            return back()->with('ok', 'Cannot delete your own account');
        }
        $user->delete();
        return back()->with('ok', 'Deleted');
    }

    public function profile(User $user)
    {
        $roles = config('roles.slugs');
        $cities = config('cities');
        return view('admin.users.profile', compact('user','roles','cities'));
    }

    public function profileUpdate(Request $request, User $user)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'nickname' => 'nullable|string|max:100',
            'city' => 'nullable|string|in:'.implode(',', config('cities')),
            'role' => 'required|in:'.implode(',', array_keys(config('roles.slugs'))),
            'avatar' => 'nullable|image|max:2048'
        ]);
        // Permission: only admin/director can change role
        if(isset($data['role']) && !in_array(FacadeAuth::user()->role,['admin','director'])){
            unset($data['role']);
        }
        if($request->hasFile('avatar')){
            $path = $request->file('avatar')->store('avatars','public');
            $data['avatar_path'] = '/storage/'.$path;
        }
        $user->update($data);
        return redirect()->route('admin.users.profile',$user)->with('ok','Профилът е обновен');
    }

    public function bulkDelete(Request $request){
        $ids = $request->input('ids',[]);
        if(!is_array($ids) || empty($ids)) return response()->json(['ok'=>false,'error'=>'No IDs'],422);
        // prevent self deletion if included
        $ids = array_filter($ids, fn($id)=> (int)$id !== Auth::id());
        User::whereIn('id',$ids)->delete();
        return response()->json(['ok'=>true]);
    }

    public function export(Request $request){
        $query = User::query();
        if($ids = $request->query('ids')){
            $arr = array_filter(explode(',', $ids));
            if($arr) $query->whereIn('id',$arr);
        }
        if($search = $request->query('search')){
            $query->where(function($q) use ($search){ $q->where('name','like',"%$search%") ->orWhere('email','like',"%$search%{}"); });
        }
        if($role = $request->query('role')) $query->where('role',$role);
        $rows = $query->orderBy('id')->get(['id','name','email','role','email_verified_at','created_at']);
        $headers = ['ID','Name','Email','Role','Verified','Created'];
        $callback = function() use ($rows,$headers){ $out = fopen('php://output','w'); fputcsv($out,$headers); foreach($rows as $r){ fputcsv($out,[ $r->id,$r->name,$r->email,$r->role,$r->email_verified_at?$r->email_verified_at->toDateString():'', $r->created_at?->toDateTimeString() ]); } fclose($out); };
        return response()->streamDownload($callback,'users.csv',['Content-Type'=>'text/csv']);
    }
}
