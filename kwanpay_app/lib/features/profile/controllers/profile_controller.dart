import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/profile_model.dart';
import '../../../core/services/profile_service.dart';

/// Provider that fetches the current user's profile from Supabase.
final profileProvider = FutureProvider<ProfileModel?>((ref) async {
  final profileService = ProfileService();
  final profile = await profileService.getProfile();

  return profile;
});

