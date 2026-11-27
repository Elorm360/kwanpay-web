import 'package:supabase_flutter/supabase_flutter.dart';

/// Turns an error from a money action into a sentence for the user.
///
/// The wallet functions in the database raise their own plain-language
/// messages (limits, balance, bad amounts) with the default `P0001` code, so
/// those are shown as they are. Anything else is a fault the user cannot act
/// on, and gets a calm generic line instead of a stack of technical text.
String moneyErrorMessage(Object error) {
  if (error is PostgrestException) {
    if (error.code == 'P0001' && error.message.trim().isNotEmpty) {
      return error.message.trim();
    }
    return "We couldn't complete that. Check your connection and try again.";
  }
  if (error is AuthException) {
    return 'Your session has ended. Sign in again to continue.';
  }
  final text = error.toString().replaceFirst('Exception: ', '').trim();
  return text.isEmpty ? "We couldn't complete that. Try again." : text;
}

/// True when [error] is a KYC limit refusal, so a screen can offer
/// the way to raise the limit next to the message.
bool isLimitError(Object error) =>
    error is PostgrestException && (error.hint ?? '').startsWith('kyc_limit_');
