import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/design/app_design_system.dart';
import '../../data/services/message_moderation_service.dart';

const _kInk       = AppColors.ink;
const _kWhite     = AppColors.surface;
const _kCharcoal  = AppColors.surfaceAlt;
const _kGrayMid   = AppColors.textTertiary;
const _kGrayLight = AppColors.textHint;
const _kBorder    = AppColors.divider;

class ChatInputBar extends StatefulWidget {
  final Future<String?> Function(String text) onSendMessage;
  final VoidCallback onSendSuccess;
  final ValueChanged<bool> onModerationWarning;
  final String contactName;
  final String contactAvatar;
  final String? activeMissionTitle;
  final bool showReserveButton;
  final VoidCallback? onReserveTap;

  const ChatInputBar({
    super.key,
    required this.onSendMessage,
    required this.onSendSuccess,
    required this.onModerationWarning,
    required this.contactName,
    required this.contactAvatar,
    this.activeMissionTitle,
    this.showReserveButton = false,
    this.onReserveTap,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _isSendingLocation = false;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    widget.onModerationWarning(false);
    final error = await widget.onSendMessage(text);
    if (!mounted) return;
    if (error != null) {
      showAppSnackBar(context, error, type: SnackBarType.error);
    } else {
      widget.onSendSuccess();
    }
  }

  Future<void> _handleSendLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      if (mounted) showAppSnackBar(context, 'Permission de localisation refusée');
      return;
    }
    setState(() => _isSendingLocation = true);
    try {
      Position? pos = await Geolocator.getLastKnownPosition();
      if (pos == null ||
          DateTime.now().difference(pos.timestamp).inMinutes > 2) {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 6),
          ),
        );
      }
      if (!mounted) return;
      final error = await widget.onSendMessage('📍 ${pos.latitude},${pos.longitude}');
      if (!mounted) return;
      if (error != null) {
        showAppSnackBar(context, error, type: SnackBarType.error);
      } else {
        widget.onSendSuccess();
      }
    } catch (_) {
      if (mounted) showAppSnackBar(context, 'Impossible d\'obtenir la position');
    } finally {
      if (mounted) setState(() => _isSendingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.trim().isNotEmpty;
    final isForbidden = hasText &&
        MessageModerationService.instance.check(_controller.text).blocked;

    return Container(
      decoration: const BoxDecoration(
        color: _kWhite,
        border: Border(top: BorderSide(color: _kBorder, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.activeMissionTitle != null)
            _MissionContextStrip(
              contactName: widget.contactName,
              contactAvatar: widget.contactAvatar,
              missionTitle: widget.activeMissionTitle!,
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              10,
              16,
              10 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showReserveButton) ...[
                  _ReserveButton(onTap: widget.onReserveTap),
                  const SizedBox(height: 8),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 44),
                        decoration: BoxDecoration(
                          color: _kWhite,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: _kBorder, width: 1),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 14, bottom: 11),
                              child: GestureDetector(
                                onTap: _isSendingLocation
                                    ? null
                                    : _handleSendLocation,
                                child: _isSendingLocation
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: _kGrayMid,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.location_on_outlined,
                                        color: _kGrayMid,
                                        size: 22,
                                      ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                focusNode: _focus,
                                maxLines: 4,
                                minLines: 1,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                style: context.chatInputStyle
                                    .copyWith(color: _kInk),
                                decoration: AppInputDecorations.formField(
                                  context,
                                  hintText: 'Votre message...',
                                  hintStyle: context.chatInputHintStyle
                                      .copyWith(color: _kGrayLight),
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 11,
                                  ),
                                  noBorder: true,
                                  fillColor: Colors.transparent,
                                ),
                                onChanged: (value) {
                                  final blocked = MessageModerationService
                                      .instance
                                      .check(value)
                                      .blocked;
                                  widget.onModerationWarning(blocked);
                                  setState(() {}); // refresh hasText / isForbidden
                                },
                                onSubmitted: (_) => _handleSend(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      child: hasText
                          ? Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: GestureDetector(
                                onTap: _handleSend,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color:
                                        isForbidden ? AppColors.error : _kInk,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isForbidden
                                        ? Icons.block_rounded
                                        : Icons.arrow_upward_rounded,
                                    color: _kWhite,
                                    size: 18,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionContextStrip extends StatelessWidget {
  final String contactName;
  final String contactAvatar;
  final String missionTitle;

  const _MissionContextStrip({
    required this.contactName,
    required this.contactAvatar,
    required this.missionTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: _kCharcoal,
        border: Border(bottom: BorderSide(color: _kBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundImage: contactAvatar.isNotEmpty ? NetworkImage(contactAvatar) : null,
            onBackgroundImageError: contactAvatar.isNotEmpty ? (_, __) {} : null,
            backgroundColor: _kBorder,
          ),
          AppGap.w6,
          Expanded(
            child: Text(
              '$contactName  ·  $missionTitle',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _kGrayMid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReserveButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _ReserveButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: _kInk,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '⚡',
              style: context.chatPrimaryActionStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              'Réserver ce service',
              style: context.chatPrimaryActionStyle.copyWith(
                fontSize: AppFontSize.base,
                color: _kWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
