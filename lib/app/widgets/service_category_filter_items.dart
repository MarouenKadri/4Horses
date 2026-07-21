import 'package:flutter/material.dart';

import '../../features/mission/data/models/service_category.dart';
import 'app_category_filter_bar.dart';
import '../../core/design/app_design_system.dart';

class ServiceCategoryFilterItems {
  const ServiceCategoryFilterItems._();

  static List<AppCategoryItem> build(BuildContext context, {bool includeAll = true}) {
    final items = <AppCategoryItem>[
      if (includeAll)
        AppCategoryItem(
          id: null,
          label: ServiceCategory.allFilterLabel,
          icon: Icons.apps_outlined,
          color: context.colors.textSecondary,
        ),
      ...ServiceCategory.ordered.map(
        (category) => AppCategoryItem(
          id: category.id,
          label: category.chipLabel,
          icon: category.icon,
          color: category.color,
        ),
      ),
    ];
    return List<AppCategoryItem>.unmodifiable(items);
  }
}
