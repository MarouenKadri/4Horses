import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/models/message.dart';
import '../../data/repositories/messaging_repository.dart';
import '../../data/repositories/moderated_messaging_repository.dart';
import '../../data/repositories/supabase_messaging_repository.dart';

typedef ConversationSyncCallback =
    void Function(
      String conversationId, {
      String? lastMessage,
      DateTime? lastMessageAt,
      int? unreadCount,
      bool preservePosition,
    });

/// Provider scoped to a single conversation.
/// Created per-ChatPage; lifecycle managed by the page.
class ChatProvider extends ChangeNotifier {
  final MessagingRepository _repo;
  final SupabaseClient? _supabase;
  final ConversationSyncCallback? onConversationSync;

  // Visible for testing: overrides _supabase.auth.currentUser?.id
  final String? _testCurrentUserId;

  List<ChatMessage> _messages = [];
  String? _conversationId;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool _hasMore = true;

  /// True when the last state update was a prepend (loadMore).
  /// Used by ChatPage to preserve scroll position.
  bool lastUpdateWasPrepend = false;

  /// Non-null when an unrecoverable error occurred (e.g. network failure).
  String? error;

  RealtimeChannel? _channel;
  int _loadToken = 0;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get hasMore => _hasMore;
  String? get currentUserId =>
      _testCurrentUserId ?? _supabase?.auth.currentUser?.id;

  ChatProvider({
    MessagingRepository? repository,
    SupabaseClient? supabaseClient,
    this.onConversationSync,
    @visibleForTesting String? testCurrentUserId,
  }) : _repo =
           repository ??
           ModeratedMessagingRepository(SupabaseMessagingRepository()),
       _supabase = (testCurrentUserId != null || repository != null)
           ? null
           : (supabaseClient ?? Supabase.instance.client),
       _testCurrentUserId = testCurrentUserId;

  /// Lifts or restores content moderation based on mission assignment status.
  /// When [value] is true, phone numbers and addresses are allowed in chat.
  void setMissionConfirmed(bool value) {
    final repo = _repo;
    if (repo is ModeratedMessagingRepository) {
      repo.isMissionConfirmed = value;
    }
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  Future<void> open(String conversationId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _conversationId == conversationId) {
      if (_channel == null) _subscribe(conversationId);
      return;
    }

    _conversationId = conversationId;
    _hasMore = true;
    _unsubscribe();

    final token = ++_loadToken;
    _messages = [];
    error = null;
    isLoading = true;
    lastUpdateWasPrepend = false;
    notifyListeners();

    try {
      final fetched = await _repo.getMessages(conversationId);
      if (token != _loadToken || _conversationId != conversationId) return;

      _messages = List<ChatMessage>.from(fetched);
      if (fetched.length < 100) _hasMore = false;
    } on AppException catch (e) {
      if (token != _loadToken) return;
      error = e.message;
    }

    isLoading = false;
    notifyListeners();

    if (error == null) {
      unawaited(_markAsRead(conversationId));
      _subscribe(conversationId);
    }
  }

  void close() {
    _unsubscribe();
    _loadToken++;
    _conversationId = null;
    _messages = [];
    isLoading = false;
    isLoadingMore = false;
    error = null;
    lastUpdateWasPrepend = false;
    notifyListeners();
  }

  // ─── Pagination ───────────────────────────────────────────────────────────

  Future<void> loadMore() async {
    final convId = _conversationId;
    if (isLoadingMore || !_hasMore || _messages.isEmpty || convId == null) {
      return;
    }

    isLoadingMore = true;
    notifyListeners();

    try {
      final older = await _repo.getMessagesBefore(convId, _messages.first.id);
      if (older.isEmpty) {
        _hasMore = false;
      } else {
        _messages = [...older, ..._messages];
        lastUpdateWasPrepend = true;
        if (older.length < 50) _hasMore = false;
      }
    } on AppException {
      // Silent: keep existing messages, user can scroll up again
    }

    isLoadingMore = false;
    notifyListeners();
  }

  // ─── Send ─────────────────────────────────────────────────────────────────

  Future<String?> sendMessage(String content) async {
    final userId = currentUserId;
    final convId = _conversationId;
    if (userId == null || convId == null) return 'Non connecté';

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = ChatMessage(
      id: tempId,
      conversationId: convId,
      senderId: userId,
      content: content,
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
    );
    lastUpdateWasPrepend = false;
    _append(optimistic);

    try {
      final sent = await _repo.sendMessage(convId, userId, content);
      if (sent == null) {
        _replace(tempId, optimistic.copyWith(status: MessageStatus.failed));
        return 'Erreur lors de l\'envoi';
      }
      lastUpdateWasPrepend = false;
      _replace(tempId, sent);
      final preview = optimistic.displayPreview;
      _notifyConversationSync(
        convId,
        lastMessage: preview,
        lastMessageAt: sent.createdAt,
        unreadCount: 0,
      );
      unawaited(_repo.updateConversationLastMessage(convId, preview));
      return null;
    } on ModerationException catch (e) {
      _removeById(tempId);
      return e.reason;
    } on AppException catch (e) {
      _replace(tempId, optimistic.copyWith(status: MessageStatus.failed));
      return e.message;
    } catch (_) {
      _replace(tempId, optimistic.copyWith(status: MessageStatus.failed));
      return 'Erreur lors de l\'envoi';
    }
  }

  // ─── Retry ────────────────────────────────────────────────────────────────

  Future<void> retryMessage(ChatMessage failed) async {
    final convId = _conversationId;
    final userId = currentUserId;
    if (convId == null || userId == null) return;

    lastUpdateWasPrepend = false;
    _replace(failed.id, failed.copyWith(status: MessageStatus.sending));

    try {
      final sent = await _repo.sendMessage(convId, userId, failed.content);
      if (sent == null) {
        _replace(failed.id, failed.copyWith(status: MessageStatus.failed));
        return;
      }
      _replace(failed.id, sent);
      final preview = failed.displayPreview;
      _notifyConversationSync(
        convId,
        lastMessage: preview,
        lastMessageAt: sent.createdAt,
        unreadCount: 0,
      );
      unawaited(_repo.updateConversationLastMessage(convId, preview));
    } on ModerationException {
      _replace(failed.id, failed.copyWith(status: MessageStatus.failed));
    } catch (_) {
      _replace(failed.id, failed.copyWith(status: MessageStatus.failed));
    }
  }

  // ─── Real-time ────────────────────────────────────────────────────────────

  void _subscribe(String conversationId) {
    _unsubscribe();
    final client = _supabase;
    if (client == null) return; // no realtime in test mode
    _channel = client
        .channel('chat_$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            final userId = currentUserId ?? '';
            final newMsg = ChatMessage.fromJson(payload.newRecord, userId);

            if (_hasMessage(newMsg.id)) return;

            lastUpdateWasPrepend = false;
            if (newMsg.senderId == userId) {
              final tempId = _messages
                  .where(
                    (m) =>
                        m.id.startsWith('temp_') &&
                        m.content == newMsg.content &&
                        m.status == MessageStatus.sending,
                  )
                  .map((m) => m.id)
                  .firstOrNull;
              if (tempId != null) {
                _replace(tempId, newMsg, notify: false);
              } else {
                _append(newMsg, notify: false);
              }
            } else {
              _append(newMsg);
              unawaited(_markAsRead(conversationId));
            }

            _notifyConversationSync(
              conversationId,
              lastMessage: newMsg.displayPreview,
              lastMessageAt: newMsg.createdAt,
            );
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            final userId = currentUserId ?? '';
            final updated = ChatMessage.fromJson(payload.newRecord, userId);
            if (!_hasMessage(updated.id)) return;
            _merge(updated);
          },
        )
        .subscribe();
  }

  // ─── State helpers ────────────────────────────────────────────────────────

  bool _hasMessage(String id) => _messages.any((m) => m.id == id);

  void _append(ChatMessage msg, {bool notify = true}) {
    _messages = [..._messages, msg];
    if (notify) notifyListeners();
  }

  void _removeById(String id, {bool notify = true}) {
    _messages = _messages.where((m) => m.id != id).toList(growable: false);
    if (notify) notifyListeners();
  }

  void _replace(String prevId, ChatMessage msg, {bool notify = true}) {
    _messages = _messages
        .map((m) => m.id == prevId ? msg : m)
        .toList(growable: false);
    if (notify) notifyListeners();
  }

  void _merge(ChatMessage msg, {bool notify = true}) {
    _messages = _messages
        .map((m) => m.id == msg.id ? msg : m)
        .toList(growable: false);
    if (notify) notifyListeners();
  }

  Future<void> _markAsRead(String conversationId) async {
    final userId = currentUserId;
    if (userId == null) return;

    _messages = _messages
        .map((m) {
          if (m.senderId != userId &&
              m.status != MessageStatus.read &&
              !m.id.startsWith('temp_')) {
            return m.copyWith(status: MessageStatus.read);
          }
          return m;
        })
        .toList(growable: false);

    _notifyConversationSync(
      conversationId,
      unreadCount: 0,
      preservePosition: true,
    );
    await _repo.markAsRead(conversationId, userId);
  }

  void _notifyConversationSync(
    String conversationId, {
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool preservePosition = false,
  }) {
    onConversationSync?.call(
      conversationId,
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
      unreadCount: unreadCount,
      preservePosition: preservePosition,
    );
  }

  void _unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }
}
