import '../entities/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReceivedReviews(String userId);
  Future<List<Review>> getGivenReviews(String userId);
  Future<List<Review>> getReceivedReviewsByReviewerType({
    required String revieweeId,
    required String reviewerUserType,
  });
  Future<List<Review>> getGivenReviewsByRevieweeType({
    required String reviewerId,
    required String revieweeUserType,
  });
  Future<String?> addReview({
    required String revieweeId,
    required String reviewerId,
    required String reviewerName,
    required String? reviewerAvatar,
    required int rating,
    required String comment,
    required String missionId,
    required String missionTitle,
  });
  Future<double> getAverageRating(String userId);
}
