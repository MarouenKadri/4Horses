import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/models/message.dart';
import 'data/repositories/messaging_repository.dart';
import 'data/repositories/supabase_messaging_repository.dart';

/// Global provider — manages the conversation list and unread badge count.
/// Per-chat state lives in [ChatProvider], scoped to each ChatPage.
class MessagingProvider extends ChangeNotifier {
  final MessagingRepository _repo;
  final SupabaseClient _supabase;

  List<Conversation> _conversations = [];
  bool isLoadingConversations = false;
  String? _conversationError;
  int _conversationLoadToken = 0;
  bool _isClientMode = true;
  StreamSubscription<AuthState>? _authSub;

  List<Conversation> get conversations => List.unmodifiable(_conversations);
  String? get conversationError => _conversationError;
  int get totalUnread =>
      _conversations.fold(0, (sum, c) => sum + c.unreadCount);
  String? get currentUserId => _supabase.auth.currentUser?.id;

  MessagingProvider({
    MessagingRepository? repository,
    SupabaseClient? supabaseClient,
  }) : _repo = repository ?? SupabaseMessagingRepository(),
       _supabase = supabaseClient ?? Supabase.instance.client {
    _authSub = _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) _resetState();
    });
  }

  // ─── Conversations ────────────────────────────────────────────────────────

  Future<void> loadConversations({
    bool forceRefresh = false,
    bool? isClientMode,
  }) async {
    final userId = currentUserId;
    if (userId == null) return;
    if (isLoadingConversations && !forceRefresh) return;

    if (isClientMode != null) _isClientMode = isClientMode;

    final token = ++_conversationLoadToken;
    _conversationError = null;
    _setLoading(true);

    try {
      final result = await _repo.getConversations(
        userId,
        isClientMode: _isClientMode,
      );
      if (token != _conversationLoadToken) return;

      _conversations = result;
    } catch (e) {
      if (token != _conversationLoadToken) return;
      debugPrint('loadConversations error: $e');
      _conversationError = 'Impossible de charger vos conversations.';
    } finally {
      if (token == _conversationLoadToken) _setLoading(false);
    }
  }

  Future<String?> getOrCreateConversation({
    required String otherUserId,
    required bool iAmClient,
    String? missionId,
  }) async {
    final userId = currentUserId;
    if (userId == null || userId == otherUserId) return null;

    return _repo.getOrCreateConversation(
      clientId: iAmClient ? userId : otherUserId,
      freelancerId: iAmClient ? otherUserId : userId,
      missionId: missionId,
    );
  }

  Future<String?> findConversation({
    required String otherUserId,
    required bool iAmClient,
    String? missionId,
  }) async {
    final userId = currentUserId;
    if (userId == null) return null;
    final clientId = iAmClient ? userId : otherUserId;
    final freelancerId = iAmClient ? otherUserId : userId;
    return _repo.findConversation(
      clientId: clientId,
      freelancerId: freelancerId,
      missionId: missionId,
    );
  }

  // ─── Conversation mutations ───────────────────────────────────────────────

  /// Links a conversation to a newly created mission and hides the reserve button.
  void linkConversationToMission(
    String conversationId,
    String missionId,
    String missionTitle,
  ) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      final next = List<Conversation>.from(_conversations);
      next[index] = _conversations[index].copyWith(
        missionId: missionId,
        missionTitle: missionTitle,
      );
      _conversations = next;
      notifyListeners();
    }
    _repo.linkMissionToConversation(conversationId, missionId, missionTitle);
  }

  // ─── Called by ChatProvider to keep list in sync ──────────────────────────

  void updateConversationPreview(
    String conversationId, {
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool preservePosition = false,
  }) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) return;

    final current = _conversations[index];
    final updated = current.copyWith(
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
      unreadCount: unreadCount,
    );

    final changed =
        updated.lastMessage != current.lastMessage ||
        updated.lastMessageAt != current.lastMessageAt ||
        updated.unreadCount != current.unreadCount;
    if (!changed && (preservePosition || index == 0)) return;

    final next = List<Conversation>.from(_conversations);
    if (preservePosition) {
      next[index] = updated;
    } else {
      next.removeAt(index);
      next.insert(0, updated);
    }
    _conversations = next;
    notifyListeners();
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    if (isLoadingConversations == value) return;
    isLoadingConversations = value;
    notifyListeners();
  }

  void _resetState() {
    _conversationLoadToken++;
    _conversations = [];
    _conversationError = null;
    isLoadingConversations = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
