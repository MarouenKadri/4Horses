class ServiceCategoriesResolver {
  const ServiceCategoriesResolver._();

  static List<String> parse(dynamic value) {
    if (value is List) {
      return value
          .map((entry) => '$entry'.trim())
          .where((entry) => entry.isNotEmpty)
          .toList(growable: false);
    }

    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((entry) => entry.trim())
          .where((entry) => entry.isNotEmpty)
          .toList(growable: false);
    }

    return const [];
  }

  static List<String> resolve({
    required dynamic rowValue,
    required dynamic metadataValue,
  }) {
    final rowValues = parse(rowValue);
    if (rowValues.isNotEmpty) return rowValues;
    return parse(metadataValue);
  }
}
