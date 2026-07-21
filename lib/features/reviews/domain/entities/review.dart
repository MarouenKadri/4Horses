import '../value_objects/satisfaction.dart';

class Review {
  final String id;
  final String revieweeId;
  final String reviewerId;
  final String reviewerName;
  final String reviewerAvatar;
  final Satisfaction satisfaction;
  final String comment;
  final String missionId;
  final String missionTitle;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.revieweeId,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerAvatar,
    required this.satisfaction,
    required this.comment,
    required this.missionId,
    required this.missionTitle,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'] as String,
    revieweeId: json['reviewee_id'] as String,
    reviewerId: json['reviewer_id'] as String,
    reviewerName: json['reviewer_name'] as String? ?? 'Anonyme',
    reviewerAvatar: json['reviewer_avatar'] as String? ?? '',
    satisfaction: Satisfaction.fromInt((json['rating'] as num).toInt()),
    comment: json['comment'] as String? ?? '',
    missionId: json['mission_id'] as String? ?? '',
    missionTitle: json['mission_title'] as String? ?? 'Mission',
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
