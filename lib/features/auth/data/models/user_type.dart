import 'package:flutter/material.dart';

enum UserType { client, freelancer }

extension UserTypeExtension on UserType {
  String get label {
    if (this == UserType.client) return 'Client';
    return 'Prestataire';
  }

  String get description {
    if (this == UserType.client) return 'Je cherche un prestataire';
    return 'Je propose mes services';
  }

  IconData get icon {
    if (this == UserType.client) return Icons.search_rounded;
    return Icons.work_rounded;
  }

  int get totalSteps {
    if (this == UserType.client) return 4;
    return 6;
  }
}
