import '../services/api_client.dart';

class AuthService {
  final ApiClient client;
  AuthService(this.client);

  Future<Map<String,dynamic>> login(String email, String password) async {
    final data = await client.post('/auth/login', {'email':email,'password':password});
    return data;
  }

  // Adjusted register signature to first/last/city + password + confirmation
  Future<String> register({required String firstName, required String lastName, String? city, required String email, required String password, required String passwordConfirmation}) async {
    final body = <String,dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
    // City now optional (captured later in onboarding). Only send if non-null/non-empty for backward compatibility.
    if(city!=null && city.trim().isNotEmpty){ body['city']=city.trim(); }
    final resp = await client.post('/auth/register', body);
    return resp['email'] as String; // backend returns email + message
  }

  Future<Map<String,dynamic>> verifyRegistration(String email,String code) async {
    return await client.post('/auth/register/verify', {'email':email,'code':code});
  }

  Future<void> resendRegistrationCode(String email) async {
    await client.post('/auth/register/resend-code', {'email':email});
  }

  Future<void> forgot(String email) async {
    await client.post('/auth/forgot-password', {'email':email});
  }

  Future<void> resetPassword({required String email, required String token, required String password, required String passwordConfirmation}) async {
    await client.post('/auth/reset-password', {
      'email': email,
      'token': token,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  Future<Map<String,dynamic>> me() async {
    return await client.get('/auth/me');
  }

  Future<Map<String,dynamic>> updateProfile({String? name,String? email,String? password,String? city,String? bio,String? phone}) async {
    final body = <String,dynamic>{};
    if(name!=null) body['name']=name;
    if(email!=null) body['email']=email;
    if(password!=null && password.isNotEmpty) body['password']=password;
    if(city!=null) body['city']=city;
    if(bio!=null) body['bio']=bio;
    if(phone!=null) body['phone']=phone;
    return await client.put('/auth/profile', body);
  }

  /// Persist user interests separately (dedicated onboarding endpoint)
  Future<void> updateInterests(List<String> interests) async {
    await client.post('/auth/interests', {'interests': interests});
  }

  Future<Map<String,dynamic>> updateAvatar(String filePath) async {
  return await client.multipart('/auth/profile', {}, {'avatar':filePath}, method: 'PUT');
  }

  Future<Map<String,dynamic>> emailStatus() async => await client.get('/auth/email-status');
  Future<void> resendVerification() async => await client.post('/auth/resend-verification', {});

  Future<Map<String,dynamic>> socialLogin(String provider,{String? idToken,String? email,String? name}) async {
    final body = <String,dynamic>{'provider':provider};
    if(idToken!=null) body['id_token']=idToken; if(email!=null) body['email']=email; if(name!=null) body['name']=name;
    return await client.post('/auth/social', body);
  }
}
