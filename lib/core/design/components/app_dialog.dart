import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// showAppSnackBar — helper centralisé pour les SnackBar
// ─────────────────────────────────────────────────────────────────────────────

enum SnackBarType { info, success, error, warning }

void showAppSnackBar(
  BuildContext context,
  String message, {
  SnackBarType type = SnackBarType.info,
  IconData? icon,
  Duration duration = const Duration(seconds: 4),
}) {
  final colors = context.colors;

  Color? bg;
  Color contentColor = Colors.white;
  IconData? resolvedIcon = icon;

  switch (type) {
    case SnackBarType.error:
      bg = colors.error;
      resolvedIcon ??= Icons.error_outline_rounded;
      break;
    case SnackBarType.success:
      bg = colors.success;
      resolvedIcon ??= Icons.check_circle_outline_rounded;
      break;
    case SnackBarType.warning:
      bg = colors.warning;
      resolvedIcon ??= Icons.warning_amber_rounded;
      break;
    case SnackBarType.info:
      bg = null;
      contentColor = colors.textPrimary;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          if (resolvedIcon != null) ...[
            Icon(resolvedIcon, color: contentColor, size: 18),
            AppGap.w10,
          ],
          Expanded(
            child: Text(message, style: TextStyle(color: contentColor)),
          ),
        ],
      ),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: duration,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// showAppDialog — helper centralisé pour les AlertDialog
// ─────────────────────────────────────────────────────────────────────────────

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required Widget title,
  required Widget content,
  String? confirmLabel,
  String? cancelLabel,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  ButtonVariant confirmVariant = ButtonVariant.primary,
  bool barrierDismissible = true,
  Color? backgroundColor,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => AlertDialog(
      backgroundColor: backgroundColor ?? ctx.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
      ),
      title: title,
      content: content,
      actions: [
        if (cancelLabel != null)
          AppButton(
            label: cancelLabel,
            variant: ButtonVariant.ghost,
            width: null,
            onPressed: onCancel ?? () => Navigator.pop(ctx),
          ),
        if (confirmLabel != null)
          AppButton(
            label: confirmLabel,
            variant: confirmVariant,
            width: null,
            onPressed: onConfirm,
          ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// showAppSuccessDialog — dialog de confirmation / succès avec icône centrée
// ─────────────────────────────────────────────────────────────────────────────

Future<void> showAppSuccessDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String buttonLabel,
  required VoidCallback onPressed,
  bool barrierDismissible = false,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => AlertDialog(
      backgroundColor: ctx.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: AppInsets.a16,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          AppGap.h20,
          Text(
            title,
            style: ctx.text.headlineMedium,
            textAlign: TextAlign.center,
          ),
          AppGap.h10,
          Text(
            message,
            textAlign: TextAlign.center,
            style: ctx.text.bodyMedium?.copyWith(
              color: ctx.colors.textTertiary,
              height: 1.5,
            ),
          ),
          AppGap.h24,
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: buttonLabel,
              onPressed: onPressed,
              variant: ButtonVariant.primary,
            ),
          ),
        ],
      ),
    ),
  );
}
