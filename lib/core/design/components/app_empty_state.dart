import 'package:flutter/material.dart';
import '../tokens/app_spacing.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

/// État vide unifié — icône + titre + description optionnelle + CTA optionnel.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? body;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final ButtonVariant ctaVariant;
  final EdgeInsetsGeometry padding;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.ctaLabel,
    this.onCta,
    this.ctaVariant = ButtonVariant.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: context.colors.textTertiary),
            ),
            AppGap.h16,
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
            if (body != null) ...[
              AppGap.h8,
              Text(
                body!,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
            if (ctaLabel != null && onCta != null) ...[
              AppGap.h24,
              AppButton(
                label: ctaLabel!,
                variant: ctaVariant,
                onPressed: onCta,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
