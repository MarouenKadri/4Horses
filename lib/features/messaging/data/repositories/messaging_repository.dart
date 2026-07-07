import '../models/message.dart';

abstract class MessagingRepository {
  Future<List<Conversation>> getConversations(
    String userId, {
    required bool isClientMode,
  });
  Future<List<ChatMessage>> getMessages(String conversationId);
  Future<List<ChatMessage>> getMessagesBefore(
    String conversationId,
    String beforeMessageId, {
    int limit = 50,
  });
  Future<ChatMessage?> sendMessage(
    String conversationId,
    String senderId,
    String content,
  );
  Future<String?> getOrCreateConversation({
    required String clientId,
    required String freelancerId,
    String? missionId,
  });
  Future<String?> findConversation({
    required String clientId,
    required String freelancerId,
    String? missionId,
  });
  Future<void> markAsRead(String conversationId, String userId);
  Future<void> updateConversationLastMessage(
    String conversationId,
    String lastMessage,
  );
  Future<void> linkMissionToConversation(
    String conversationId,
    String missionId,
    String missionTitle,
  );
}
