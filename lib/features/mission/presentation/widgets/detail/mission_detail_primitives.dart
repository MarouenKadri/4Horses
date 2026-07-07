import 'package:flutter/material.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/mission.dart';

// ─── StatusBannerConfig ───────────────────────────────────────────────────────
// Data object — no Widget, testable unitairement

enum DetailBannerStyle { colored, card }

class StatusBannerConfig {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool pulse;
  final DetailBannerStyle style;

  const StatusBannerConfig({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.pulse = false,
    this.style = DetailBannerStyle.card,
  });
}

// ─── DetailCircleBtn ──────────────────────────────────────────────────────────

class DetailCircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const DetailCircleBtn({
    super.key,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive
              ? Colors.white.withValues(alpha: 0.42)
              : Colors.white.withValues(alpha: 0.28),
          width: 0.6,
        ),
      ),
      child: Icon(icon, size: 16, color: Colors.white),
    ),
  );
}

// ─── DetailMetaChip ───────────────────────────────────────────────────────────

class DetailMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const DetailMetaChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: context.colors.textTertiary),
      AppGap.w6,
      Expanded(
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: context.missionMetaStyle,
        ),
      ),
    ],
  );
}

// ─── DetailLuxuryPill ─────────────────────────────────────────────────────────

class DetailLuxuryPill extends StatelessWidget {
  final String label;

  const DetailLuxuryPill({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: AppColors.inkDark, width: 0.5),
    ),
    child: Text(label, style: context.missionPillStyle),
  );
}

// ─── DetailSectionCard / Title / Label ───────────────────────────────────────

class DetailSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool showBorder;

  const DetailSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 16),
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: showBorder
            ? Border.all(color: context.colors.border, width: 0.8)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class DetailSectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const DetailSectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final titleText = Text(title, style: context.missionSectionTitleStyle);

    if (trailing == null) return titleText;

    return Row(
      children: [
        Expanded(child: titleText),
        AppGap.w12,
        trailing!,
      ],
    );
  }
}

class DetailSectionLabel extends StatelessWidget {
  final String label;

  const DetailSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(), style: context.missionSectionLabelStyle);
  }
}

// ─── DetailInlineDivider ──────────────────────────────────────────────────────

class DetailInlineDivider extends StatelessWidget {
  const DetailInlineDivider({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 12,
    margin: AppInsets.h8,
    color: context.colors.divider,
  );
}

// ─── DetailInfoRow ────────────────────────────────────────────────────────────

class DetailInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final bool twoLines;

  const DetailInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.text,
    this.twoLines = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      crossAxisAlignment: twoLines
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 17, color: context.colors.textTertiary),
        AppGap.w14,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.missionSubtleCaptionStyle),
              AppGap.h4,
              Text(
                text,
                maxLines: twoLines ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: context.missionPrimaryValueStyle,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ─── DetailListDivider ────────────────────────────────────────────────────────

class DetailListDivider extends StatelessWidget {
  const DetailListDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: AppColors.gray50, indent: 31);
}

// ─── DetailBottomArea ─────────────────────────────────────────────────────────

class DetailBottomArea extends StatelessWidget {
  final Widget child;
  final String? caption;

  const DetailBottomArea({super.key, required this.child, this.caption});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      decoration: BoxDecoration(
        color: context.colors.background,
        border: Border(top: BorderSide(color: context.colors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          if (caption != null) ...[
            AppGap.h8,
            Text(
              caption!,
              style: context.text.labelMedium?.copyWith(
                color: context.colors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── DetailTealButton ─────────────────────────────────────────────────────────

class DetailTealButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final VoidCallback? onTap;

  const DetailTealButton({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? Colors.black;
    final fg = textColor ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: onTap != null ? bg : bg.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 18, color: fg), AppGap.w8],
            Text(
              label,
              style: context.missionButtonStyle.copyWith(
                color: onTap != null ? fg : context.colors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  const DetailSecondaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: onTap != null
                    ? context.colors.textPrimary
                    : context.colors.textHint,
              ),
              AppGap.w8,
            ],
            Text(
              label,
              style: context.missionButtonStyle.copyWith(
                color: onTap != null
                    ? context.colors.textPrimary
                    : context.colors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DetailReadonlyBadge ──────────────────────────────────────────────────────

class DetailReadonlyBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const DetailReadonlyBadge({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: 52,
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.button),
      border: Border.all(color: context.colors.divider),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: context.colors.textTertiary, size: 18),
        AppGap.w8,
        Text(
          label,
          style: context.missionButtonStyle.copyWith(
            color: context.colors.textTertiary,
          ),
        ),
      ],
    ),
  );
}

// ─── DetailStatusBanner ───────────────────────────────────────────────────────
// Rend StatusBannerConfig — supporte 2 styles visuels (colored / card)

class DetailStatusBanner extends StatelessWidget {
  final StatusBannerConfig config;

  const DetailStatusBanner({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return config.style == DetailBannerStyle.card
        ? _buildCard(context)
        : _buildColored(context);
  }

  // Style client — fond coloré semi-transparent
  Widget _buildColored(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    padding: AppInsets.a14,
    decoration: BoxDecoration(
      color: config.color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppRadius.button),
      border: Border.all(color: config.color.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        config.pulse
            ? DetailPulsingDot(color: config.color)
            : Icon(config.icon, color: config.color, size: 20),
        AppGap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config.title,
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: config.color,
                ),
              ),
              AppGap.h2,
              Text(
                config.subtitle,
                style: context.text.labelMedium?.copyWith(
                  color: config.color.withValues(alpha: 0.75),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // Style freelancer — card blanche, icône muted
  Widget _buildCard(BuildContext context) {
    final iconColor = config.color == AppColors.error
        ? context.colors.error.withValues(alpha: 0.65)
        : config.color == AppColors.warning
        ? context.colors.warning.withValues(alpha: 0.65)
        : context.colors.textSecondary;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.border),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          config.pulse
              ? DetailPulsingDot(color: config.color)
              : Icon(config.icon, color: iconColor, size: 18),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(config.title, style: context.missionPrimaryValueStyle),
                AppGap.h4,
                Text(
                  config.subtitle,
                  style: context.missionBodyStyle.copyWith(
                    fontSize: AppFontSize.md,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── DetailPulsingDot ─────────────────────────────────────────────────────────

class DetailPulsingDot extends StatefulWidget {
  final Color color;

  const DetailPulsingDot({super.key, required this.color});

  @override
  State<DetailPulsingDot> createState() => _DetailPulsingDotState();
}

class _DetailPulsingDotState extends State<DetailPulsingDot>
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
      begin: 0.35,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color.withValues(alpha: _anim.value),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: _anim.value * 0.5),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
    ),
  );
}

// ─── DetailGradientPlaceholder ────────────────────────────────────────────────

class DetailGradientPlaceholder extends StatelessWidget {
  final Mission mission;

  const DetailGradientPlaceholder({super.key, required this.mission});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          mission.categoryColor.withValues(alpha: 0.6),
          context.colors.background,
        ],
      ),
    ),
    child: Center(
      child: Icon(
        mission.categoryIcon,
        size: 72,
        color: Colors.white.withValues(alpha: 0.2),
      ),
    ),
  );
}

// ─── DetailMapPlaceholder ─────────────────────────────────────────────────────

class DetailMapPlaceholder extends StatelessWidget {
  final String address;

  const DetailMapPlaceholder({super.key, required this.address});

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Container(color: context.colors.surfaceAlt),
      const Positioned.fill(child: CustomPaint(painter: _MiniMapPainter())),
      const Center(child: DetailMiniMapPin()),
    ],
  );
}

// ─── DetailMiniMapPin ─────────────────────────────────────────────────────────

class DetailMiniMapPin extends StatelessWidget {
  const DetailMiniMapPin({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 26,
    height: 26,
    decoration: const BoxDecoration(
      color: AppColors.ink,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.10),
          blurRadius: 12,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Center(
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}

// ─── _MiniMapPainter ──────────────────────────────────────────────────────────

class _MiniMapPainter extends CustomPainter {
  const _MiniMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = AppColors.miniMapRoad
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final minorRoadPaint = Paint()
      ..color = AppColors.miniMapMinorRoad
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final waterPaint = Paint()
      ..color = AppColors.miniMapWater
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final river = Path()
      ..moveTo(size.width * 0.18, size.height * 0.16)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.28,
        size.width * 0.30,
        size.height * 0.62,
        size.width * 0.56,
        size.height * 0.72,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.78,
        size.width * 0.79,
        size.height * 0.62,
        size.width * 0.88,
        size.height * 0.86,
      );
    canvas.drawPath(river, waterPaint);

    for (final y in [0.22, 0.46, 0.69]) {
      canvas.drawLine(
        Offset(size.width * 0.08, size.height * y),
        Offset(size.width * 0.92, size.height * y),
        roadPaint,
      );
    }
    for (final x in [0.22, 0.48, 0.74]) {
      canvas.drawLine(
        Offset(size.width * x, size.height * 0.12),
        Offset(size.width * x, size.height * 0.88),
        minorRoadPaint,
      );
    }
    canvas.drawLine(
      Offset(size.width * 0.16, size.height * 0.82),
      Offset(size.width * 0.82, size.height * 0.18),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── DetailDualPillBar ────────────────────────────────────────────────────────

class DetailDualPillBar extends StatelessWidget {
  final IconData leftIcon;
  final String leftLabel;
  final VoidCallback onLeft;
  final IconData rightIcon;
  final String rightLabel;
  final VoidCallback onRight;

  const DetailDualPillBar({
    super.key,
    required this.leftIcon,
    required this.leftLabel,
    required this.onLeft,
    required this.rightIcon,
    required this.rightLabel,
    required this.onRight,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      child: Row(
        children: [
          Expanded(
            child: _Pill(icon: leftIcon, label: leftLabel, onTap: onLeft),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _Pill(icon: rightIcon, label: rightLabel, onTap: onRight),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Pill({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.missionButtonStyle.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
