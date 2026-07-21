abstract class FreelancerCatalogRepository {
  Future<List<Map<String, dynamic>>> fetchFreelancers({
    required bool includeServiceCategories,
  });
}

class InMemoryFreelancerCatalogRepository
    implements FreelancerCatalogRepository {
  final List<Map<String, dynamic>> _rows;

  InMemoryFreelancerCatalogRepository([
    List<Map<String, dynamic>> rows = const [],
  ]) : _rows = rows;

  @override
  Future<List<Map<String, dynamic>>> fetchFreelancers({
    required bool includeServiceCategories,
  }) async {
    return _rows;
  }
}
