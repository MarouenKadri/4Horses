import '../models/message.dart';
import '../services/message_moderation_service.dart';
import 'messaging_repository.dart';

class ModerationException implements Exception {
  final String reason;
  const ModerationException(this.reason);
  @override
  String toString() => reason;
}

/// Decorator that enforces content moderation before any message reaches the DB.
/// Set [isMissionConfirmed] to true once the mission is assigned — this lifts
/// the restriction on phone numbers and addresses so participants can coordinate.
class ModeratedMessagingRepository implements MessagingRepository {
  final MessagingRepository _delegate;
  final MessageModerationService _moderation;

  bool isMissionConfirmed = false;

  ModeratedMessagingRepository(
    this._delegate, [
    MessageModerationService? moderation,
  ]) : _moderation = moderation ?? MessageModerationService.instance;

  @override
  Future<ChatMessage?> sendMessage(
    String conversationId,
    String senderId,
    String content,
  ) {
    if (!isMissionConfirmed) {
      final result = _moderation.check(content);
      if (result.blocked) throw ModerationException(result.reason!);
    }
    return _delegate.sendMessage(conversationId, senderId, content);
  }

  @override
  Future<List<Conversation>> getConversations(
    String userId, {
    required bool isClientMode,
  }) => _delegate.getConversations(userId, isClientMode: isClientMode);

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) =>
      _delegate.getMessages(conversationId);

  @override
  Future<List<ChatMessage>> getMessagesBefore(
    String conversationId,
    String beforeMessageId, {
    int limit = 50,
  }) => _delegate.getMessagesBefore(
    conversationId,
    beforeMessageId,
    limit: limit,
  );

  @override
  Future<String?> getOrCreateConversation({
    required String clientId,
    required String freelancerId,
    String? missionId,
  }) => _delegate.getOrCreateConversation(
    clientId: clientId,
    freelancerId: freelancerId,
    missionId: missionId,
  );

  @override
  Future<String?> findConversation({
    required String clientId,
    required String freelancerId,
    String? missionId,
  }) => _delegate.findConversation(
    clientId: clientId,
    freelancerId: freelancerId,
    missionId: missionId,
  );

  @override
  Future<void> markAsRead(String conversationId, String userId) =>
      _delegate.markAsRead(conversationId, userId);

  @override
  Future<void> updateConversationLastMessage(
    String conversationId,
    String lastMessage,
  ) => _delegate.updateConversationLastMessage(conversationId, lastMessage);

  @override
  Future<void> linkMissionToConversation(
    String conversationId,
    String missionId,
    String missionTitle,
  ) => _delegate.linkMissionToConversation(
    conversationId,
    missionId,
    missionTitle,
  );
}
