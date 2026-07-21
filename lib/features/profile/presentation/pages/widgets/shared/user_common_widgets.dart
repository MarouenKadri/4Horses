import 'package:flutter/material.dart';
import '../../../../../../core/design/app_design_system.dart';

/// ─── Widget partagé : section avec icon badge ────────────────────────────
/// Utilise par les anciennes feuilles profil et par les écrans profil partagés.
class ProfileSheetSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const ProfileSheetSection({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSurfaceCard(
                padding: const EdgeInsets.all(
                  AppProfileMetrics.sectionBadgePadding,
                ),
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(color: context.colors.border, width: 1),
                child: Icon(icon, size: 16, color: context.colors.textPrimary),
              ),
              AppGap.w10,
              Text(
                title.toUpperCase(),
                style: context.profileSheetSectionStyle.copyWith(
                  color: context.colors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          AppGap.h14,
          child,
        ],
      ),
    );
  }
}

/// ─── Widget partagé : étape de vérification ───────────────────────────────
/// Utilisé dans account_page.dart et freelancer_activity_page.dart
class VerificationStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const VerificationStep({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.v8,
      child: Row(
        children: [
          AppSurfaceCard(
            padding: AppInsets.a10,
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.badge),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: AppProfileMetrics.verificationIconSize,
            ),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.profilePrimaryLabelStyle),
                Text(subtitle, style: context.profileSecondaryLabelStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration profileSheetInputDecoration(
  BuildContext context, {
  required String label,
  required IconData icon,
  bool readOnly = false,
}) {
  final borderColor = context.colors.border;
  final focusColor = context.colors.textPrimary;
  final labelColor = readOnly
      ? context.colors.textHint
      : context.colors.textSecondary;

  OutlineInputBorder outline(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppProfileMetrics.sheetFieldRadius),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    labelStyle: context.profileSheetFieldLabelStyle.copyWith(color: labelColor),
    floatingLabelStyle: context.profileSheetFieldLabelStyle.copyWith(
      color: readOnly ? context.colors.textHint : focusColor,
    ),
    prefixIcon: Icon(
      icon,
      size: AppProfileMetrics.sheetFieldIconSize,
      color: context.colors.textPrimary,
    ),
    contentPadding: AppInsets.h16v18,
    filled: false,
    enabledBorder: outline(borderColor),
    focusedBorder: outline(
      readOnly ? borderColor : focusColor,
      readOnly ? 1 : 1.2,
    ),
    errorBorder: outline(context.colors.error),
    focusedErrorBorder: outline(context.colors.error, 1.2),
    disabledBorder: outline(borderColor),
  );
}

class ProfileSheetPrimaryAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const ProfileSheetPrimaryAction({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: ButtonVariant.black,
      height: AppProfileMetrics.sheetPrimaryActionHeight,
    );
  }
}

class ProfileSheetSecondaryAction extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const ProfileSheetSecondaryAction({
    super.key,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onTap,
      variant: ButtonVariant.ghost,
      height: 44,
    );
  }
}
