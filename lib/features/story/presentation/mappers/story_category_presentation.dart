import 'package:flutter/material.dart';

import '../../shared/story_category_mapper.dart';

class StoryCategoryPresentation {
  const StoryCategoryPresentation._();

  static String label(String raw, {String fallback = 'Expertise'}) =>
      StoryCategoryMapper.label(raw, fallback: fallback);

  static IconData icon(
    String raw, {
    IconData fallback = Icons.home_repair_service_outlined,
  }) => StoryCategoryMapper.icon(raw, fallback: fallback);
}
