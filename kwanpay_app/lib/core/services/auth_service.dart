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

  /// Emails a one-time code for resetting the password. Supabase sends it
  /// only if the account exists, but never says so, so callers must show the
  /// same message either way.
  Future<void> sendPasswordResetCode({required String email}) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  /// Exchanges the emailed reset code for a short-lived session, then sets the
  /// new password. Signs out afterwards so the user signs in fresh.
  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _supabase.auth.verifyOTP(
      type: OtpType.recovery,
      email: email,
      token: code,
    );
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    await _supabase.auth.signOut();
  }

  /// Minimum rules shown to the user before they type, and enforced here.
  static const minPasswordLength = 8;

  static String? passwordProblem(String password) {
    if (password.length < minPasswordLength) {
      return 'Use at least $minPasswordLength characters.';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(password) || !RegExp(r'\d').hasMatch(password)) {
      return 'Use at least one letter and one number.';
    }
    return null;
  }

  static bool looksLikeEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[A-Za-z]{2,}$').hasMatch(email);

  static const _domainTypos = {
    'gmaol.com': 'gmail.com',
    'gmial.com': 'gmail.com',
    'gmai.com': 'gmail.com',
    'gmail.co': 'gmail.com',
    'gamil.com': 'gmail.com',
    'gnail.com': 'gmail.com',
    'gmail.con': 'gmail.com',
    'yaho.com': 'yahoo.com',
    'yahoo.co': 'yahoo.com',
    'yahooo.com': 'yahoo.com',
    'hotmial.com': 'hotmail.com',
    'hotmail.co': 'hotmail.com',
    'outlok.com': 'outlook.com',
    'outlook.co': 'outlook.com',
    'iclod.com': 'icloud.com',
  };

  /// Returns a corrected address for common domain typos (e.g. gmaol.com),
  /// or null if the domain looks fine. A typo'd address can never receive the
  /// verification code, so the sign-up would be stranded.
  static String? suggestEmailFix(String email) {
    final at = email.lastIndexOf('@');
    if (at < 1) return null;
    final fix = _domainTypos[email.substring(at + 1).toLowerCase()];
    return fix == null ? null : '${email.substring(0, at)}@$fix';
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

