import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_model.dart';
import 'wallet_service.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  /// Fetches the current user's profile from the 'profiles' table.
  Future<ProfileModel?> getProfile() async {
    final user = currentUser;

    if (user == null) return null;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) return null;

      return ProfileModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  /// Creates or updates the current user's profile using upsert.
  /// Upsert is used to avoid race conditions where the profile
  /// might be created between a check and an insert.
  Future<void> createProfile({
    required String fullName,
    required String email,
    String phone = '',
    String country = '',
    String avatarUrl = '',
    String walletAddress = '',
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    try {
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'country': country,
        'avatar_url': avatarUrl,
        'wallet_address': walletAddress,
      });

      await WalletService().createWallet();
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }

  /// Ensures a profile exists for the current user.
  /// Uses upsert internally so it's safe to call multiple times.
  Future<void> createProfileIfNotExists() async {
    final user = currentUser;

    if (user == null) return;

    final profile = await getProfile();

    if (profile != null) return;

    final metadata = user.userMetadata ?? {};

    await createProfile(
      fullName: metadata['full_name'] ?? '',
      email: user.email ?? '',
    );
  }

  /// Updates the current user's profile fields in the 'profiles' table.
  Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String country,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    await _supabase
        .from('profiles')
        .update({
          'full_name': fullName,
          'phone': phone,
          'country': country,
        })
        .eq('id', user.id);
  }
}
