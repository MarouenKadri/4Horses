import 'package:flutter/material.dart';
import 'package:fourhorses/app/widgets/app_category_filter_bar.dart';
import 'package:fourhorses/features/mission/data/models/service_category.dart';

class CategoriesRow extends StatelessWidget {
  const CategoriesRow({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      ...ServiceCategory.popular,
      ...ServiceCategory.ordered.where((category) => !category.isPopular),
    ].take(6).toList();

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          return AppCategoryChip(
            label: category.chipLabel,
            icon: category.icon,
            color: category.color,
          );
        },
      ),
    );
  }
}
