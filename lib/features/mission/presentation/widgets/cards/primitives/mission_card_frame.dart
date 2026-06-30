import 'package:flutter/material.dart';

import '../../../../../../core/design/app_design_system.dart';

// ─── Primitive : Decorator ────────────────────────────────────────────────────
// Responsabilité unique : encadrement visuel partagé (shadow, radius, ripple)
// + contrat typographique partagé entre tous les variants.
// Les variants composent ce widget sans redéfinir les styles de texte.
// ─────────────────────────────────────────────────────────────────────────────

class MissionCardFrame extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double radius;
  final Color color;
  final List<BoxShadow> shadows;

  // ── Typographie ──────────────────────────────────────────────────────────────

  /// Titre principal — catégorie ou intitulé mission
  static const TextStyle titleStyle = TextStyle(
    fontSize: AppFontSize.h3,
    fontWeight: FontWeight.w600,
    color: AppColors.cardTitle,
    letterSpacing: -0.2,
    height: 1.25,
  );

  /// Sous-titre — intitulé secondaire ou description courte
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w400,
    color: AppColors.cardSubtitle,
    height: 1.45,
  );

  /// Label catégorie / meta compacte
  static const TextStyle metaStyle = TextStyle(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w500,
    color: AppColors.cardMeta,
    letterSpacing: 0.1,
  );

  /// Titre compact pour les cards petites (archive)
  static const TextStyle titleCompactStyle = TextStyle(
    fontSize: AppFontSize.lg,
    fontWeight: FontWeight.w600,
    color: AppColors.cardTitle,
    letterSpacing: -0.2,
  );

  /// Texte d'action / info courte semi-bold (ex: "Commence le...", badges)
  static const TextStyle captionStyle = TextStyle(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w600,
    color: AppColors.cardCaption,
  );

  // ── Spacing ──────────────────────────────────────────────────────────────────

  static const double paddingDefault = 18.0;
  static const double radiusDefault  = 24.0;
  static const double radiusLarge    = 26.0;
  static const double radiusSmall    = 20.0;

  // ── Shadows ──────────────────────────────────────────────────────────────────

  static const List<BoxShadow> defaultShadow = [
    BoxShadow(
      color: AppColors.blackAlpha04,
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> browseShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.04),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> noShadow = [];

  const MissionCardFrame({
    super.key,
    required this.child,
    required this.onTap,
    this.radius = 24,
    this.color = Colors.white,
    this.shadows = defaultShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}
