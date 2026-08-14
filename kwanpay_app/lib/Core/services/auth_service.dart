import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
      },
    );
  }

  Future<AuthResponse> verifySignupOtp({
    required String email,
    required String token,
  }) async {
    return await _supabase.auth.verifyOTP(
      type: OtpType.signup,
      email: email,
      token: token,
    );
  }

  Future<void> resendSignupOtp({
    required String email,
  }) async {
    await _supabase.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  bool isEmailVerified(User? user) {
    return user?.emailConfirmedAt != null;
  }

  bool isNewSignup(AuthResponse response) {
    return response.user != null &&
        (response.user!.identities?.isNotEmpty ?? false);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

