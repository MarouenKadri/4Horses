import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import '../theme/app_theme.dart';
import 'app_layout.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppBar components
// ─────────────────────────────────────────────────────────────────────────────

class AppBackButtonLeading extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const AppBackButtonLeading({
    super.key,
    this.onPressed,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: color ?? context.colors.textPrimary,
        size: size,
      ),
      onPressed: onPressed ?? () => Navigator.maybePop(context),
    );
  }
}

class AppPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final bool showBorder;
  final Color? backgroundColor;
  final double toolbarHeight;

  const AppPageAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.titleWidget,
    this.leading,
    this.actions,
    this.bottom,
    this.centerTitle = false,
    this.showBorder = false,
    this.backgroundColor,
    this.toolbarHeight = kToolbarHeight,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    Widget? resolvedTitle = titleWidget;
    if (resolvedTitle == null && title != null) {
      resolvedTitle = subtitle == null
          ? Text(title!, style: context.appBarTitleStyle)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title!, style: context.appBarTitleStyle),
                Text(subtitle!, style: context.appBarSubtitleStyle),
              ],
            );
    }

    return AppBar(
      backgroundColor: backgroundColor ?? context.colors.background,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,
      shape: showBorder
          ? Border(bottom: BorderSide(color: context.colors.border, width: 0.8))
          : null,
      leading: leading,
      title: resolvedTitle,
      actions: actions,
      bottom: bottom,
    );
  }
}

class AppBarPillTitle extends StatelessWidget {
  final String label;
  final IconData icon;

  const AppBarPillTitle({
    super.key,
    required this.label,
    this.icon = Icons.eco_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.h12v6,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          AppGap.w6,
          Text(label, style: context.appBarPillStyle),
        ],
      ),
    );
  }
}

class AppBarAccentTitle extends StatelessWidget {
  final String title;

  const AppBarAccentTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: context.appBarAccentTitleStyle),
        AppGap.h3,
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ],
    );
  }
}

class AppBarActionCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final List<BoxShadow>? boxShadow;
  final BoxBorder? border;
  final String? badgeLabel;
  final Color badgeColor;
  final Animation<double>? scale;

  const AppBarActionCircleButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 38,
    this.iconSize = 22,
    required this.backgroundColor,
    required this.iconColor,
    this.boxShadow,
    this.border,
    this.badgeLabel,
    this.badgeColor = AppColors.error,
    this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final action = GestureDetector(
      onTap: onTap,
      child: AppIconCircle(
        icon: icon,
        size: size,
        iconSize: iconSize,
        backgroundColor: backgroundColor,
        iconColor: iconColor,
        boxShadow: boxShadow,
        border: border,
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        scale == null ? action : ScaleTransition(scale: scale!, child: action),
        if (badgeLabel != null)
          Positioned(
            top: -2,
            right: -2,
            child: AppCountBadge(
              label: badgeLabel!,
              backgroundColor: badgeColor,
              foregroundColor: Colors.white,
              padding: AppInsets.h4v1,
            ),
          ),
      ],
    );
  }
}

class AppBarAvatarButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double size;
  final double fontSize;
  final Color backgroundColor;
  final Color foregroundColor;
  final BoxBorder? border;
  final EdgeInsetsGeometry margin;

  const AppBarAvatarButton({
    super.key,
    required this.label,
    this.onTap,
    this.size = 38,
    this.fontSize = AppFontSize.base,
    required this.backgroundColor,
    required this.foregroundColor,
    this.border,
    this.margin = const EdgeInsets.only(right: 12, left: 2),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: GestureDetector(
        onTap: onTap,
        child: AppInitialCircle(
          label: label,
          size: size,
          fontSize: fontSize,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          border: border,
        ),
      ),
    );
  }
}

class AppBarSectionLabel extends StatelessWidget {
  final String label;
  final EdgeInsetsGeometry padding;

  const AppBarSectionLabel({
    super.key,
    required this.label,
    this.padding = AppInsets.h20,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: context.appBarSectionLabelStyle),
      ),
    );
  }
}
