import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppSurfaceCard
// ─────────────────────────────────────────────────────────────────────────────

class AppSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? margin;

  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = AppInsets.a16,
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? context.colors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.lg),
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );

    if (margin == null) return card;
    return Padding(padding: margin!, child: card);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppIconCircle
// ─────────────────────────────────────────────────────────────────────────────

class AppIconCircle extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const AppIconCircle({
    super.key,
    required this.icon,
    this.size = 42,
    this.iconSize = 20,
    this.backgroundColor = Colors.transparent,
    this.iconColor = Colors.black,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: border,
        boxShadow: boxShadow,
      ),
      child: Icon(icon, size: iconSize, color: iconColor),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppInitialCircle
// ─────────────────────────────────────────────────────────────────────────────

class AppInitialCircle extends StatelessWidget {
  final String label;
  final double size;
  final double fontSize;
  final Color backgroundColor;
  final Color foregroundColor;
  final BoxBorder? border;

  const AppInitialCircle({
    super.key,
    required this.label,
    this.size = 34,
    this.fontSize = AppFontSize.base,
    this.backgroundColor = Colors.transparent,
    this.foregroundColor = Colors.white,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: context.text.labelLarge?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: foregroundColor,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppCountBadge
// ─────────────────────────────────────────────────────────────────────────────

class AppCountBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final EdgeInsetsGeometry padding;

  const AppCountBadge({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Text(
        label,
        style: context.appBarBadgeStyle.copyWith(color: foregroundColor),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTextAction
// ─────────────────────────────────────────────────────────────────────────────

class AppTextAction extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const AppTextAction({super.key, required this.label, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: context.profileSheetActionStyle.copyWith(color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBadgeDot
// ─────────────────────────────────────────────────────────────────────────────
// AppLoadingIndicator
// ─────────────────────────────────────────────────────────────────────────────

class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const AppLoadingIndicator({
    super.key,
    this.size = 20,
    this.strokeWidth = 2,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? AppColors.primary,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class AppBadgeDot extends StatelessWidget {
  final Color color;
  final double size;

  const AppBadgeDot({super.key, this.color = AppColors.primary, this.size = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppPageBody
// ─────────────────────────────────────────────────────────────────────────────

class AppPageBody extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool useSafeAreaTop;
  final bool useSafeAreaBottom;

  const AppPageBody({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.useSafeAreaTop = false,
    this.useSafeAreaBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: useSafeAreaTop,
      bottom: useSafeAreaBottom,
      child: Padding(padding: padding, child: child),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppSection
// ─────────────────────────────────────────────────────────────────────────────

class AppSection extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  const AppSection({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final section = Container(color: color, padding: padding, child: child);
    if (margin == null) return section;
    return Padding(padding: margin!, child: section);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppSectionHeader
// ─────────────────────────────────────────────────────────────────────────────

class AppSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding = AppInsets.h20,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.text.titleMedium?.copyWith(
                fontSize: AppFontSize.lg,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppEmptyStateBlock
// ─────────────────────────────────────────────────────────────────────────────

class AppEmptyStateBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  const AppEmptyStateBlock({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: context.colors.border),
          AppGap.h16,
          Text(
            title,
            style: context.text.titleMedium?.copyWith(
              fontSize: AppFontSize.lg,
              fontWeight: FontWeight.w600,
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            AppGap.h8,
            Text(
              message!,
              style: context.text.bodyMedium?.copyWith(
                fontSize: AppFontSize.base,
                color: context.colors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[AppGap.h24, action!],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppInfoBanner
// ─────────────────────────────────────────────────────────────────────────────

class AppInfoBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color? color;

  const AppInfoBanner({
    super.key,
    required this.icon,
    required this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tone = color ?? context.colors.info;
    return AppSurfaceCard(
      padding: AppInsets.a14,
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: context.colors.border),
      child: Row(
        children: [
          Icon(icon, color: tone, size: 20),
          AppGap.w12,
          Expanded(
            child: Text(
              message,
              style: context.text.bodySmall?.copyWith(
                fontSize: AppFontSize.md,
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppPageHeaderBlock
// ─────────────────────────────────────────────────────────────────────────────

class AppPageHeaderBlock extends StatelessWidget {
  final String title;
  final String subtitle;

  const AppPageHeaderBlock({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.text.headlineMedium?.copyWith(
            fontSize: AppFontSize.h2,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
        AppGap.h8,
        Text(
          subtitle,
          style: context.text.bodyMedium?.copyWith(
            fontSize: AppFontSize.body,
            fontWeight: FontWeight.w400,
            color: context.colors.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// AppProgressBar — barre de progression réutilisable
// Utilisée par AppProgressHeader (auth) ET create_mission_page
// ─────────────────────────────────────────────────────────────────────────────

class AppProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String? stepLabel;
  final EdgeInsetsGeometry padding;

  const AppProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabel,
    this.padding = const EdgeInsets.fromLTRB(20, 6, 20, 0),
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Barre ────────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 2,
              child: Stack(
                children: [
                  Container(color: context.colors.divider),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) => FractionallySizedBox(
                      widthFactor: value,
                      child: Container(color: context.colors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Label étape ──────────────────────────────────────────────────
          if (stepLabel != null) ...[
            const SizedBox(height: 10),
            Text(stepLabel!, style: context.progressStepLabelStyle),
          ],
        ],
      ),
    );
  }
}

// AppProgressHeader
// ─────────────────────────────────────────────────────────────────────────────

class AppProgressHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;
  final String? stepLabel;

  const AppProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    this.stepLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: context.colors.textPrimary,
                onPressed: onBack,
              ),
            ],
          ),
        ),
        AppProgressBar(
          currentStep: currentStep,
          totalSteps: totalSteps,
          stepLabel: stepLabel,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppFlowHeader
// ─────────────────────────────────────────────────────────────────────────────

class AppFlowHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const AppFlowHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 10),
  });

  @override
  Widget build(BuildContext context) {
    return AppSection(
      padding: padding,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: context.colors.textPrimary,
            ),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          AppGap.w8,
          Expanded(
            child: Text(
              title,
              style: context.text.titleLarge?.copyWith(
                fontSize: AppFontSize.lg,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppArrowActionButton
// ─────────────────────────────────────────────────────────────────────────────

class AppArrowActionButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final double iconSize;
  final BoxShape shape;

  const AppArrowActionButton({
    super.key,
    required this.enabled,
    this.onPressed,
    this.width = 60,
    this.height = 60,
    this.iconSize = 28,
    this.shape = BoxShape.circle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: shape,
          color: enabled ? Colors.black : context.colors.divider,
          borderRadius: shape == BoxShape.rectangle
              ? BorderRadius.circular(AppRadius.button)
              : null,
        ),
        child: Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppKeyboardActionBar
// ─────────────────────────────────────────────────────────────────────────────

class AppKeyboardActionBar extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;

  const AppKeyboardActionBar({super.key, required this.enabled, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppSection(
      color: context.colors.surface,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedOpacity(
            opacity: enabled ? 1.0 : 0.35,
            duration: const Duration(milliseconds: 200),
            child: AppArrowActionButton(
              enabled: enabled,
              onPressed: onTap,
              width: 52,
              height: 44,
              iconSize: 24,
              shape: BoxShape.rectangle,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppRoundIconTile
// ─────────────────────────────────────────────────────────────────────────────

class AppRoundIconTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const AppRoundIconTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppInsets.h20v12,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            AppGap.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.titleSmall?.copyWith(
                      fontSize: AppFontSize.body,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  AppGap.h2,
                  Text(
                    subtitle,
                    style: context.text.bodySmall?.copyWith(
                      fontSize: AppFontSize.md,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppPillChip
// ─────────────────────────────────────────────────────────────────────────────

class AppPillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedBackgroundColor;
  final Color? selectedForegroundColor;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;

  const AppPillChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.selectedBackgroundColor,
    this.selectedForegroundColor,
    this.backgroundColor,
    this.foregroundColor,
    this.padding = AppInsets.h14v8,
    this.margin = EdgeInsets.zero,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? (selectedBackgroundColor ?? AppColors.primary)
        : (backgroundColor ?? context.colors.surfaceAlt);
    final fg = selected
        ? (selectedForegroundColor ?? Colors.white)
        : (foregroundColor ?? context.colors.textPrimary);

    return Padding(
      padding: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.cardLg),
          child: Ink(
            padding: padding,
            decoration: BoxDecoration(
              color: bg,
              borderRadius:
                  borderRadius ?? BorderRadius.circular(AppRadius.cardLg),
              border: Border.all(color: selected ? bg : context.colors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: fg),
                  AppGap.w6,
                ],
                Text(
                  label,
                  style: context.text.labelLarge?.copyWith(
                    fontSize: AppFontSize.md,
                    fontWeight: FontWeight.w500,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTagPill
// ─────────────────────────────────────────────────────────────────────────────

class AppTagPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final FontWeight fontWeight;

  const AppTagPill({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    this.fontSize = AppFontSize.xs,
    this.fontWeight = FontWeight.w800,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: foregroundColor),
            AppGap.w3,
          ],
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppSettingsTile
// ─────────────────────────────────────────────────────────────────────────────

class AppSettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final Color? backgroundColor;

  const AppSettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? context.colors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: context.accountMenuTitleStyle),
                        if (subtitle != null) ...[
                          AppGap.h2,
                          Text(
                            subtitle!,
                            style: context.accountMenuSubtitleStyle,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null)
                    trailing!
                  else
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: context.colors.textHint,
                    ),
                ],
              ),
            ),
          ),
          if (showDivider)
            Divider(height: 1, indent: 16, color: context.colors.divider),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppSettingsSectionHeader
// ─────────────────────────────────────────────────────────────────────────────

class AppSettingsSectionHeader extends StatelessWidget {
  final String label;
  final EdgeInsetsGeometry padding;

  const AppSettingsSectionHeader({
    super.key,
    required this.label,
    this.padding = const EdgeInsets.fromLTRB(2, 20, 0, 10),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(label.toUpperCase(), style: context.accountSectionStyle),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppListSurface
// ─────────────────────────────────────────────────────────────────────────────

class AppListSurface extends StatelessWidget {
  final List<Widget> children;
  final BorderRadius? borderRadius;

  const AppListSurface({super.key, required this.children, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        color: context.colors.surface,
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppActionFooter
// ─────────────────────────────────────────────────────────────────────────────

class AppActionFooter extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final bool showTopBorder;

  const AppActionFooter({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 16),
    this.showTopBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.surface,
        border: showTopBorder
            ? Border(top: BorderSide(color: context.colors.divider, width: 1))
            : null,
      ),
      child: SafeArea(
        top: false,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppHeroSliverBar
// ─────────────────────────────────────────────────────────────────────────────

class AppHeroSliverBar extends StatelessWidget {
  final List<Color> gradientColors;
  final double expandedHeight;
  final Widget body;
  final List<Widget>? actions;
  final bool pinned;
  final Widget? leadingBack;

  const AppHeroSliverBar({
    super.key,
    required this.gradientColors,
    required this.body,
    this.expandedHeight = 220,
    this.actions,
    this.pinned = true,
    this.leadingBack,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      backgroundColor: gradientColors.first,
      leading:
          leadingBack ??
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: SafeArea(child: body),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppQuickActionCard
// ─────────────────────────────────────────────────────────────────────────────

class AppQuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const AppQuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppInsets.v16,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: AppInsets.a12,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            AppGap.h8,
            Text(
              label,
              style: context.text.labelSmall?.copyWith(
                fontSize: AppFontSize.md,
                fontWeight: FontWeight.w600,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTransactionTile
// ─────────────────────────────────────────────────────────────────────────────

class AppTransactionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final String amount;
  final String date;
  final bool isCredit;

  const AppTransactionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    this.iconColor = AppColors.primary,
    this.iconBackground = AppColors.secondary,
    this.isCredit = false,
  });

  @override
  Widget build(BuildContext context) {
    final amountColor = isCredit
        ? context.colors.success
        : context.colors.textPrimary;
    return Padding(
      padding: AppInsets.h16v12,
      child: Row(
        children: [
          Container(
            padding: AppInsets.a10,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.titleSmall?.copyWith(
                    fontSize: AppFontSize.body,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: context.text.bodySmall?.copyWith(
                    fontSize: AppFontSize.md,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: context.text.titleSmall?.copyWith(
                  fontSize: AppFontSize.lg,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
              Text(
                date,
                style: context.text.labelSmall?.copyWith(
                  fontSize: AppFontSize.sm,
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppDangerBanner
// ─────────────────────────────────────────────────────────────────────────────

class AppDangerBanner extends StatelessWidget {
  final String title;
  final List<String> items;

  const AppDangerBanner({
    super.key,
    required this.title,
    this.items = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.a16,
      decoration: BoxDecoration(
        color: context.colors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.colors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: context.colors.error,
                size: 16,
              ),
              AppGap.w8,
              Expanded(
                child: Text(
                  title,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            AppGap.h10,
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Icon(
                        Icons.remove_circle_outline_rounded,
                        size: 13,
                        color: context.colors.error,
                      ),
                    ),
                    AppGap.w8,
                    Expanded(
                      child: Text(
                        item,
                        style: context.text.bodyMedium?.copyWith(
                          color: context.colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppErrorMessage
// ─────────────────────────────────────────────────────────────────────────────

class AppErrorMessage extends StatelessWidget {
  final String message;

  const AppErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.h12v10,
      decoration: BoxDecoration(
        color: context.colors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 15,
            color: context.colors.error,
          ),
          AppGap.w8,
          Expanded(
            child: Text(
              message,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
