import '../../../../data/models/service_category.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📝 Inkern - Modèles pour la création de mission
/// ═══════════════════════════════════════════════════════════════════════════

/// Constantes de type de budget (chaînes utilisées dans le formulaire de création)
class CreateBudgetType {
  static const String hourly = 'hourly';
  static const String fixed = 'fixed';
  static const String quote = 'quote';
}

/// Labels des étapes du formulaire de création
const List<String> missionSteps = [
  'Service',
  'Date',
  'Heure',
  'Adresse',
  'Détails',
  'Budget',
  'Tarif',
  'Récapitulatif',
];

/// Liste des services pour le formulaire de création (issue de ServiceCategory)
List<Map<String, dynamic>> get missionServices => ServiceCategory.ordered
    .map(
      (cat) => <String, dynamic>{
        'id': cat.id,
        'name': cat.name,
        'icon': cat.icon,
        'color': cat.color,
        'subServices': cat.subServices,
      },
    )
    .toList();
