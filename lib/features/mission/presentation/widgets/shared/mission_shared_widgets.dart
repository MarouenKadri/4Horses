import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/mission.dart';
import '../cards/primitives/mission_card_frame.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🧩 Inkern - Widgets Communs Mission (Partagés Client & Freelancer)
/// ═══════════════════════════════════════════════════════════════════════════

// ─── Badge Statut ────────────────────────────────────────────────────────────

class MissionStatusBadge extends StatelessWidget {
  final MissionStatus status;
  final bool showIcon;
  final bool compact;

  const MissionStatusBadge({
    super.key,
    required this.status,
    this.showIcon = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = context.colors.textPrimary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 11,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.18),
          width: 0.9,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status.label.toUpperCase(),
            style:
                (compact ? context.text.labelSmall : context.text.labelMedium)
                    ?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: badgeColor,
                      letterSpacing: 1.1,
                    ),
          ),
          if (showIcon) ...[
            AppGap.w4,
            Icon(status.icon, size: 13, color: badgeColor),
          ],
        ],
      ),
    );
  }
}

// ─── Chip Catégorie ───────────────────────────────────────────────────────────

class CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final bool compact;

  const CategoryChip({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.compact = false,
  });

  factory CategoryChip.fromCategory(
    ServiceCategory category, {
    bool compact = false,
  }) {
    return CategoryChip(
      icon: category.icon,
      label: category.name,
      color: category.color,
      compact: compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = context.isAppTheme
        ? context.colors.primary
        : (color ?? context.colors.primary);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          compact ? AppRadius.tag : AppRadius.small,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: effectiveColor),
          AppGap.w4,
          Text(
            label,
            style: compact
                ? context.text.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: effectiveColor,
                  )
                : context.text.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: effectiveColor,
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Chip Info (date, lieu, durée) ────────────────────────────────────────────

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final bool compact;

  const InfoChip({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: compact ? 14 : 16,
          color: iconColor ?? context.colors.textTertiary,
        ),
        AppGap.w4,
        Flexible(
          child: Text(
            text,
            style: compact
                ? context.text.labelMedium
                : context.text.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Badge Budget ─────────────────────────────────────────────────────────────

class BudgetBadge extends StatelessWidget {
  final BudgetInfo budget;
  /// large = true → badge hero dans les pages détail (fontSize 22)
  /// large = false → badge compact dans les cartes (fontSize 15)
  final bool large;

  const BudgetBadge({
    super.key,
    required this.budget,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final isQuote = budget.type == BudgetType.quote;
    final isHourly = budget.type == BudgetType.hourly;

    if (isQuote) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: large ? 14 : 12,
          vertical: large ? 9 : 7,
        ),
        decoration: BoxDecoration(
          color: context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(large ? 14 : 10),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.request_quote_outlined,
                size: large ? 16 : 14, color: context.colors.textSecondary),
            SizedBox(width: large ? 6 : 5),
            Text(
              'Sur devis',
              style: context.missionButtonStyle.copyWith(
                fontSize: large ? AppFontSize.body : AppFontSize.md,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final amount = budget.amount?.toInt() ?? 0;
    final valueText = '$amount €${isHourly ? '/h' : ''}';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 13,
        vertical: large ? 10 : 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.inkDark,
        borderRadius: BorderRadius.circular(large ? 14 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        valueText,
        style: context.missionDarkValueStyle.copyWith(
          fontSize: large ? AppFontSize.h2Lg : AppFontSize.title,
        ),
      ),
    );
  }
}

class BudgetText extends StatelessWidget {
  final BudgetInfo budget;
  final bool large;

  const BudgetText({super.key, required this.budget, this.large = false});

  @override
  Widget build(BuildContext context) {
    final isQuote = budget.type == BudgetType.quote;
    final isHourly = budget.type == BudgetType.hourly;
    final amount = budget.amount?.toInt() ?? 0;
    final valueText = '$amount €${isHourly ? '/h' : ''}';

    if (isQuote) {
      return Text(
        budget.displayText,
        style: (large ? MissionCardFrame.captionStyle : MissionCardFrame.metaStyle)
            .copyWith(
              color: AppColors.cardCaption,
              fontWeight: FontWeight.w600,
            ),
      );
    }

    return Text(
      valueText,
      style: context.missionEntityNameStyle.copyWith(
        fontSize: large ? AppFontSize.xl : AppFontSize.lg,
        letterSpacing: -0.2,
        height: 1,
      ),
    );
  }
}

// ─── Avatar Utilisateur ───────────────────────────────────────────────────────

class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final bool showVerified;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 18,
    this.showVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: context.colors.surfaceAlt,
          child: ClipOval(
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return _AvatarShimmer(radius: radius);
                    },
                    errorBuilder: (_, __, ___) =>
                        _AvatarPlaceholder(radius: radius),
                  )
                : _AvatarPlaceholder(radius: radius),
          ),
        ),
        if (showVerified)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: AppInsets.a2,
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_rounded,
                size: radius * 0.6,
                color: AppColors.info,
              ),
            ),
          ),
      ],
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  final double radius;
  const _AvatarPlaceholder({required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: context.colors.surfaceAlt,
      child: Icon(
        Icons.person_rounded,
        size: radius,
        color: context.colors.textHint,
      ),
    );
  }
}

class _AvatarShimmer extends StatefulWidget {
  final double radius;
  const _AvatarShimmer({required this.radius});

  @override
  State<_AvatarShimmer> createState() => _AvatarShimmerState();
}

class _AvatarShimmerState extends State<_AvatarShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.4,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (ctx, __) => Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        color: ctx.colors.border.withValues(alpha: _anim.value),
      ),
    );
  }
}

// ─── Rating ──────────────────────────────────────────────────────────────────

class RatingWidget extends StatelessWidget {
  final double rating;
  final int? reviewsCount;
  final int? missionsCount;
  final bool compact;
  final bool showStars;

  const RatingWidget({
    super.key,
    required this.rating,
    this.reviewsCount,
    this.missionsCount,
    this.compact = false,
    this.showStars = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showStars) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          5,
          (i) => Icon(
            i < rating.round() ? Icons.star_rounded : Icons.star_border_rounded,
            size: compact ? 14 : 16,
            color: i < rating.round()
                ? AppColors.rating
                : context.colors.border,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 14, color: AppColors.rating),
        AppGap.w2,
        Text(
          rating.toStringAsFixed(1),
          style: compact
              ? context.text.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                )
              : context.text.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
        ),
        if (reviewsCount != null)
          Text(
            ' ($reviewsCount)',
            style: compact
                ? context.text.labelSmall?.copyWith(
                    color: context.colors.textSecondary,
                  )
                : context.text.labelSmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
          ),
      ],
    );
  }
}

// ─── Image Header ─────────────────────────────────────────────────────────────

class MissionImageHeader extends StatelessWidget {
  final List<String> images;
  final IconData fallbackIcon;
  final bool showImageCount;
  final double height;
  final BorderRadius? borderRadius;
  final String? heroTag;

  const MissionImageHeader({
    super.key,
    required this.images,
    required this.fallbackIcon,
    this.showImageCount = true,
    this.height = 140,
    this.borderRadius,
    this.heroTag,
  });

  Widget _buildImage(
    BuildContext context,
    String src,
    double height,
    IconData fallback,
  ) {
    final isLocal = !src.startsWith('http');
    errorWidget(_, __, ___) => Container(
      height: height,
      color: context.colors.divider,
      child: Icon(fallback, size: 48, color: context.colors.textTertiary),
    );
    if (isLocal) {
      return Image.file(
        File(src),
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: errorWidget,
      );
    }
    return Image.network(
      src,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: errorWidget,
      loadingBuilder: (ctx, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          color: context.colors.surfaceAlt,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.colors.textTertiary,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    final child = ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      child: Stack(
        children: [
          _buildImage(context, images.first, height, fallbackIcon),
          if (showImageCount && images.length > 1)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_library_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    AppGap.w4,
                    Text(
                      '${images.length}',
                      style: context.text.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
    if (heroTag != null) return Hero(tag: heroTag!, child: child);
    return child;
  }
}

// ─── État Vide ────────────────────────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppInsets.a32,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: AppColors.primary),
            ),
            AppGap.h20,
            Text(
              title,
              style: context.text.headlineSmall,
              textAlign: TextAlign.center,
            ),
            AppGap.h8,
            Text(
              subtitle,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.textTertiary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              AppGap.h28,
              AppButton(
                label: buttonText!,
                variant: ButtonVariant.primary,
                icon: Icons.add_rounded,
                onPressed: onButtonPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Transition de page Slide-Up + Fade ───────────────────────────────────────

PageRoute<T> slideUpRoute<T>({required Widget page}) => PageRouteBuilder<T>(
  pageBuilder: (_, __, ___) => page,
  transitionDuration: const Duration(milliseconds: 350),
  reverseTransitionDuration: const Duration(milliseconds: 280),
  transitionsBuilder: (_, animation, __, child) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      ),
    );
  },
);

// ─── Skeleton Loaders ─────────────────────────────────────────────────────────

class SkeletonList extends StatefulWidget {
  final int count;
  const SkeletonList({super.key, this.count = 3});

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: widget.count,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => _MissionCardSkeleton(opacity: _anim.value),
        ),
      ),
    );
  }
}

class _MissionCardSkeleton extends StatelessWidget {
  final double opacity;
  const _MissionCardSkeleton({required this.opacity});

  Widget _box(BuildContext context, double? w, double h, [double r = 6]) =>
      Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: context.colors.border.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(r),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.card),
            ),
            child: _box(context, double.infinity, 120, 0),
          ),
          Padding(
            padding: AppPadding.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _box(context, 80, 22, AppRadius.badge),
                    const Spacer(),
                    _box(context, 70, 22, AppRadius.badge),
                  ],
                ),
                AppGap.h12,
                _box(context, double.infinity, 18),
                AppGap.h6,
                _box(context, 200, 14),
                AppGap.h12,
                Row(
                  children: [
                    _box(context, 90, 14),
                    AppGap.w10,
                    _box(context, 80, 14),
                  ],
                ),
                AppGap.h12,
                Divider(height: 1, color: context.colors.divider),
                AppGap.h12,
                Row(
                  children: [
                    _box(context, 70, 20),
                    const Spacer(),
                    _box(context, 110, 32, AppRadius.chip),
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

// ─── Info Row (date / heure / durée) ─────────────────────────────────────────

class MissionInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const MissionInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          AppGap.h8,
          Text(label, style: context.text.labelMedium),
          AppGap.h4,
          Text(
            value,
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class MissionVerticalDivider extends StatelessWidget {
  const MissionVerticalDivider({super.key});
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 50, color: context.colors.divider);
}

class MissionLocationRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool showMapIcon;

  const MissionLocationRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.showMapIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: AppInsets.a10,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        AppGap.w14,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.text.labelMedium),
              AppGap.h2,
              Text(
                value,
                style: context.text.labelLarge?.copyWith(
                  fontSize: AppFontSize.body,
                ),
              ),
            ],
          ),
        ),
        if (showMapIcon)
          const Icon(Icons.map_rounded, color: AppColors.primary, size: 22),
      ],
    );
  }
}

// ─── Card Container ───────────────────────────────────────────────────────────

class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const CardContainer({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? AppInsets.h16v6,
      decoration: AppDecorations.card(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: padding ?? AppPadding.cardLarge,
            child: child,
          ),
        ),
      ),
    );
  }
}
