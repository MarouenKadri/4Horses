import 'package:flutter/material.dart';

import '../../../../core/design/app_design_system.dart';
import '../../domain/value_objects/satisfaction.dart';

extension SatisfactionUi on Satisfaction {
  String get label => switch (this) {
    Satisfaction.insatisfait => 'Insatisfait',
    Satisfaction.correct => 'Correct',
    Satisfaction.satisfait => 'Satisfait',
    Satisfaction.tresSatisfait => 'Tres satisfait',
  };

  IconData get icon => switch (this) {
    Satisfaction.insatisfait => Icons.sentiment_very_dissatisfied_rounded,
    Satisfaction.correct => Icons.sentiment_neutral_rounded,
    Satisfaction.satisfait => Icons.sentiment_satisfied_rounded,
    Satisfaction.tresSatisfait => Icons.sentiment_very_satisfied_rounded,
  };

  Color get color => switch (this) {
    Satisfaction.insatisfait => AppColors.errorStrong,
    Satisfaction.correct => AppColors.amberDark,
    Satisfaction.satisfait => AppColors.greenEmerald,
    Satisfaction.tresSatisfait => AppColors.indigoTW,
  };
}
