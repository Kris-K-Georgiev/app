<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\PendingRegistration;
use App\Models\PasswordResetCode;
use App\Mail\VerificationCodeMail;
use App\Mail\PasswordResetCodeMail;
use Illuminate\Support\Facades\Mail;
use Illuminate\Auth\Events\Registered;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Validation\ValidationException;
use Illuminate\Foundation\Auth\EmailVerificationRequest;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Facades\Gate;
use App\Services\CodeService;
// (Removed Carbon import to satisfy static analyzer issues; using DateTimeImmutable instead)

class AuthController extends Controller
{
    /* ================= Registration (first/last name + city) ================= */
    public function register(Request $request)
    {
        $data = $request->validate([
            'first_name' => 'required|string|min:2|max:100',
            'last_name'  => 'required|string|min:2|max:100',
            'city'       => 'required|string|min:2|max:100',
            'email'      => 'required|email|unique:users,email',
            'password'   => 'required|string|min:6|confirmed',
        ]);

        // Optional city whitelist validation (config/cities.php returning array['list'=>[]])
        $citiesConfig = config('cities.list');
        if(is_array($citiesConfig) && !empty($citiesConfig)){
            if(!in_array($data['city'], $citiesConfig, true)){
                return response()->json(['message'=>'Невалиден град'],422);
            }
        }

        if (PendingRegistration::where('email',$data['email'])->exists()) {
            // refresh existing pending (allow user to restart)
            PendingRegistration::where('email',$data['email'])->delete();
        }

    $code = CodeService::generate();
        $pending = PendingRegistration::create([
            'first_name'    => $data['first_name'],
            'last_name'     => $data['last_name'],
            'city'          => $data['city'],
            'email'         => $data['email'],
            'password_hash' => Hash::make($data['password']),
            'code'          => $code,
            'attempts'      => 0,
            'expires_at'    => CodeService::expiresAt(),
            'last_sent_at'  => new \DateTimeImmutable(),
        ]);

        try {
            Mail::to($pending->email)->send(new VerificationCodeMail($code));
        } catch (\Throwable $e) {
            $pending->delete();
            return response()->json(['message'=>'Грешка при изпращане на имейл'],500);
        }
    return response()->json(['message'=>'Код за потвърждение изпратен','email'=>$pending->email,'expires_in'=> CodeService::ttlSeconds()]);
    }

    public function resendCode(Request $request)
    {
        $data = $request->validate(['email'=>'required|email']);
        $pending = PendingRegistration::where('email',$data['email'])->first();
        if(!$pending){
            return response()->json(['message'=>'Няма чакаща регистрация'],404);
        }
        if($pending->last_sent_at instanceof \DateTimeInterface){
            $diff = (new \DateTimeImmutable())->getTimestamp() - $pending->last_sent_at->getTimestamp();
            if($diff < 60){
                $remain = 60 - $diff;
                return response()->json(['message'=>'Изчакай още '.$remain.' сек. преди нов повторен опит'],429);
            }
        }
        if($pending->expires_at instanceof \DateTimeInterface && $pending->expires_at < new \DateTimeImmutable()){
            $pending->expires_at = CodeService::expiresAt();
        }
        $pending->code = CodeService::generate();
        $pending->attempts = 0;
        $pending->last_sent_at = now();
        $pending->save();
        Mail::to($pending->email)->send(new VerificationCodeMail($pending->code));
    return response()->json(['message'=>'Кодът е изпратен отново','expires_in'=> CodeService::ttlSeconds()]);
    }

    public function verifyRegistration(Request $request)
    {
        $data = $request->validate([
            'email' => 'required|email',
            'code'  => 'required|digits:6'
        ]);
        $pending = PendingRegistration::where('email',$data['email'])->first();
        if(!$pending){
            return response()->json(['message'=>'Няма чакаща регистрация'],404);
        }
        if($pending->expires_at instanceof \DateTimeInterface && $pending->expires_at < new \DateTimeImmutable()){
            $pending->delete();
            return response()->json(['message'=>'Кодът е изтекъл'],422);
        }
        if($pending->code !== $data['code']){
            $pending->increment('attempts');
            if($pending->attempts >=5){
                $pending->delete();
                return response()->json(['message'=>'Твърде много опити'],429);
            }
            return response()->json(['message'=>'Невалиден код','remaining'=>5-$pending->attempts],422);
        }
        $fullName = trim($pending->first_name.' '.$pending->last_name);
        // Validate city again just before user creation (in case config changed)
        $citiesConfig = config('cities.list');
        if(is_array($citiesConfig) && !empty($citiesConfig) && !in_array($pending->city, $citiesConfig, true)){
            return response()->json(['message'=>'Невалиден град'],422);
        }
        $user = User::create([
            'name' => $fullName,
            'email'=> $pending->email,
            'password'=>$pending->password_hash,
            'role'=>'user',
            'city'=>$pending->city,
            'email_verified_at'=> now(),
        ]);
        $pending->delete();
        $token = $user->createToken('auth')->plainTextToken;
    return response()->json(['message'=>'Регистрацията е завършена','token'=>$token,'user'=>$user]);
    }

    /* ================= Auth (login / social) ================= */
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);
        if(!Auth::attempt($credentials)){
            throw ValidationException::withMessages(['email'=>['Невалидни данни за вход']]);
        }
        /** @var User $user */
        $user = $request->user();
        $token = $user->createToken('auth')->plainTextToken;
        return response()->json(['token'=>$token,'user'=>$user]);
    }

    public function socialLogin(Request $request)
    {
        $data = $request->validate([
            'provider' => 'required|string|in:google,apple',
            'id_token' => 'nullable|string',
            'email'    => 'nullable|email',
            'name'     => 'nullable|string'
        ]);
        $email=null; $name=null; $verified=false;
        if(app()->environment('local') && $data['email']){
            $email=$data['email'];
            $name=$data['name'] ?? 'Social User';
            $verified=true;
        } else if($data['provider']==='google'){
            if(empty($data['id_token'])) return response()->json(['message'=>'Липсва id_token'],422);
            try {
                $client = new \GuzzleHttp\Client(['timeout'=>5]);
                $resp = $client->get('https://oauth2.googleapis.com/tokeninfo',[ 'query'=>['id_token'=>$data['id_token']] ]);
                $payload = json_decode($resp->getBody()->getContents(), true);
                $email = $payload['email'] ?? null;
                $name = $payload['name'] ?? ($payload['given_name'] ?? 'Google User');
                $verified = ($payload['email_verified'] ?? 'false') === 'true';
            } catch(\Throwable $e){
                return response()->json(['message'=>'Грешка при проверка на Google токена'],400);
            }
        } else if($data['provider']==='apple'){
            return response()->json(['message'=>'Apple входът не е имплементиран'],501);
        }
        if(!$email){
            return response()->json(['message'=>'Неуспешен социален вход'],400);
        }
        $user = User::where('email',$email)->first();
        if(!$user){
            $user = User::create([
                'name'=>$name ?? 'User',
                'email'=>$email,
                'password'=>Hash::make(\Illuminate\Support\Str::random(32)),
                'email_verified_at'=> now(),
                'role'=>'user'
            ]);
        }
        $token = $user->createToken('auth')->plainTextToken;
        return response()->json(['token'=>$token,'user'=>$user]);
    }

    /* ================= User & Session ================= */
    public function me(Request $request){ return $request->user(); }
    public function logout(Request $request){ $request->user()->currentAccessToken()->delete(); return response()->json(['message'=>'Излязохте успешно']); }

    public function updateProfile(Request $request)
    {
        /** @var User $user */
        $user = $request->user();
        $data = $request->validate([
            'name' => 'sometimes|string|min:2|max:255',
            'email'=> 'sometimes|email|unique:users,email,'.$user->id,
            'password'=> 'sometimes|string|min:6|confirmed',
            'city' => 'sometimes|nullable|string|max:120',
            'bio'  => 'sometimes|nullable|string|max:2000',
            'phone'=> 'sometimes|nullable|string|max:40'
        ]);
        if(isset($data['password'])){
            $data['password'] = Hash::make($data['password']);
        }
        $user->fill($data)->save();
        return response()->json($user);
    }

    /* ================= Password Reset ================= */
    public function forgotPassword(Request $request)
    {
        $request->validate(['email'=>'required|email']);
        $email = $request->input('email');
        $user = User::where('email',$email)->first();
        if($user){
            // почисти стари кодове
            PasswordResetCode::where('email',$email)->delete();
            $code = CodeService::generate();
            PasswordResetCode::create([
                'email'=>$email,
                'code'=>$code,
                'expires_at'=> CodeService::expiresAt()
            ]);
            try { Mail::to($email)->send(new PasswordResetCodeMail($code)); } catch(\Throwable $e) { /* ignore */ }
        }
    return response()->json(['message'=>'Ако имейлът съществува, изпратихме код.','expires_in'=> CodeService::ttlSeconds()]);
    }

    public function resetPassword(Request $request)
    {
        $data = $request->validate([
            'email'=>'required|email',
            'code'=>'required|digits:6',
            'password'=>'required|min:6|confirmed'
        ]);
        $row = PasswordResetCode::where('email',$data['email'])->where('code',$data['code'])->first();
        if(!$row){
            return response()->json(['message'=>'Невалиден код'],422);
        }
    if($row->expires_at instanceof \DateTimeInterface && $row->expires_at < new \DateTimeImmutable()){
            $row->delete();
            return response()->json(['message'=>'Кодът е изтекъл'],422);
        }
        $user = User::where('email',$data['email'])->first();
        if(!$user){
            // сигурност: тихо изтриване
            $row->delete();
            return response()->json(['message'=>'Паролата е обновена.']);
        }
        $user->forceFill(['password'=>Hash::make($data['password'])])->save();
        $row->delete();
        return response()->json(['message'=>'Паролата е обновена.']);
    }

    /* ================= Email Status ================= */
    public function emailStatus(Request $request)
    {
        /** @var User $user */
        $user = $request->user();
        return response()->json(['verified'=>$user->hasVerifiedEmail(),'email'=>$user->email]);
    }
}
