import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../screens/auth_screens.dart';
import '../main.dart';

class AuthProvider extends ChangeNotifier {
  Future<void> refreshUser() async {
    try {
      _user = await _auth.me();
      notifyListeners();
    } catch (_) {}
  }
  Future<void> restoreSession(String token) async {
    _token = token;
    api.token = token;
    try {
      _user = await _auth.me();
    } catch (_) {
      _token = null;
      api.token = null;
      await _secure.delete(key: 'token');
    }
    _initialized = true;
    notifyListeners();
  }
  final ApiClient api;
  late final AuthService _auth;
  String? _token;
  Map<String,dynamic>? _user;
  bool _loading = false;
  bool _initialized = false; // becomes true after restore completes
  bool biometricPreferred = true;
  String? _dismissedVersion; // persisted
  String? _pendingEmail; // new staged registration email
  // Secure storage instance (encrypted on device). Using const for optimal reuse.
  static const _secure = FlutterSecureStorage();
  bool get isEmailVerified => (_user?['email_verified_at'])!=null || (_user?['verified']==true);
  String? get avatarPath => _user?['avatar_path'];
  String? get pendingEmail => _pendingEmail;

  AuthProvider(this.api){
    _auth = AuthService(api);
    _restore(); // Always restore session on app start
  }

  bool get isLoading => _loading;
  bool get isAuthenticated => _token!=null;
  Map<String,dynamic>? get user => _user;
  bool get initialized => _initialized;
  bool canCreateEvent(){
    final role = _user?['role'];
    return role=='admin' || role=='director' || role=='teacher';
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    // Try secure storage first
    try {
      _token = await _secure.read(key: 'token');
      if (_token == null) {
        // Migration path from legacy SharedPreferences token
        final legacy = prefs.getString('token');
        if (legacy != null) {
          _token = legacy;
          await _secure.write(key: 'token', value: legacy);
          await prefs.remove('token');
        }
      }
    } catch (e) {
      // Fallback: if secure storage unavailable (rare), use prefs
      _token = prefs.getString('token');
    }

    api.token = _token;
    biometricPreferred = prefs.getBool('biometric_pref') ?? true;
    _dismissedVersion = prefs.getString('dismissed_version');
    if (_token != null) {
      try {
        _user = await _auth.me();
      } catch (_) {
        // Token invalid -> purge
        _token = null;
        api.token = null;
        await _secure.delete(key: 'token');
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<bool> login(String email,String password) async {
    _loading=true; notifyListeners();
    try {
      const maxAttempts = 3;
      int attempt = 0;
      ApiException? lastTimeout;
      while(attempt < maxAttempts){
        attempt++;
        try {
          final data = await _auth.login(email,password);
          _token = data['token'];
          api.token = _token;
          _user = data['user'];
          final prefs = await SharedPreferences.getInstance();
          await _secure.write(key:'token', value:_token!);
          await prefs.remove('token');
          return true;
        } on ApiException catch(e){
          final isTimeout = e.statusCode==408;
            if(!isTimeout){ rethrow; }
          lastTimeout = e;
          // Before retry, quick health probe to differentiate unreachable vs slow endpoint
          final ok = await api.health();
          if(!ok && attempt==1){
            // immediate failure if server health is down and not just slow
            throw ApiException(statusCode: 503, path: '/auth/login', message: 'Сървърът е недостъпен (health check). Опитайте по-късно.');
          }
          if(attempt>=maxAttempts){
            throw ApiException(statusCode: 408, path: '/auth/login', message: 'Времето изтече (опит $attempt/$maxAttempts). Провери мрежата или сървъра.');
          }
          // Exponential backoff: 400ms, 800ms
          final delay = Duration(milliseconds: 400 * attempt);
          await Future.delayed(delay);
        }
      }
      if(lastTimeout!=null) {
        throw lastTimeout; // propagate last timeout after attempts exhausted
      }
      return false;
    } finally { _loading=false; notifyListeners(); }
  }

  Future<void> startRegistration({required String firstName, required String lastName, required String email, required String password, required String passwordConfirmation}) async {
    // City removed from initial registration; will be collected post-verification in onboarding.
    _pendingEmail = await _auth.register(firstName:firstName, lastName:lastName, email:email, password:password, passwordConfirmation:passwordConfirmation);
    notifyListeners();
  }

  Future<bool> submitVerificationCode(String code) async {
    if(_pendingEmail==null) return false;
    try {
      final data = await _auth.verifyRegistration(_pendingEmail!, code);
      _token = data['token'];
      api.token = _token;
      _user = data['user'];
      _pendingEmail = null;
      final prefs = await SharedPreferences.getInstance();
      await _secure.write(key:'token', value:_token!);
      await prefs.remove('token');
      notifyListeners();
      return true;
    } catch(_) {
      rethrow;
    }
  }

  Future<void> resendRegistrationCode() async { if(_pendingEmail!=null){ await _auth.resendRegistrationCode(_pendingEmail!); } }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await _secure.delete(key:'token');
    _token=null; _user=null; api.token=null; _pendingEmail=null; notifyListeners();
    // Navigate to login screen
    try {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        Navigator.of(ctx).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (_) {}
  }

  Future<bool> updateProfile({String? name,String? email,String? password,String? city,String? bio,String? phone}) async {
    if(!isAuthenticated) return false;
    final updated = await _auth.updateProfile(name: name, email: email, password: password, city: city, bio: bio, phone: phone);
    // Refresh from /auth/me to ensure server-side mutations / casts
    try { _user = await _auth.me(); } catch(_) { _user = updated; }
    notifyListeners(); return true;
  }

  Future<void> updateAvatar(String path) async { if(!isAuthenticated) return; final updated = await _auth.updateAvatar(path); _user = updated; notifyListeners(); }
  Future<bool> pollEmailVerified() async { if(!isAuthenticated) return false; final status = await _auth.emailStatus(); if(status['verified']==true){ _user?['email_verified_at']=DateTime.now().toIso8601String(); notifyListeners(); return true;} return false; }
  Future<void> resendVerification() async { if(isAuthenticated) await _auth.resendVerification(); }

  Future<void> setInterests(List<String> interests) async {
    if(!isAuthenticated) return; await _auth.updateInterests(interests); try { _user = await _auth.me(); } catch(_) {} notifyListeners();
  }
  bool versionDismissed(String version) => _dismissedVersion == version;
  Future<void> dismissVersion(String version) async { final prefs = await SharedPreferences.getInstance(); _dismissedVersion = version; await prefs.setString('dismissed_version', version); notifyListeners(); }

  Future<void> setBiometricPreferred(bool value) async { biometricPreferred = value; notifyListeners(); final prefs = await SharedPreferences.getInstance(); await prefs.setBool('biometric_pref', value); }

  Future<bool> loginWithSocial({required String provider, String? idToken, String? email, String? name}) async {
    _loading=true; notifyListeners();
    try {
      final body = <String,dynamic>{'provider':provider};
      if(idToken!=null) body['id_token']=idToken; if(email!=null) body['email']=email; if(name!=null) body['name']=name;
      final data = await api.post('/auth/social', body);
      _token = data['token']; api.token=_token; _user=data['user'];
      final prefs = await SharedPreferences.getInstance(); await _secure.write(key:'token', value:_token!); await prefs.remove('token'); return true;
    } finally { _loading=false; notifyListeners(); }
  }
}
