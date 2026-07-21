import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class StripeCard {
  final String id;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;
  final bool isDefault;

  const StripeCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.isDefault,
  });

  factory StripeCard.fromJson(Map<String, dynamic> j) => StripeCard(
    id: j['id'] as String,
    brand: j['brand'] as String? ?? 'card',
    last4: j['last4'] as String? ?? '0000',
    expMonth: j['expMonth'] as int? ?? 0,
    expYear: j['expYear'] as int? ?? 0,
    isDefault: j['isDefault'] as bool? ?? false,
  );

  String get brandLabel {
    final b = brand.toLowerCase();
    return switch (b) {
      'visa' => 'Visa',
      'mastercard' => 'Mastercard',
      'amex' => 'American Express',
      _ =>
        brand.isEmpty ? 'Carte' : brand[0].toUpperCase() + brand.substring(1),
    };
  }

  String get expiry =>
      '${expMonth.toString().padLeft(2, '0')}/${(expYear % 100).toString().padLeft(2, '0')}';
}

class PaymentService {
  static final _supabase = Supabase.instance.client;

  static String get _fnBase {
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    return '$url/functions/v1';
  }

  static String get _token => _supabase.auth.currentSession?.accessToken ?? '';

  static Map<String, String> get _headers => {
    'Authorization': 'Bearer $_token',
    'Content-Type': 'application/json',
  };

  static Future<void> _initStripeIfNeeded(Map<String, dynamic> data) async {
    final pubKey = data['publishableKey'] as String? ?? '';
    if (pubKey.isNotEmpty && !pubKey.contains('YOUR_STRIPE')) {
      Stripe.publishableKey = pubKey;
    }
    if (Stripe.publishableKey.isNotEmpty) {
      await Stripe.instance.applySettings();
    }
  }

  // ── Card management ───────────────────────────────────────────────────────

  static Future<void> addCardWithPaymentSheet() async {
    final res = await http.post(
      Uri.parse('$_fnBase/stripe-customer-setup'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      final err = (jsonDecode(res.body) as Map<String, dynamic>)['error'];
      throw Exception(err ?? 'Erreur Stripe');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    await _initStripeIfNeeded(data);

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        setupIntentClientSecret: data['setupIntentClientSecret'] as String,
        customerId: data['customerId'] as String,
        customerEphemeralKeySecret: data['ephemeralKey'] as String,
        merchantDisplayName: 'BYRSA',
        style: ThemeMode.dark,
      ),
    );
    await Stripe.instance.presentPaymentSheet();
  }

  static Future<List<StripeCard>> listCards() async {
    try {
      final res = await http.get(
        Uri.parse('$_fnBase/stripe-payment-methods'),
        headers: _headers,
      );
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return (data['paymentMethods'] as List)
          .map((pm) => StripeCard.fromJson(pm as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('listCards error: $e');
      return [];
    }
  }

  static Future<void> deleteCard(String paymentMethodId) async {
    await http.delete(
      Uri.parse('$_fnBase/stripe-payment-methods'),
      headers: _headers,
      body: jsonEncode({'paymentMethodId': paymentMethodId}),
    );
  }

  static Future<void> setDefaultCard(String paymentMethodId) async {
    await http.post(
      Uri.parse('$_fnBase/stripe-payment-methods'),
      headers: _headers,
      body: jsonEncode({'defaultPaymentMethodId': paymentMethodId}),
    );
  }

  // ── Mission payment ───────────────────────────────────────────────────────

  static Future<void> payMissionWithSheet(String missionId) async {
    final res = await http.post(
      Uri.parse('$_fnBase/stripe-pay-mission'),
      headers: _headers,
      body: jsonEncode({'missionId': missionId}),
    );
    if (res.statusCode != 200) {
      String? err;
      try {
        err =
            (jsonDecode(res.body) as Map<String, dynamic>)['error'] as String?;
      } catch (_) {}
      debugPrint('stripe-pay-mission error ${res.statusCode}: ${res.body}');
      throw Exception(err ?? 'Erreur paiement (${res.statusCode})');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    await _initStripeIfNeeded(data);

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: data['clientSecret'] as String,
        merchantDisplayName: 'BYRSA',
        style: ThemeMode.dark,
      ),
    );
    await Stripe.instance.presentPaymentSheet();
  }

  // ── IBAN (freelancer) ─────────────────────────────────────────────────────

  static Future<Map<String, String?>> loadIban() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};
    final data = await _supabase
        .from('profiles')
        .select('bank_iban, bank_bic, bank_holder')
        .eq('id', userId)
        .single();
    return {
      'iban': data['bank_iban'] as String?,
      'bic': data['bank_bic'] as String?,
      'holder': data['bank_holder'] as String?,
    };
  }

  static Future<void> saveIban({
    required String iban,
    String? bic,
    String? holder,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase
        .from('profiles')
        .update({
          'bank_iban': iban.trim().toUpperCase(),
          if (bic != null && bic.trim().isNotEmpty)
            'bank_bic': bic.trim().toUpperCase(),
          if (holder != null && holder.trim().isNotEmpty)
            'bank_holder': holder.trim(),
        })
        .eq('id', userId);
  }

  static Future<void> deleteIban() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase
        .from('profiles')
        .update({'bank_iban': null, 'bank_bic': null, 'bank_holder': null})
        .eq('id', userId);
  }

  // ── Transactions ──────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final data = await _supabase
          .from('transactions')
          .select('*, mission:missions!mission_id(title)')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(100);
      return List<Map<String, dynamic>>.from(data as List);
    } catch (e) {
      debugPrint('fetchTransactions error: $e');
      return [];
    }
  }
}
