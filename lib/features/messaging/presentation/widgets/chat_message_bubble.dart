import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/design/app_design_system.dart';
import '../../data/models/message.dart';
import '../providers/chat_provider.dart';
import 'location_message_bubble.dart';
import 'message_time_status.dart';

const _kInk      = AppColors.ink;
const _kWhite    = AppColors.surface;
const _kGrayMid  = AppColors.textTertiary;
const _kBorder   = AppColors.divider;

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showAvatar;
  final String contactAvatar;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.contactAvatar,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isSystemMessage) {
      return _SystemBubble(text: message.content);
    }

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.68,
      ),
      child: switch (message.parsedContent) {
        final LocationContent loc => LocationMessageBubble(
            message: message,
            location: loc,
            isMe: isMe,
          ),
        _ => _TextBubble(message: message, isMe: isMe),
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: isMe
          ? Row(children: [const Spacer(), bubble])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                showAvatar
                    ? CircleAvatar(
                        radius: 15,
                        backgroundImage: contactAvatar.isNotEmpty ? NetworkImage(contactAvatar) : null,
                        onBackgroundImageError: contactAvatar.isNotEmpty ? (_, __) {} : null,
                        backgroundColor: _kBorder,
                      )
                    : const SizedBox(width: 30),
                AppGap.w8,
                bubble,
                const Spacer(),
              ],
            ),
    );
  }
}

class _TextBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  const _TextBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? _kInk : _kWhite,
        border: isMe ? null : Border.all(color: _kBorder, width: 0.8),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: (isMe
                    ? context.chatBubbleTextOnDarkStyle
                    : context.chatBubbleTextStyle)
                .copyWith(color: isMe ? _kWhite : _kInk),
          ),
          AppGap.h4,
          MessageTimeStatus(message: message, isMe: isMe),
          if (message.status == MessageStatus.failed && isMe)
            _RetryButton(message: message),
        ],
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  final ChatMessage message;
  const _RetryButton({required this.message});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ChatProvider>().retryMessage(message),
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, size: 13, color: AppColors.error),
            const SizedBox(width: 3),
            Text(
              'Réessayer',
              style: context.chatTimestampStyle.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemBubble extends StatelessWidget {
  final String text;
  const _SystemBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _kBorder,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: context.chatSystemStyle.copyWith(color: _kGrayMid),
        textAlign: TextAlign.center,
      ),
    );
  }
}
