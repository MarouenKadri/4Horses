import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetReceivedReviews {
  final ReviewRepository _repository;

  GetReceivedReviews(this._repository);

  Future<List<Review>> call(String userId) {
    return _repository.getReceivedReviews(userId);
  }
}
