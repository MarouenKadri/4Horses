import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_notification.dart';
import 'notification_repository.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📦 Inkern - SupabaseNotificationRepository
///
/// Table SQL requise :
///   notifications : id, user_id, type, title, body, avatar_url,
///                   is_read (bool default false), created_at
/// ═══════════════════════════════════════════════════════════════════════════

class SupabaseNotificationRepository implements NotificationRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<AppNotification>> fetchAll(String userId) async {
    try {
      final data = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
      return data.map<AppNotification>(AppNotification.fromJson).toList();
    } catch (e) {
      debugPrint('fetchNotifications error: $e');
      return [];
    }
  }

  @override
  Future<void> markRead(String notifId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notifId);
    } catch (e) {
      debugPrint('markRead error: $e');
    }
  }

  @override
  Future<void> markAllRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('markAllRead error: $e');
    }
  }

  @override
  Future<void> delete(String notifId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notifId);
    } catch (e) {
      debugPrint('deleteNotification error: $e');
    }
  }

  @override
  Future<void> sendNotification(
    String targetUserId, {
    required String type,
    required String title,
    required String body,
    String? avatarUrl,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': targetUserId,
        'type': type,
        'title': title,
        'body': body,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('sendNotification error: $e');
    }
  }
}
