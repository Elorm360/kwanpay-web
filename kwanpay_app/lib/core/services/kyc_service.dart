import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The user's KYC tier, their limits and how much of them is used.
/// All amounts are Ghana cedis; the database converts other currencies.
class KycStatus {
  final int tier;
  final String tierName;
  final double perTransactionLimit;
  final double dailyLimit;
  final double monthlyLimit;
  final double usedToday;
  final double usedThisMonth;

  /// What ID verification unlocks; null once the ID is verified.
  final String? nextTierName;
  final double? nextDailyLimit;
  final double? nextMonthlyLimit;

  /// 'pending', 'approved', 'rejected', or null when nothing was sent.
  final String? submissionStatus;
  final String? rejectionReason;

  const KycStatus({
    required this.tier,
    required this.tierName,
    required this.perTransactionLimit,
    required this.dailyLimit,
    required this.monthlyLimit,
    required this.usedToday,
    required this.usedThisMonth,
    this.nextTierName,
    this.nextDailyLimit,
    this.nextMonthlyLimit,
    this.submissionStatus,
    this.rejectionReason,
  });

  bool get idVerified => tier >= 2;
  bool get underReview => submissionStatus == 'pending';
  bool get rejected => submissionStatus == 'rejected' && !idVerified;

  static double _num(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  static double? _numOrNull(Object? value) =>
      value == null ? null : _num(value);

  factory KycStatus.fromJson(Map<String, dynamic> json) => KycStatus(
    tier: (json['tier'] as num?)?.toInt() ?? 0,
    tierName: json['tier_name']?.toString() ?? 'Basic',
    perTransactionLimit: _num(json['per_transaction_limit']),
    dailyLimit: _num(json['daily_limit']),
    monthlyLimit: _num(json['monthly_limit']),
    usedToday: _num(json['used_today']),
    usedThisMonth: _num(json['used_this_month']),
    nextTierName: json['next_tier_name']?.toString(),
    nextDailyLimit: _numOrNull(json['next_daily_limit']),
    nextMonthlyLimit: _numOrNull(json['next_monthly_limit']),
    submissionStatus: json['submission_status']?.toString(),
    rejectionReason: json['rejection_reason']?.toString(),
  );
}

enum KycDocumentType {
  ghanaCard('ghana_card', 'Ghana Card'),
  passport('passport', 'Passport');

  const KycDocumentType(this.code, this.label);
  final String code;
  final String label;
}

class KycService {
  final _supabase = Supabase.instance.client;
  static const _bucket = 'kyc-documents';

  Future<KycStatus> getStatus() async {
    final data = await _supabase.rpc('get_my_kyc_status');
    return KycStatus.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// Uploads one photo to the user's private folder and returns its path.
  Future<String> uploadPhoto(Uint8List bytes, String label) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Sign in again to continue.');
    final path =
        '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$label.jpg';
    await _supabase.storage
        .from(_bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return path;
  }

  Future<void> submit({
    required KycDocumentType type,
    required String documentNumber,
    required String frontPath,
    String? backPath,
    required String selfiePath,
  }) async {
    await _supabase.rpc(
      'submit_kyc_documents',
      params: {
        'p_document_type': type.code,
        'p_document_number': documentNumber.trim(),
        'p_front_path': frontPath,
        'p_back_path': backPath,
        'p_selfie_path': selfiePath,
      },
    );
  }
}

final kycServiceProvider = Provider<KycService>((ref) => KycService());

final kycStatusProvider = FutureProvider.autoDispose<KycStatus>(
  (ref) => ref.watch(kycServiceProvider).getStatus(),
);