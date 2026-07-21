import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetGivenReviews {
  final ReviewRepository _repository;

  GetGivenReviews(this._repository);

  Future<List<Review>> call(String userId) {
    return _repository.getGivenReviews(userId);
  }
}
