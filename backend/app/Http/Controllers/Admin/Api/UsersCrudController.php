<?php
namespace App\Http\Controllers\Admin\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UsersCrudController extends Controller
{
    public function index(Request $r){
        $q = User::query();
        if($s=$r->query('search')){
            $q->where(function($qq) use ($s){
                $qq->where('name','like',"%$s%")
                   ->orWhere('email','like',"%$s%" );
            });
        }
        if($role=$r->query('role')) $q->where('role',$role);
        $q->orderByDesc('id');
        return $q->paginate((int)$r->query('per_page',30));
    }
    public function show(User $user){ return ['data'=>$user]; }
    public function store(Request $r){
        $data = $r->validate([
            'name'=>'required|string|max:255',
            'email'=>'required|email|unique:users,email',
            'password'=>'required|string|min:6',
            'role'=>'required|string'
        ]);
        $data['password']=Hash::make($data['password']);
        $user = User::create($data);
        return response()->json(['data'=>$user],201);
    }
    public function update(Request $r, User $user){
        $data = $r->validate([
            'name'=>'sometimes|required|string|max:255',
            'email'=>'sometimes|required|email|unique:users,email,'.$user->id,
            'password'=>'nullable|string|min:6',
            'role'=>'sometimes|required|string'
        ]);
        if(!empty($data['password'])) $data['password']=Hash::make($data['password']); else unset($data['password']);
        $user->update($data);
        return ['data'=>$user];
    }
    public function destroy(User $user){ $user->delete(); return ['ok'=>true]; }
    public function restore($id){ $u=User::withTrashed()->findOrFail($id); $u->restore(); return ['ok'=>true]; }
}