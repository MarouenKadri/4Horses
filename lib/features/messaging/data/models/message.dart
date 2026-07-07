import 'message_content.dart';

export 'message_content.dart';

enum MessageStatus { sending, sent, delivered, read, failed }

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final MessageStatus status;
  final bool isSystemMessage;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.status = MessageStatus.sent,
    this.isSystemMessage = false,
  });

  factory ChatMessage.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final statusStr = json['status'] as String? ?? 'sent';
    final status = switch (statusStr) {
      'sending' => MessageStatus.sending,
      'delivered' => MessageStatus.delivered,
      'read' => MessageStatus.read,
      'failed' => MessageStatus.failed,
      _ => MessageStatus.sent,
    };
    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: status,
      isSystemMessage: (json['type'] as String?) == 'system',
    );
  }

  bool isMe(String currentUserId) => senderId == currentUserId;

  MessageContent get parsedContent {
    if (isSystemMessage) return SystemContent(content);
    final loc = LocationContent.tryParse(content);
    if (loc != null) return loc;
    return TextContent(content);
  }

  /// Preview text shown in conversation list tiles.
  String get displayPreview => switch (parsedContent) {
    TextContent(:final text) => text,
    LocationContent() => '📍 Position partagée',
    SystemContent(:final text) => text,
  };

  ChatMessage copyWith({MessageStatus? status}) => ChatMessage(
    id: id,
    conversationId: conversationId,
    senderId: senderId,
    content: content,
    createdAt: createdAt,
    status: status ?? this.status,
    isSystemMessage: isSystemMessage,
  );
}

class Conversation {
  final String id;
  final String clientId;
  final String freelancerId;
  final String? missionId;
  final String? missionTitle;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final bool isOtherVerified;

  const Conversation({
    required this.id,
    required this.clientId,
    required this.freelancerId,
    this.missionId,
    this.missionTitle,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.isOtherVerified = false,
  });

  Conversation copyWith({
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    String? missionId,
    String? missionTitle,
  }) => Conversation(
    id: id,
    clientId: clientId,
    freelancerId: freelancerId,
    missionId: missionId ?? this.missionId,
    missionTitle: missionTitle ?? this.missionTitle,
    lastMessage: lastMessage ?? this.lastMessage,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    unreadCount: unreadCount ?? this.unreadCount,
    otherUserId: otherUserId,
    otherUserName: otherUserName,
    otherUserAvatar: otherUserAvatar,
    isOtherVerified: isOtherVerified,
  );
}
