import 'package:flutter/material.dart';
import '../../../../../../core/design/app_design_system.dart';

// ─── Primitive : Badge statut ─────────────────────────────────────────────────
// Responsabilité unique : afficher un badge coloré pour le statut d'une mission.
// Deux factory constructors couvrent les deux styles visuels de l'app :
//   • summary  → fond blanc + bordure (cards postulées/en cours/publiées)
//   • archive  → fond coloré selon statut (cards archives)
// ─────────────────────────────────────────────────────────────────────────────

class MissionStatusChip extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;
  final Border? border;
  final EdgeInsetsGeometry padding;
  final double letterSpacing;

  const MissionStatusChip({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
    this.border,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.letterSpacing = 0.35,
  });

  // Style summary : fond blanc + bordure subtile
  factory MissionStatusChip.summary(BuildContext context, {required String label}) {
    return MissionStatusChip(
      label: label,
      foreground: context.colors.textPrimary,
      background: context.colors.surface,
      border: Border.all(color: context.colors.border),
    );
  }

  // Style archive : fond coloré résolu depuis le label
  factory MissionStatusChip.archive(BuildContext context, {required String label}) {
    final style = _resolveArchiveStyle(context, label);
    return MissionStatusChip(
      label: label,
      foreground: style.foreground,
      background: style.background,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      letterSpacing: 0.2,
    );
  }

  static _ChipStyle _resolveArchiveStyle(BuildContext context, String label) {
    return switch (label) {
      'Annulee' => _ChipStyle(
          foreground: context.colors.error,
          background: context.colors.errorLight,
        ),
      'Paiement en attente' => _ChipStyle(
          foreground: context.colors.textSecondary,
          background: context.colors.surfaceAlt,
        ),
      _ => _ChipStyle(
          foreground: context.colors.textSecondary,
          background: context.colors.surfaceAlt,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        border: border,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppFontSize.xs,
          fontWeight: FontWeight.w600,
          color: foreground,
          letterSpacing: letterSpacing,
        ),
      ),
    );
  }
}

class _ChipStyle {
  final Color foreground;
  final Color background;
  const _ChipStyle({required this.foreground, required this.background});
}
