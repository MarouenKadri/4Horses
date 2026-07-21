// ─── Budget ───────────────────────────────────────────────────────────────────

enum BudgetType { hourly, fixed, quote }

class BudgetInfo {
  final BudgetType type;

  /// Montant unique saisi par le client
  /// - Horaire : tarif €/h
  /// - Fixe    : montant total
  final double? amount;

  /// Durée estimée en heures (uniquement pour le type horaire)
  final double? estimatedHours;

  const BudgetInfo({required this.type, this.amount, this.estimatedHours});

  /// Texte affiché dans l'UI
  String get displayText {
    if (type == BudgetType.quote) return 'Sur devis';
    if (amount == null) return 'À définir';
    if (type == BudgetType.hourly) return '${amount!.toInt()} €/h';
    return '${amount!.toInt()} €';
  }

  /// Ligne budget complète pour les cards de liste
  /// (type · montant · heures estimées)
  String get detailedLabel {
    switch (type) {
      case BudgetType.hourly:
        final h = estimatedHours;
        return [
          'Tarif horaire',
          displayText,
          if (h != null && h > 0)
            '~${h.toStringAsFixed(h.truncateToDouble() == h ? 0 : 1)} h estimées',
        ].join(' · ');
      case BudgetType.fixed:
        return 'Budget fixe · $displayText';
      case BudgetType.quote:
        return 'Sur devis';
    }
  }

  /// Montant total pour les calculs de paiement et commissions
  /// - Horaire → amount × estimatedHours
  /// - Fixe    → amount
  double get totalAmount {
    if (type == BudgetType.hourly) return (amount ?? 0) * (estimatedHours ?? 1);
    return amount ?? 0;
  }

  double get averageAmount => totalAmount;
}
