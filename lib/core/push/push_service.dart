import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// PushService — notifications push via Firebase Cloud Messaging
///
/// Initialisation défensive : tant que la config Firebase n'est pas en place
/// (`flutterfire configure` → google-services.json / GoogleService-Info.plist),
/// le service se désactive silencieusement et l'app fonctionne normalement.
///
/// Chaîne complète :
///   login → registerToken() → profiles.fcm_token
///   insert dans `notifications` → trigger/webhook → Edge Function send-push
///   → FCM → appareil
/// ═══════════════════════════════════════════════════════════════════════════

class PushService {
  PushService._();

  static bool _available = false;

  /// À appeler une fois au démarrage, après Supabase.initialize.
  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      _available = true;
    } catch (e) {
      // Config Firebase absente — push désactivé, app inchangée.
      debugPrint('PushService: Firebase non configuré ($e)');
      _available = false;
    }
    if (!_available) return;

    FirebaseMessaging.instance.onTokenRefresh.listen(_saveToken);
  }

  /// À appeler quand un utilisateur est connecté.
  static Future<void> registerToken() async {
    if (!_available) return;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _saveToken(token);
    } catch (e) {
      debugPrint('PushService.registerToken: $e');
    }
  }

  /// À appeler avant la déconnexion — l'appareil ne doit plus recevoir
  /// les notifications de ce compte.
  static Future<void> clearToken() async {
    if (!_available) return;
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await Supabase.instance.client
          .from('profiles')
          .update({'fcm_token': null})
          .eq('id', userId);
    } catch (e) {
      debugPrint('PushService.clearToken: $e');
    }
  }

  static Future<void> _saveToken(String token) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await Supabase.instance.client
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', userId);
    } catch (e) {
      debugPrint('PushService._saveToken: $e');
    }
  }
}
