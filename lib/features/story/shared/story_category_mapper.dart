import 'package:flutter/material.dart';

import '../../mission/data/models/service_category.dart';

class StoryCategoryMapper {
  const StoryCategoryMapper._();

  static String label(String raw, {String fallback = 'Expertise'}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return fallback;

    final category = ServiceCategory.resolve(trimmed);
    if (category != null) return category.name;

    var value = trimmed.replaceAll('_', ' ').replaceAll('-', ' ');
    value = value.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (value.isEmpty) return fallback;
    return value[0].toUpperCase() + value.substring(1);
  }

  static IconData icon(
    String raw, {
    IconData fallback = Icons.home_repair_service_outlined,
  }) {
    final category = ServiceCategory.resolve(raw);
    if (category != null) return category.icon;

    final normalized = _normalize(raw);
    if (normalized.contains('jardin')) return Icons.yard_outlined;
    if (normalized.contains('plomb')) return Icons.plumbing_outlined;
    if (normalized.contains('menage') || normalized.contains('nettoy')) {
      return Icons.cleaning_services_outlined;
    }
    if (normalized.contains('elec')) return Icons.electrical_services_outlined;
    return fallback;
  }

  static String _normalize(String raw) {
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
