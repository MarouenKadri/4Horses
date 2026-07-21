import 'package:flutter/material.dart';
import '../../../../../../core/design/app_design_system.dart';

// ─── Statut de vérification champ (email / téléphone) ────────────────────────
enum RegisterFieldStatus { idle, checking, available, taken }

// ─── Helper header ────────────────────────────────────────────────────────────
Widget registerPageHeader(BuildContext context, String title, String subtitle) {
  return AppPageHeaderBlock(title: title, subtitle: subtitle);
}

// ─── Carte sélectionnable (Genre, Rôle) ──────────────────────────────────────
class RegisterSelectableCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const RegisterSelectableCard({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppInsets.a18,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppDesign.radius12),
          border: Border.all(
            color: isSelected
                ? context.colors.textPrimary
                : context.colors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.textPrimary.withValues(alpha: 0.08)
                    : context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppDesign.radius12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
                size: 24,
              ),
            ),
            AppGap.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    AppGap.h3,
                    Text(subtitle!, style: context.text.bodySmall),
                  ],
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? context.colors.textPrimary
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? context.colors.textPrimary
                      : context.colors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Indicateur de statut (idle / checking / available / taken) ───────────────
class RegisterFieldStatusRow extends StatelessWidget {
  final RegisterFieldStatus status;
  final String takenMessage;

  const RegisterFieldStatusRow({
    super.key,
    required this.status,
    required this.takenMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (status == RegisterFieldStatus.idle) return const SizedBox.shrink();
    final isChecking = status == RegisterFieldStatus.checking;
    final isAvailable = status == RegisterFieldStatus.available;
    final color = isChecking
        ? context.colors.textTertiary
        : isAvailable
        ? AppColors.success
        : AppColors.error;
    final icon = isChecking
        ? null
        : isAvailable
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;
    final label = isChecking
        ? 'Vérification…'
        : isAvailable
        ? 'Disponible'
        : takenMessage;

    return Row(
      children: [
        if (isChecking)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          )
        else
          Icon(icon, size: 16, color: color),
        AppGap.w6,
        Text(
          label,
          style: context.text.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
