import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/message.dart';
import 'messaging_repository.dart';

class SupabaseMessagingRepository implements MessagingRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<Conversation>> getConversations(
    String userId, {
    required bool isClientMode,
  }) async {
    try {
      final query = _supabase.from('conversations').select(
            'id, client_id, freelancer_id, mission_id, mission_title, '
            'last_message, last_message_at',
          );
      final rows = await (isClientMode
              ? query.eq('client_id', userId)
              : query.eq('freelancer_id', userId))
          .order('last_message_at', ascending: false)
          .limit(50);

      if ((rows as List).isEmpty) return [];

      final otherUserIds = rows
          .map<String>((row) => row['client_id'] == userId
              ? row['freelancer_id'] as String
              : row['client_id'] as String)
          .toSet()
          .toList(growable: false);

      // Batch-fetch profiles — 1 query, includes is_verified
      final profileRows = await _supabase
          .from('profiles')
          .select('id, first_name, last_name, avatar_url, is_verified')
          .inFilter('id', otherUserIds);

      final profileMap = <String, Map<String, dynamic>>{
        for (final p
            in (profileRows as List).whereType<Map<String, dynamic>>())
          p['id'] as String: p,
      };

      // Batch-count unread — 1 query, limited to avoid unbounded scans.
      // TODO: replace with an RPC `get_unread_counts(conversation_ids uuid[])`
      // returning TABLE(conversation_id uuid, count bigint) once volume justifies it.
      final conversationIds =
          rows.map<String>((r) => r['id'] as String).toList(growable: false);

      final unreadRows = await _supabase
          .from('messages')
          .select('conversation_id')
          .inFilter('conversation_id', conversationIds)
          .neq('status', 'read')
          .neq('sender_id', userId)
          .limit(500);

      final unreadMap = <String, int>{};
      for (final msg in (unreadRows as List)) {
        final convId = msg['conversation_id'] as String;
        unreadMap[convId] = (unreadMap[convId] ?? 0) + 1;
      }

      return rows.map<Conversation>((row) {
        final isClient = row['client_id'] == userId;
        final otherUserId = isClient
            ? row['freelancer_id'] as String
            : row['client_id'] as String;
        final profile = profileMap[otherUserId];
        final otherName = profile != null
            ? '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'
                .trim()
            : '';

        return Conversation(
          id: row['id'] as String,
          clientId: row['client_id'] as String,
          freelancerId: row['freelancer_id'] as String,
          missionId: row['mission_id'] as String?,
          missionTitle: row['mission_title'] as String?,
          lastMessage: row['last_message'] as String?,
          lastMessageAt: row['last_message_at'] != null
              ? DateTime.parse(row['last_message_at'] as String)
              : null,
          unreadCount: unreadMap[row['id'] as String] ?? 0,
          otherUserId: otherUserId,
          otherUserName: otherName.isEmpty ? 'Utilisateur' : otherName,
          otherUserAvatar: profile?['avatar_url'] as String?,
          isOtherVerified: profile?['is_verified'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      debugPrint('getConversations error: $e');
      throw const AppException(
        'Impossible de charger les conversations',
        kind: AppErrorKind.network,
      );
    }
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id ?? '';
      final rows = await _supabase
          .from('messages')
          .select('id, conversation_id, sender_id, content, status, created_at')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true)
          .limit(100);
      return (rows as List)
          .map((r) => ChatMessage.fromJson(r as Map<String, dynamic>, currentUserId))
          .toList();
    } catch (e) {
      debugPrint('getMessages error: $e');
      throw const AppException(
        'Impossible de charger les messages',
        kind: AppErrorKind.network,
      );
    }
  }

  @override
  Future<List<ChatMessage>> getMessagesBefore(
    String conversationId,
    String beforeMessageId, {
    int limit = 50,
  }) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id ?? '';
      final anchorRow = await _supabase
          .from('messages')
          .select('created_at')
          .eq('id', beforeMessageId)
          .single();
      final rows = await _supabase
          .from('messages')
          .select('id, conversation_id, sender_id, content, status, created_at')
          .eq('conversation_id', conversationId)
          .lt('created_at', anchorRow['created_at'] as String)
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List)
          .reversed
          .map((r) => ChatMessage.fromJson(r as Map<String, dynamic>, currentUserId))
          .toList();
    } catch (e) {
      debugPrint('getMessagesBefore error: $e');
      throw const AppException(
        'Impossible de charger les messages précédents',
        kind: AppErrorKind.network,
      );
    }
  }

  @override
  Future<ChatMessage?> sendMessage(
    String conversationId,
    String senderId,
    String content,
  ) async {
    try {
      final row = await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': senderId,
        'content': content,
        'status': 'sent',
      }).select().single();
      return ChatMessage.fromJson(row, senderId);
    } catch (e) {
      debugPrint('sendMessage error: $e');
      throw const AppException(
        'Erreur lors de l\'envoi',
        kind: AppErrorKind.network,
      );
    }
  }

  @override
  Future<String?> getOrCreateConversation({
    required String clientId,
    required String freelancerId,
    String? missionId,
  }) async {
    try {
      var query = _supabase
          .from('conversations')
          .select('id')
          .eq('client_id', clientId)
          .eq('freelancer_id', freelancerId);

      if (missionId != null) query = query.eq('mission_id', missionId);

      final existing = await query.maybeSingle();
      if (existing != null) return existing['id'] as String;

      final data = <String, dynamic>{
        'client_id': clientId,
        'freelancer_id': freelancerId,
      };
      if (missionId != null) data['mission_id'] = missionId;

      final row = await _supabase
          .from('conversations')
          .insert(data)
          .select('id')
          .single();
      return row['id'] as String;
    } catch (e) {
      debugPrint('getOrCreateConversation error: $e');
      return null;
    }
  }

  @override
  Future<String?> findConversation({
    required String clientId,
    required String freelancerId,
    String? missionId,
  }) async {
    try {
      var query = _supabase
          .from('conversations')
          .select('id')
          .eq('client_id', clientId)
          .eq('freelancer_id', freelancerId);

      if (missionId != null) query = query.eq('mission_id', missionId);

      final existing = await query.maybeSingle();
      return existing?['id'] as String?;
    } catch (e) {
      debugPrint('findConversation error: $e');
      return null;
    }
  }

  @override
  Future<void> markAsRead(String conversationId, String userId) async {
    try {
      await _supabase
          .from('messages')
          .update({'status': 'read'})
          .eq('conversation_id', conversationId)
          .neq('sender_id', userId);
    } catch (e) {
      debugPrint('markAsRead error: $e');
    }
  }

  @override
  Future<void> updateConversationLastMessage(
    String conversationId,
    String lastMessage,
  ) async {
    try {
      await _supabase.from('conversations').update({
        'last_message': lastMessage,
        'last_message_at': DateTime.now().toIso8601String(),
      }).eq('id', conversationId);
    } catch (e) {
      debugPrint('updateConversationLastMessage error: $e');
    }
  }

  @override
  Future<void> linkMissionToConversation(
    String conversationId,
    String missionId,
    String missionTitle,
  ) async {
    try {
      await _supabase
          .from('conversations')
          .update({'mission_id': missionId, 'mission_title': missionTitle})
          .eq('id', conversationId);
    } catch (e) {
      debugPrint('linkMissionToConversation error: $e');
    }
  }
}
