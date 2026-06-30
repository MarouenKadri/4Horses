import 'package:flutter/material.dart';
import '../../../../core/design/app_design_system.dart';
import '../../data/models/message.dart';

const _kWhite = AppColors.surface;
const _kGrayLight = AppColors.textHint;

class MessageTimeStatus extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageTimeStatus({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
          style: context.chatTimestampStyle.copyWith(
            color: isMe ? _kWhite.withValues(alpha: 0.75) : _kGrayLight,
          ),
        ),
        if (isMe) ...[
          AppGap.w4,
          Text(
            _statusLabel(message.status),
            style: context.chatTimestampStyle.copyWith(
              fontWeight: FontWeight.w700,
              color: _statusColor(message.status),
            ),
          ),
          AppGap.w3,
          Icon(
            _statusIcon(message.status),
            size: 14,
            color: _statusColor(message.status),
          ),
        ],
      ],
    );
  }

  String _statusLabel(MessageStatus status) => switch (status) {
    MessageStatus.sending   => 'Envoi',
    MessageStatus.sent      => 'Envoye',
    MessageStatus.delivered => 'Non lu',
    MessageStatus.read      => 'Lu',
    MessageStatus.failed    => 'Erreur',
  };

  IconData _statusIcon(MessageStatus status) => switch (status) {
    MessageStatus.sending   => Icons.schedule_rounded,
    MessageStatus.sent      => Icons.done_rounded,
    MessageStatus.delivered => Icons.done_all_rounded,
    MessageStatus.read      => Icons.done_all_rounded,
    MessageStatus.failed    => Icons.error_outline_rounded,
  };

  Color _statusColor(MessageStatus status) => switch (status) {
    MessageStatus.read   => AppColors.messageReadBg,
    MessageStatus.failed => AppColors.error,
    _                    => _kWhite.withValues(alpha: 0.82),
  };
}
