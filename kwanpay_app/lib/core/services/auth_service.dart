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

  /// Plain-language message for an auth error, keyed on Supabase's error
  /// codes rather than its English text.
  static String friendlyError(AuthException e) {
    final message = e.message.toLowerCase();
    switch (e.code) {
      case 'over_email_send_rate_limit':
        // Project-wide cap on emails (very low on Supabase's built-in
        // sender), not something the user caused.
        return "We've sent too many emails in the last hour. Please try again later.";
      case 'over_request_rate_limit':
        return 'Too many attempts. Please wait a minute, then try again.';
      case 'invalid_credentials':
        return 'Incorrect email or password.';
      case 'email_not_confirmed':
        return 'Confirm your email first. Enter the code we sent you.';
      case 'otp_expired':
        return 'That code is wrong or has expired. Check the latest email, or resend.';
      case 'same_password':
        return 'Choose a password you have not used before.';
      case 'weak_password':
        return 'That password is too weak. Use at least $minPasswordLength characters with a letter and a number.';
      case 'email_address_invalid':
        return 'That email address cannot receive mail. Check it and try again.';
    }
    // Per-address resend cooldown: "For security purposes, you can only
    // request this after 42 seconds."
    final wait = RegExp(r'after (\d+) seconds?').firstMatch(message);
    if (wait != null) {
      return 'Please wait ${wait.group(1)} seconds before requesting another code.';
    }
    if (e.statusCode == '429') {
      return 'Too many attempts. Please try again shortly.';
    }
    return e.message;
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

