import 'package:fourhorses/core/errors/app_exception.dart';
import 'package:fourhorses/features/messaging/data/models/message.dart';
import 'package:fourhorses/features/messaging/data/repositories/messaging_repository.dart';

/// In-memory fake for tests — no Supabase required.
class FakeMessagingRepository implements MessagingRepository {
  final List<ChatMessage> _messages;
  bool shouldThrow;
  String? sendError; // non-null → sendMessage throws AppException with this msg

  int sendCallCount = 0;
  int markAsReadCallCount = 0;

  FakeMessagingRepository({
    List<ChatMessage>? messages,
    this.shouldThrow = false,
    this.sendError,
  }) : _messages = messages ?? [];

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    if (shouldThrow) {
      throw const AppException('network error', kind: AppErrorKind.network);
    }
    return List<ChatMessage>.from(_messages);
  }

  @override
  Future<List<ChatMessage>> getMessagesBefore(
    String conversationId,
    String beforeMessageId, {
    int limit = 50,
  }) async {
    if (shouldThrow) {
      throw const AppException('network error', kind: AppErrorKind.network);
    }
    return const [];
  }

  @override
  Future<ChatMessage?> sendMessage(
    String conversationId,
    String senderId,
    String content,
  ) async {
    sendCallCount++;
    if (sendError != null) {
      throw AppException(sendError!, kind: AppErrorKind.network);
    }
    final msg = ChatMessage(
      id: 'msg_$sendCallCount',
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
    );
    _messages.add(msg);
    return msg;
  }

  @override
  Future<void> markAsRead(String conversationId, String userId) async {
    markAsReadCallCount++;
  }

  @override
  Future<void> updateConversationLastMessage(
    String conversationId,
    String lastMessage,
  ) async {}

  @override
  Future<void> linkMissionToConversation(
    String conversationId,
    String missionId,
    String missionTitle,
  ) async {}

  @override
  Future<List<Conversation>> getConversations(
    String userId, {
    required bool isClientMode,
  }) async => const [];

  @override
  Future<String?> getOrCreateConversation({
    required String clientId,
    required String freelancerId,
    String? missionId,
  }) async => 'conv_test';

  @override
  Future<String?> findConversation({
    required String clientId,
    required String freelancerId,
    String? missionId,
  }) async => null;
}
