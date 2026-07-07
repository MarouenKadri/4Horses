import 'package:flutter/material.dart';
import '../../../../core/design/app_design_system.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🏷️ Inkern - Catégories de Services
/// ═══════════════════════════════════════════════════════════════════════════

class ServiceCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int sortOrder;
  final bool isPopular;
  final String description;
  final List<String> subServices;
  final List<String> popularTags;
  final List<String> aliases;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.sortOrder = 999,
    this.isPopular = false,
    this.description = '',
    this.subServices = const [],
    this.popularTags = const [],
    this.aliases = const [],
  });

  static const String allFilterLabel = 'Toutes';

  static const List<ServiceCategory> all = [
    menage,
    jardinage,
    bricolage,
    plomberie,
    electricite,
    maconnerie,
    mecanique,
    gardeEnfant,
    aidePersonnesAgees,
    demenagement,
    petsitting,
    cours,
    autre,
  ];

  static const ServiceCategory menage = ServiceCategory(
    id: 'menage',
    name: 'Ménage',
    icon: Icons.cleaning_services_rounded,
    color: AppColors.categoryMenage,
    sortOrder: 1,
    isPopular: true,
    description: 'Services de nettoyage et entretien de la maison',
    subServices: [
      'Ménage complet',
      'Nettoyage cuisine',
      'Nettoyage salle de bain',
      'Vitres',
      'Repassage',
      'Nettoyage fin de chantier',
      'Nettoyage après déménagement',
    ],
    popularTags: ['régulier', 'ponctuel', 'produits fournis', 'écologique'],
    aliases: ['nettoyage', 'housekeeping'],
  );

  static const ServiceCategory jardinage = ServiceCategory(
    id: 'jardinage',
    name: 'Jardinage',
    icon: Icons.grass_rounded,
    color: AppColors.categoryJardinage,
    sortOrder: 2,
    isPopular: true,
    description: 'Entretien de jardins, terrasses et espaces verts',
    subServices: [
      'Tonte pelouse',
      'Taille haies',
      'Désherbage',
      'Plantation',
      'Élagage',
      'Arrosage',
      'Entretien potager',
      'Évacuation déchets verts',
    ],
    popularTags: [
      'petit jardin',
      'grand terrain',
      'outils fournis',
      'régulier',
    ],
    aliases: ['jardin', 'espaces verts'],
  );

  static const ServiceCategory bricolage = ServiceCategory(
    id: 'bricolage',
    name: 'Bricolage',
    icon: Icons.handyman_rounded,
    color: AppColors.categoryBricolage,
    sortOrder: 3,
    isPopular: true,
    description: 'Petits travaux et réparations diverses',
    subServices: [
      'Montage meubles',
      'Petites réparations',
      'Peinture',
      'Pose étagères',
      'Fixations murales',
      'Pose rideaux/stores',
      'Petite menuiserie',
    ],
    popularTags: ['IKEA', 'rapide', 'outillage complet'],
    aliases: ['brico', 'petits travaux', 'handyman'],
  );

  static const ServiceCategory plomberie = ServiceCategory(
    id: 'plomberie',
    name: 'Plomberie',
    icon: Icons.plumbing_rounded,
    color: AppColors.categoryPlomberie,
    sortOrder: 4,
    isPopular: true,
    description: 'Réparations et installations sanitaires',
    subServices: [
      'Fuite d\'eau',
      'Débouchage',
      'Installation robinet',
      'Réparation WC',
      'Chauffe-eau',
      'Raccordement',
      'Remplacement joints',
    ],
    popularTags: ['urgence', 'devis gratuit', 'garantie'],
    aliases: ['plombier'],
  );

  static const ServiceCategory electricite = ServiceCategory(
    id: 'electricite',
    name: 'Électricité',
    icon: Icons.electrical_services_rounded,
    color: AppColors.categoryElectricite,
    sortOrder: 5,
    isPopular: true,
    description: 'Installations et dépannages électriques',
    subServices: [
      'Prise électrique',
      'Interrupteur',
      'Luminaire',
      'Dépannage',
      'Tableau électrique',
      'Mise aux normes',
      'Installation domotique',
      'Passage de câbles',
    ],
    popularTags: ['certifié', 'mise aux normes', 'urgence'],
    aliases: ['électricité', 'electricien', 'elec'],
  );

  static const ServiceCategory maconnerie = ServiceCategory(
    id: 'maconnerie',
    name: 'Maçonnerie',
    icon: Icons.foundation_rounded,
    color: AppColors.categoryMaconnerie,
    sortOrder: 6,
    isPopular: true,
    description: 'Travaux de maçonnerie, carrelage et revêtements',
    subServices: [
      'Carrelage',
      'Dallage',
      'Pose de parquet',
      'Enduit / crépi',
      'Petite maçonnerie',
      'Réparation mur / sol',
      'Ragréage',
      'Montage cloison',
    ],
    popularTags: ['intérieur', 'extérieur', 'rénovation', 'neuf'],
    aliases: ['maçon', 'carrelage', 'travaux'],
  );

  static const ServiceCategory mecanique = ServiceCategory(
    id: 'mecanique',
    name: 'Mécanique',
    icon: Icons.build_rounded,
    color: AppColors.categoryMecanique,
    sortOrder: 7,
    isPopular: true,
    description: 'Entretien et réparation automobile',
    subServices: [
      'Vidange',
      'Changement de pneus',
      'Freins',
      'Batterie',
      'Courroie de distribution',
      'Diagnostic électronique',
      'Révision complète',
      'Carrosserie mineure',
    ],
    popularTags: ['à domicile', 'toutes marques', 'urgence', 'devis gratuit'],
    aliases: ['mécanicien', 'voiture', 'auto', 'garage'],
  );

  static const ServiceCategory gardeEnfant = ServiceCategory(
    id: 'garde_enfant',
    name: 'Garde enfant',
    icon: Icons.child_care_rounded,
    color: AppColors.categoryGardeEnfant,
    sortOrder: 8,
    isPopular: true,
    description: 'Garde d\'enfants à domicile ou en sortie',
    subServices: [
      'Garde à domicile',
      'Sortie d\'école',
      'Garde le soir',
      'Garde le week-end',
      'Baby-sitting ponctuel',
      'Aide aux devoirs',
      'Activités enfants',
    ],
    popularTags: ['0-3 ans', '3-6 ans', '6-12 ans', 'diplômé', 'expérimenté'],
    aliases: ['baby-sitting', 'babysitting', 'garde enfants', 'nounou'],
  );

  static const ServiceCategory aidePersonnesAgees = ServiceCategory(
    id: 'aide_personnes_agees',
    name: 'Aide séniors',
    icon: Icons.elderly_rounded,
    color: AppColors.categoryAidePersonnesAgees,
    sortOrder: 9,
    isPopular: true,
    description: 'Accompagnement et aide à domicile pour personnes âgées',
    subServices: [
      'Aide à la toilette',
      'Préparation des repas',
      'Courses',
      'Accompagnement médical',
      'Compagnie / visite',
      'Aide au ménage',
      'Aide administrative',
    ],
    popularTags: ['domicile', 'régulier', 'ponctuel', 'diplômé'],
    aliases: ['senior', 'personnes âgées', 'aide domicile', 'auxiliaire vie'],
  );

  static const ServiceCategory demenagement = ServiceCategory(
    id: 'demenagement',
    name: 'Déménagement',
    icon: Icons.local_shipping_rounded,
    color: AppColors.categoryDemenagement,
    sortOrder: 10,
    description: 'Aide au déménagement et transport',
    subServices: [
      'Aide déménagement',
      'Transport meubles',
      'Emballage',
      'Montage/démontage',
      'Portage',
      'Location camion avec chauffeur',
    ],
    popularTags: ['petit volume', 'grand volume', 'avec véhicule', 'muscles'],
    aliases: ['transport', 'déménagement'],
  );

  static const ServiceCategory petsitting = ServiceCategory(
    id: 'petsitting',
    name: 'Pet-sitting',
    icon: Icons.pets_rounded,
    color: AppColors.categoryPetsitting,
    sortOrder: 11,
    description: 'Garde et promenade d\'animaux de compagnie',
    subServices: [
      'Garde chien',
      'Garde chat',
      'Promenade',
      'Visite à domicile',
      'Garde NAC',
      'Garde longue durée',
    ],
    popularTags: ['expérimenté', 'à domicile', 'chez le pet-sitter'],
    aliases: ['animaux', 'pet sitting', 'garde animaux'],
  );

  static const ServiceCategory autre = ServiceCategory(
    id: 'autre',
    name: 'Autre',
    icon: Icons.more_horiz_rounded,
    color: AppColors.categoryAutre,
    sortOrder: 13,
    description: 'Tout autre service non listé',
    subServices: ['Service à définir'],
    aliases: ['other', 'divers', 'autre chose'],
  );

  static const ServiceCategory cours = ServiceCategory(
    id: 'cours',
    name: 'Cours',
    icon: Icons.school_rounded,
    color: AppColors.categoryCours,
    sortOrder: 12,
    description: 'Cours particuliers et soutien scolaire',
    subServices: [
      'Mathématiques',
      'Français',
      'Anglais',
      'Physique-Chimie',
      'SVT',
      'Musique',
      'Informatique',
      'Langues étrangères',
    ],
    popularTags: ['primaire', 'collège', 'lycée', 'supérieur', 'adulte'],
    aliases: ['soutien scolaire', 'prof'],
  );

  static ServiceCategory? findById(String id) {
    final normalized = _normalizeLookup(id);
    for (final cat in all) {
      if (_normalizeLookup(cat.id) == normalized) return cat;
    }
    return null;
  }

  static ServiceCategory? findByName(String name) {
    final normalized = _normalizeLookup(name);
    for (final cat in all) {
      if (_normalizeLookup(cat.name) == normalized) return cat;
      if (_normalizeLookup(cat.id) == normalized) return cat;
      if (cat.aliases.any((alias) => _normalizeLookup(alias) == normalized)) {
        return cat;
      }
    }
    return null;
  }

  static ServiceCategory? resolve(dynamic raw) {
    if (raw == null) return null;
    final value = '$raw'.trim();
    if (value.isEmpty) return null;
    return findById(value) ?? findByName(value);
  }

  static List<ServiceCategory> get ordered {
    final items = [...all];
    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return items;
  }

  static List<String> resolveNames(dynamic rawValue) {
    final names = <String>[];
    final seen = <String>{};
    for (final raw in _readRawList(rawValue)) {
      final category = resolve(raw);
      final fallback = raw.trim();
      final label = category?.name ?? fallback;
      if (label.isEmpty) continue;
      final normalized = _normalizeLookup(label);
      if (normalized.isEmpty || seen.contains(normalized)) continue;
      seen.add(normalized);
      names.add(label);
    }
    return names;
  }

  static List<String> resolveIds(dynamic rawValue) {
    final ids = <String>[];
    final seen = <String>{};
    for (final raw in _readRawList(rawValue)) {
      final category = resolve(raw);
      if (category == null) continue;
      if (seen.add(category.id)) ids.add(category.id);
    }
    return ids;
  }

  static List<ServiceCategory> search(String query) {
    final lowerQuery = _normalizeLookup(query);
    return all.where((cat) {
      if (_normalizeLookup(cat.name).contains(lowerQuery)) return true;
      if (_normalizeLookup(cat.description).contains(lowerQuery)) return true;
      if (cat.subServices.any(
        (s) => _normalizeLookup(s).contains(lowerQuery),
      )) {
        return true;
      }
      if (cat.popularTags.any(
        (tag) => _normalizeLookup(tag).contains(lowerQuery),
      )) {
        return true;
      }
      return cat.aliases.any(
        (alias) => _normalizeLookup(alias).contains(lowerQuery),
      );
    }).toList();
  }

  static List<ServiceCategory> get popular =>
      ordered.where((category) => category.isPopular).toList(growable: false);

  static Map<String, List<ServiceCategory>> get byColorGroup => {
    'green': [menage, jardinage],
    'orange': [bricolage, electricite],
    'blue': [plomberie, cours],
    'purple': [demenagement, petsitting],
    'brown': [maconnerie],
    'grey': [mecanique],
  };

  static List<String> _readRawList(dynamic rawValue) {
    if (rawValue is List) {
      return rawValue
          .map((entry) => '$entry'.trim())
          .where((entry) => entry.isNotEmpty)
          .toList();
    }
    if (rawValue is String && rawValue.trim().isNotEmpty) {
      return rawValue
          .split(',')
          .map((entry) => entry.trim())
          .where((entry) => entry.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static String _normalizeLookup(String raw) {
    var value = raw.trim().toLowerCase();
    if (value.isEmpty) return value;
    const replacements = <String, String>{
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'á': 'a',
      'ã': 'a',
      'ç': 'c',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'ì': 'i',
      'í': 'i',
      'ô': 'o',
      'ö': 'o',
      'ò': 'o',
      'ó': 'o',
      'õ': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ú': 'u',
      'ÿ': 'y',
      'œ': 'oe',
      'æ': 'ae',
    };
    replacements.forEach((from, to) {
      value = value.replaceAll(from, to);
    });
    return value.replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}

extension ServiceCategoryX on ServiceCategory {
  Color themedColor(BuildContext context) =>
      context.isAppTheme ? context.colors.primary : color;

  String get chipLabel => id == 'bricolage' ? 'Brico' : name;

  Color get lightColor => color.withValues(alpha: 0.1);
  Color get mediumColor => color.withValues(alpha: 0.3);
}
