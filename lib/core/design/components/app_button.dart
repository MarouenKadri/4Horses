import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import '../theme/app_theme.dart';
import 'app_layout.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppButton — bouton universel (remplace PrimaryButton / SecondaryButton)
// Variantes : primary · secondary · outline · ghost · destructive
// ─────────────────────────────────────────────────────────────────────────────

enum ButtonVariant { primary, secondary, outline, ghost, destructive, black }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final bool iconTrailing;
  final double height;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.iconTrailing = true,
    this.height = 56,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final active = isEnabled && !isLoading;

    final child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null && !iconTrailing) ...[
                  Icon(icon, size: 20),
                  AppGap.w8,
                ],
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall?.copyWith(
                    fontSize: AppFontSize.lg,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: switch (variant) {
                      ButtonVariant.primary ||
                      ButtonVariant.destructive ||
                      ButtonVariant.black => Colors.white,
                      ButtonVariant.secondary => context.colors.textPrimary,
                      ButtonVariant.outline => AppColors.primary,
                      ButtonVariant.ghost => context.colors.textSecondary,
                    },
                  ),
                ),
                if (icon != null && iconTrailing) ...[
                  AppGap.w8,
                  Icon(icon, size: 20),
                ],
              ],
            ),
          );

    switch (variant) {
      case ButtonVariant.primary:
        final bg = isEnabled ? AppColors.primary : context.colors.border;
        return AppSurfaceCard(
          padding: EdgeInsets.zero,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.button),
          boxShadow: active ? AppShadows.primaryButton : const [],
          child: SizedBox(
            width: width,
            height: height,
            child: ElevatedButton(
              onPressed: active ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
              child: child,
            ),
          ),
        );

      case ButtonVariant.secondary:
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: active ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.surfaceAlt,
              foregroundColor: context.colors.textPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
                side: BorderSide(color: context.colors.border),
              ),
            ),
            child: child,
          ),
        );

      case ButtonVariant.outline:
        return SizedBox(
          width: width,
          height: height,
          child: OutlinedButton(
            onPressed: active ? onPressed : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: child,
          ),
        );

      case ButtonVariant.ghost:
        return SizedBox(
          width: width,
          height: height,
          child: TextButton(
            onPressed: active ? onPressed : null,
            style: TextButton.styleFrom(
              foregroundColor: context.colors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: child,
          ),
        );

      case ButtonVariant.destructive:
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: active ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: child,
          ),
        );

      case ButtonVariant.black:
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: active ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled
                  ? Colors.black
                  : Colors.black.withValues(alpha: 0.12),
              foregroundColor: Colors.white,
              disabledForegroundColor: context.colors.textHint,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: child,
          ),
        );
    }
  }
}
