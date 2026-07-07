import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/app_design_system.dart';
import '../../data/models/message.dart';
import 'message_time_status.dart';

const _kInk = AppColors.ink;
const _kWhite = AppColors.surface;

class LocationMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final LocationContent location;
  final bool isMe;

  const LocationMessageBubble({
    super.key,
    required this.message,
    required this.location,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final mapUrl =
        'https://staticmap.openstreetmap.de/staticmap.php'
        '?center=${location.lat},${location.lng}'
        '&zoom=15&size=300x150'
        '&markers=${location.lat},${location.lng},red-pushpin';

    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse('https://maps.google.com/?q=${location.lat},${location.lng}'),
        mode: LaunchMode.externalApplication,
      ),
      child: Container(
        width: 230,
        decoration: BoxDecoration(
          color: isMe ? _kInk : _kWhite,
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
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  mapUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: context.colors.surfaceAlt,
                    child: Center(
                      child: Icon(
                        Icons.map_outlined,
                        size: 36,
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.open_in_new_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ouvrir',
                          style: context.chatPrimaryActionStyle.copyWith(
                            fontSize: AppFontSize.xs,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: isMe
                        ? _kWhite.withValues(alpha: 0.8)
                        : AppColors.primary,
                  ),
                  AppGap.w4,
                  Expanded(
                    child: Text(
                      'Position partagée',
                      style: context.chatLocationLabelStyle.copyWith(
                        color: isMe ? _kWhite : _kInk,
                      ),
                    ),
                  ),
                  MessageTimeStatus(message: message, isMe: isMe),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
