import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ghana_funding_rail.dart';
import '../models/payment_method.dart';

class PaymentMethodService {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Future<List<PaymentMethod>> listMethods() async {
    final user = currentUser;
    if (user == null) return [];

    final data = await _supabase
        .from('payment_methods')
        .select()
        .eq('user_id', user.id)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);

    return (data as List)
        .map((row) => PaymentMethod.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<PaymentMethod> saveMomo({
    required String msisdn,
    required String rail,
    bool makeDefault = true,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No authenticated user.');
    }

    final normalized = GhanaFundingRail.normalizeMsisdn(msisdn);
    if (normalized == null) {
      throw Exception('Enter a valid Ghana Mobile Money number.');
    }

    final network = GhanaFundingRail.fromMsisdn(normalized);
    if (network == null) {
      throw Exception('That number is not a Ghana Mobile Money line.');
    }

    if (rail != network.id) {
      throw Exception('That number belongs to ${network.name}.');
    }

    if (makeDefault) {
      await _supabase
          .from('payment_methods')
          .update({'is_default': false})
          .eq('user_id', user.id)
          .eq('is_default', true);
    }

    final existing = await _supabase
        .from('payment_methods')
        .select()
        .eq('user_id', user.id)
        .eq('msisdn', normalized)
        .maybeSingle();

    if (existing != null) {
      final data = await _supabase
          .from('payment_methods')
          .update({
            'rail': network.id,
            'is_default': makeDefault || existing['is_default'] == true,
          })
          .eq('id', existing['id'])
          .select()
          .single();
      return PaymentMethod.fromJson(data);
    }

    final hasAny = await _supabase
        .from('payment_methods')
        .select('id')
        .eq('user_id', user.id)
        .limit(1)
        .maybeSingle();

    final data = await _supabase
        .from('payment_methods')
        .insert({
          'user_id': user.id,
          'kind': 'momo',
          'rail': network.id,
          'msisdn': normalized,
          'is_default': makeDefault || hasAny == null,
        })
        .select()
        .single();

    return PaymentMethod.fromJson(data);
  }

  Future<void> makeDefault(String id) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No authenticated user.');
    }

    await _supabase
        .from('payment_methods')
        .update({'is_default': false})
        .eq('user_id', user.id)
        .eq('is_default', true);

    await _supabase
        .from('payment_methods')
        .update({'is_default': true})
        .eq('id', id)
        .eq('user_id', user.id);
  }

  Future<void> deleteMethod(String id) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No authenticated user.');
    }

    await _supabase
        .from('payment_methods')
        .delete()
        .eq('id', id)
        .eq('user_id', user.id);
  }
}
