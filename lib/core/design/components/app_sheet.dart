import 'dart:ui';

import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sheet components
// ─────────────────────────────────────────────────────────────────────────────

class AppBottomSheetHandle extends StatelessWidget {
  const AppBottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Center(
        child: Container(
          width: 30,
          height: 2.5,
          decoration: BoxDecoration(
            color: context.colors.textHint.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ),
    );
  }
}

class AppSheetSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const AppSheetSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? context.colors.sheetBg;
    final resolvedBg = color == null ? bg.withValues(alpha: 0.86) : bg;
    final resolvedBorderColor = color == null
        ? context.colors.border.withValues(alpha: 0.85)
        : context.colors.border;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: resolvedBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: resolvedBorderColor),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(15, 23, 42, 0.10),
                blurRadius: 28,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class AppSheetHeader extends StatelessWidget {
  final String title;

  const AppSheetHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppBottomSheetHandle(),
        AppGap.h16,
        Text(title, style: context.profileSheetTitleStyle),
        AppGap.h14,
        Divider(color: context.colors.divider, height: 1),
      ],
    );
  }
}

class AppFormSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? footer;
  final EdgeInsetsGeometry contentPadding;
  final Color? color;

  const AppFormSheet({
    super.key,
    required this.title,
    required this.child,
    this.footer,
    this.contentPadding = const EdgeInsets.fromLTRB(20, 16, 20, 24),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppSheetSurface(
      color: color ?? AppColors.snow,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: contentPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppBottomSheetHandle(),
                  AppGap.h20,
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: context.sheetFormTitleStyle,
                  ),
                  AppGap.h16,
                  Divider(color: context.colors.divider, height: 1),
                  AppGap.h24,
                  child,
                ],
              ),
            ),
            if (footer != null) ...[
              Divider(color: context.colors.divider, height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: footer!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppPickerSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? footer;
  final bool dark;
  final Alignment titleAlignment;
  final EdgeInsetsGeometry contentPadding;

  const AppPickerSheet({
    super.key,
    required this.title,
    required this.child,
    this.footer,
    this.dark = false,
    this.titleAlignment = Alignment.centerLeft,
    this.contentPadding = const EdgeInsets.fromLTRB(20, 0, 20, 0),
  });

  @override
  Widget build(BuildContext context) {
    final sheet = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppBottomSheetHandle(),
        AppGap.h12,
        Padding(
          padding: contentPadding,
          child: Align(
            alignment: titleAlignment,
            child: Text(
              title,
              style: dark
                  ? context.sheetPickerTitleDarkStyle
                  : context.sheetPickerTitleStyle,
            ),
          ),
        ),
        AppGap.h8,
        child,
        if (footer != null) footer!,
      ],
    );

    if (dark) {
      return AppDarkSheet(child: sheet);
    }
    return AppSheetSurface(color: context.colors.sheetBg, child: sheet);
  }
}

class AppActionSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? header;
  final bool dark;

  const AppActionSheet({
    super.key,
    required this.title,
    required this.children,
    this.header,
    this.dark = true,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppBottomSheetHandle(),
        if (header != null) ...[
          header!,
        ] else ...[
          AppGap.h12,
          Padding(
            padding: AppInsets.h20,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: dark
                    ? context.sheetPickerTitleDarkStyle
                    : context.sheetPickerTitleStyle,
              ),
            ),
          ),
          AppGap.h8,
        ],
        ...children,
        SizedBox(height: 12 + bottom),
      ],
    );

    if (dark) {
      return AppDarkSheet(child: content);
    }
    return AppSheetSurface(color: context.colors.sheetBg, child: content);
  }
}

class AppActionSheetItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;
  final bool dark;

  const AppActionSheetItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
    this.dark = true,
  });

  @override
  Widget build(BuildContext context) {
    final destructiveColor = context.colors.error;
    final titleColor = destructive
        ? destructiveColor
        : dark
            ? AppColors.snow
            : context.colors.textPrimary;
    final iconColor = destructive
        ? destructiveColor
        : dark
            ? AppColors.snow.withValues(alpha: 0.85)
            : context.colors.textSecondary;
    final subtitleColor = dark ? AppColors.gray500 : context.colors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: [
            Icon(icon, size: 21, color: iconColor),
            AppGap.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.sheetActionTitleStyle.copyWith(
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    AppGap.h2,
                    Text(
                      subtitle!,
                      style: context.sheetActionSubtitleStyle.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppScrollableSheet extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final Widget? header;
  final Widget? footer;
  final Color? color;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final Widget Function(BuildContext context, ScrollController controller)
  builder;

  const AppScrollableSheet({
    super.key,
    required this.builder,
    this.title,
    this.trailing,
    this.header,
    this.footer,
    this.color,
    this.initialChildSize = 0.7,
    this.minChildSize = 0.4,
    this.maxChildSize = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      builder: (context, controller) => AppSheetSurface(
        color: color ?? context.colors.sheetBg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) ...[
              header!,
            ] else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  children: [
                    if (title == null && trailing == null)
                      const Center(child: AppBottomSheetHandle())
                    else
                      Row(
                        children: [
                          if (title == null)
                            const Expanded(
                              child: Center(child: AppBottomSheetHandle()),
                            )
                          else
                            const Expanded(
                              child: Center(child: AppBottomSheetHandle()),
                            ),
                          if (trailing != null) trailing!,
                        ],
                      ),
                    if (title != null) ...[
                      AppGap.h12,
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title!,
                              textAlign: TextAlign.center,
                              style: context.sheetFormTitleStyle,
                            ),
                          ),
                          if (trailing != null) ...[
                            AppGap.w8,
                            SizedBox(width: 40, child: trailing!),
                          ],
                        ],
                      ),
                      AppGap.h16,
                      Divider(color: context.colors.divider, height: 1),
                    ],
                  ],
                ),
              ),
            ],
            Expanded(child: builder(context, controller)),
            if (footer != null) ...[
              Divider(color: context.colors.divider, height: 1),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: footer!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet dark glassmorphism — design partagé par tous les pickers sombres.
/// Pour changer le design, modifier uniquement cette classe.
class AppDarkSheet extends StatelessWidget {
  final Widget child;

  const AppDarkSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.78),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class AppBarSheetSurface extends StatelessWidget {
  final Widget child;

  const AppBarSheetSurface({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.sheetBg.withValues(alpha: 0.72),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: context.colors.border.withValues(alpha: 0.55)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(15, 23, 42, 0.10),
                blurRadius: 24,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class AppBarOptionTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const AppBarOptionTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
    this.padding = AppInsets.h16v14,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            leading,
            AppGap.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.appBarSheetItemTitleStyle),
                  if (subtitle != null) ...[
                    AppGap.h2,
                    Text(
                      subtitle!,
                      style: context.appBarSheetItemSubtitleStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            AppGap.w12,
            trailing,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// showAppBottomSheet — helper centralisé pour les bottom sheets
// ─────────────────────────────────────────────────────────────────────────────

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  Widget? child,
  WidgetBuilder? builder,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool wrapWithSurface = true,
}) {
  assert(child != null || builder != null, 'Provide either child or builder');
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final content = builder != null ? builder(ctx) : child!;
      return wrapWithSurface ? AppSheetSurface(child: content) : content;
    },
  );
}
