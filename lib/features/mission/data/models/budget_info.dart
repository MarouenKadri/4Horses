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

  /// Montant total pour les calculs de paiement et commissions
  /// - Horaire → amount × estimatedHours
  /// - Fixe    → amount
  double get totalAmount {
    if (type == BudgetType.hourly) return (amount ?? 0) * (estimatedHours ?? 1);
    return amount ?? 0;
  }

  double get averageAmount => totalAmount;
}
