import 'package:flutter/material.dart';

enum ServiceType {
  menage,
  jardinage,
  bricolage,
  gardeEnfants,
  electricite,
  plomberie,
  peinture,
  demenagement,
  coursesLivraison,
  animaux,
  informatique,
  couture,
  cuisine,
  autre,
}

extension ServiceTypeExtension on ServiceType {
  String get label {
    switch (this) {
      case ServiceType.menage:
        return 'Ménage';
      case ServiceType.jardinage:
        return 'Jardinage';
      case ServiceType.bricolage:
        return 'Bricolage';
      case ServiceType.gardeEnfants:
        return "Garde d'enfants";
      case ServiceType.electricite:
        return 'Électricité';
      case ServiceType.plomberie:
        return 'Plomberie';
      case ServiceType.peinture:
        return 'Peinture';
      case ServiceType.demenagement:
        return 'Déménagement';
      case ServiceType.coursesLivraison:
        return 'Courses & Livraison';
      case ServiceType.animaux:
        return 'Garde d\'animaux';
      case ServiceType.informatique:
        return 'Informatique';
      case ServiceType.couture:
        return 'Couture';
      case ServiceType.cuisine:
        return 'Cuisine';
      case ServiceType.autre:
        return 'Autre';
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceType.menage:
        return Icons.cleaning_services_rounded;
      case ServiceType.jardinage:
        return Icons.grass_rounded;
      case ServiceType.bricolage:
        return Icons.handyman_rounded;
      case ServiceType.gardeEnfants:
        return Icons.child_care_rounded;
      case ServiceType.electricite:
        return Icons.bolt_rounded;
      case ServiceType.plomberie:
        return Icons.plumbing_rounded;
      case ServiceType.peinture:
        return Icons.format_paint_rounded;
      case ServiceType.demenagement:
        return Icons.local_shipping_rounded;
      case ServiceType.coursesLivraison:
        return Icons.shopping_cart_rounded;
      case ServiceType.animaux:
        return Icons.pets_rounded;
      case ServiceType.informatique:
        return Icons.computer_rounded;
      case ServiceType.couture:
        return Icons.content_cut_rounded;
      case ServiceType.cuisine:
        return Icons.restaurant_rounded;
      case ServiceType.autre:
        return Icons.add_circle_outline_rounded;
    }
  }
}
