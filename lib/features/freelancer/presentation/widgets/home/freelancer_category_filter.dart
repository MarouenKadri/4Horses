import 'package:flutter/material.dart';

import 'package:fourhorses/app/widgets/app_category_filter_bar.dart';
import 'package:fourhorses/app/widgets/service_category_filter_items.dart';
import 'package:fourhorses/core/design/app_design_system.dart';

/// Barre de filtres par catégorie (scroll horizontal).
class FreelancerCategoryFilter extends StatelessWidget {
  final String? selectedCategoryId;
  final ValueChanged<String?> onSelect;

  const FreelancerCategoryFilter({
    super.key,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surface,
      child: AppCategoryFilterBar(
        items: ServiceCategoryFilterItems.build(context),
        selectedId: selectedCategoryId,
        onSelect: onSelect,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        spacing: 10,
        height: 50,
      ),
    );
  }
}
