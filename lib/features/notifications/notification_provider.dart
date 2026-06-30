import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/models/app_notification.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/supabase_notification_repository.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📦 Inkern - NotificationProvider
/// Gestion d'état + Supabase Realtime pour les notifications en temps réel.
/// ═══════════════════════════════════════════════════════════════════════════

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  List<AppNotification> _notifications = [];
  bool isLoading = false;
  RealtimeChannel? _channel;
  StreamSubscription<AuthState>? _authSub;

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  NotificationProvider({NotificationRepository? repository})
      : _repository = repository ?? SupabaseNotificationRepository() {
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        _channel?.unsubscribe();
        _channel = null;
        _init();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _channel?.unsubscribe();
        _channel = null;
        _notifications = [];
        notifyListeners();
      }
    });
    if (Supabase.instance.client.auth.currentUser != null) _init();
  }

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // ─── Init ─────────────────────────────────────────────────────────────────

  Future<void> _init() async {
    if (_userId == null) return;
    await _load();
    _subscribeRealtime();
  }

  Future<void> _load() async {
    final userId = _userId;
    if (userId == null) return;
    isLoading = true;
    notifyListeners();
    _notifications = await _repository.fetchAll(userId);
    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _load();

  // ─── Marquer lu ───────────────────────────────────────────────────────────

  void markRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].isRead) return;
    final list = List<AppNotification>.from(_notifications);
    list[index] = list[index].copyWith(isRead: true);
    _notifications = list;
    notifyListeners();
    _repository.markRead(id).catchError((e) => debugPrint('markRead error: $e'));
  }

  void markAllRead() {
    final userId = _userId;
    if (_notifications.every((n) => n.isRead)) return;
    _notifications = _notifications
        .map((n) => n.isRead ? n : n.copyWith(isRead: true))
        .toList();
    notifyListeners();
    if (userId != null) {
      _repository
          .markAllRead(userId)
          .catchError((e) => debugPrint('markAllRead error: $e'));
    }
  }

  void deleteNotification(String id) {
    final previous = _notifications;
    _notifications = previous.where((n) => n.id != id).toList();
    notifyListeners();
    _repository.delete(id).catchError((e) {
      debugPrint('deleteNotification error: $e');
      _notifications = previous;
      notifyListeners();
    });
  }

  // ─── Ajouter (appelé par realtime) ────────────────────────────────────────

  void addNotification(AppNotification notif) {
    _notifications = [notif, ..._notifications.where((n) => n.id != notif.id)];
    notifyListeners();
  }

  // ─── Envoyer à un autre utilisateur (insert Supabase → Realtime) ──────────

  Future<void> sendNotification(
    String targetUserId, {
    required NotifType type,
    required String title,
    required String body,
    String? avatarUrl,
  }) async {
    await _repository.sendNotification(
      targetUserId,
      type: type.name,
      title: title,
      body: body,
      avatarUrl: avatarUrl,
    );
  }

  // ─── Realtime ─────────────────────────────────────────────────────────────

  void _subscribeRealtime() {
    final userId = _userId;
    if (userId == null) return;

    _channel = Supabase.instance.client
        .channel('notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            try {
              final notif = AppNotification.fromJson(payload.newRecord);
              addNotification(notif);
            } catch (e) {
              debugPrint('realtime notification error: $e');
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _channel?.unsubscribe();
    super.dispose();
  }
}
