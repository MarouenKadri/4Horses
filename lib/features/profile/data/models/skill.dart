import 'package:flutter/material.dart';
import '../../../../core/design/app_design_system.dart';

/// Modèle pour une compétence
class Skill {
  final String id;
  final String name;
  final String category;
  final IconData icon;
  int experienceYears;
  SkillLevel level;

  Skill({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    this.experienceYears = 0,
    this.level = SkillLevel.debutant,
  });
}

enum SkillLevel { debutant, intermediaire, confirme, expert }

extension SkillLevelExtension on SkillLevel {
  String get label {
    switch (this) {
      case SkillLevel.debutant:
        return 'Débutant';
      case SkillLevel.intermediaire:
        return 'Intermédiaire';
      case SkillLevel.confirme:
        return 'Confirmé';
      case SkillLevel.expert:
        return 'Expert';
    }
  }

  Color get color {
    switch (this) {
      case SkillLevel.debutant:
        return AppColors.info;
      case SkillLevel.intermediaire:
        return AppColors.warning;
      case SkillLevel.confirme:
        return AppColors.success;
      case SkillLevel.expert:
        return AppColors.primaryDark;
    }
  }

  double get progress {
    switch (this) {
      case SkillLevel.debutant:
        return 0.25;
      case SkillLevel.intermediaire:
        return 0.5;
      case SkillLevel.confirme:
        return 0.75;
      case SkillLevel.expert:
        return 1.0;
    }
  }
}

/// Catégories de compétences disponibles
class SkillCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> skills;

  const SkillCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.skills,
  });
}
