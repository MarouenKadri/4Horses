import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

class SupabaseReviewRepository implements ReviewRepository {
  final _supabase = Supabase.instance.client;

  static const String _clientRole = 'client';
  static const String _freelancerRole = 'freelancer';
  static const int _defaultLimit = 50;

  @override
  Future<List<Review>> getReceivedReviews(String userId) async {
    try {
      final rows = await _supabase
          .from('reviews')
          .select(
            'id, reviewee_id, reviewer_id, reviewer_name, reviewer_avatar, rating, comment, mission_id, mission_title, created_at',
          )
          .eq('reviewee_id', userId)
          .order('created_at', ascending: false)
          .limit(_defaultLimit);
      return (rows as List)
          .map((r) => Review.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getReceivedReviews error: $e');
      return [];
    }
  }

  @override
  Future<List<Review>> getGivenReviews(String userId) async {
    try {
      final rows = await _supabase
          .from('reviews')
          .select(
            'id, reviewee_id, reviewer_id, reviewer_name, reviewer_avatar, rating, comment, mission_id, mission_title, created_at',
          )
          .eq('reviewer_id', userId)
          .order('created_at', ascending: false)
          .limit(_defaultLimit);
      return (rows as List)
          .map((r) => Review.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getGivenReviews error: $e');
      return [];
    }
  }

  @override
  Future<List<Review>> getReceivedReviewsByReviewerType({
    required String revieweeId,
    required String reviewerUserType,
  }) async {
    try {
      final rows = await _supabase
          .from('reviews')
          .select(
            'id, reviewee_id, reviewer_id, reviewer_name, reviewer_avatar, rating, comment, mission_id, mission_title, created_at',
          )
          .eq('reviewee_id', revieweeId)
          .order('created_at', ascending: false)
          .limit(_defaultLimit);
      final reviews = (rows as List)
          .map((r) => Review.fromJson(r as Map<String, dynamic>))
          .toList();
      return _filterReviewsByUserType(
        reviews,
        userIdSelector: (review) => review.reviewerId,
        expectedUserType: reviewerUserType,
      );
    } catch (e) {
      debugPrint('getReceivedReviewsByReviewerType error: $e');
      return [];
    }
  }

  @override
  Future<List<Review>> getGivenReviewsByRevieweeType({
    required String reviewerId,
    required String revieweeUserType,
  }) async {
    try {
      final rows = await _supabase
          .from('reviews')
          .select(
            'id, reviewee_id, reviewer_id, reviewer_name, reviewer_avatar, rating, comment, mission_id, mission_title, created_at',
          )
          .eq('reviewer_id', reviewerId)
          .order('created_at', ascending: false)
          .limit(_defaultLimit);
      final reviews = (rows as List)
          .map((r) => Review.fromJson(r as Map<String, dynamic>))
          .toList();
      return _filterReviewsByUserType(
        reviews,
        userIdSelector: (review) => review.revieweeId,
        expectedUserType: revieweeUserType,
      );
    } catch (e) {
      debugPrint('getGivenReviewsByRevieweeType error: $e');
      return [];
    }
  }

  @override
  Future<String?> addReview({
    required String revieweeId,
    required String reviewerId,
    required String reviewerName,
    required String? reviewerAvatar,
    required int rating,
    required String comment,
    required String missionId,
    required String missionTitle,
  }) async {
    try {
      await _supabase.from('reviews').insert({
        'reviewee_id': revieweeId,
        'reviewer_id': reviewerId,
        'reviewer_name': reviewerName,
        'reviewer_avatar': reviewerAvatar ?? '',
        'rating': rating,
        'comment': comment,
        'mission_id': missionId,
        'mission_title': missionTitle,
      });
      return null;
    } catch (e) {
      debugPrint('addReview error: $e');
      return 'Erreur lors de l\'envoi de l\'avis';
    }
  }

  @override
  Future<double> getAverageRating(String userId) async {
    try {
      // Fetch up to 200 ratings — sufficient sample for any average computation
      final rows = await _supabase
          .from('reviews')
          .select('rating')
          .eq('reviewee_id', userId)
          .limit(200);
      final list = rows as List;
      if (list.isEmpty) return 0.0;
      final sum = list.fold<int>(
        0,
        (acc, r) =>
            acc + ((r as Map<String, dynamic>)['rating'] as num).toInt(),
      );
      return sum / list.length;
    } catch (e) {
      debugPrint('getAverageRating error: $e');
      return 0.0;
    }
  }

  Future<List<Review>> _filterReviewsByUserType(
    List<Review> reviews, {
    required String Function(Review review) userIdSelector,
    required String expectedUserType,
  }) async {
    if (reviews.isEmpty) return const [];
    final expected = _normalizeUserType(expectedUserType);
    if (expected.isEmpty) return const [];

    try {
      final roleByMissionAndUser = await _loadRolesFromMissions(
        reviews,
        userIdSelector: userIdSelector,
      );

      final unresolvedUserIds = reviews
          .where((review) {
            final missionId = review.missionId.trim();
            final missionKey = '$missionId|${userIdSelector(review)}';
            return roleByMissionAndUser[missionKey] == null;
          })
          .map(userIdSelector)
          .where((id) => id.trim().isNotEmpty)
          .toSet()
          .toList(growable: false);

      final roleByProfileId = await _loadRolesFromProfiles(unresolvedUserIds);

      final filtered = reviews
          .where((review) {
            final targetUserId = userIdSelector(review);
            final missionId = review.missionId.trim();
            final missionKey = '$missionId|$targetUserId';
            final missionRole = roleByMissionAndUser[missionKey];
            final resolvedRole = missionRole ?? roleByProfileId[targetUserId];
            return resolvedRole == expected;
          })
          .toList(growable: false);

      return filtered;
    } catch (e) {
      debugPrint('_filterReviewsByUserType error: $e');
      return const [];
    }
  }

  Future<Map<String, String>> _loadRolesFromMissions(
    List<Review> reviews, {
    required String Function(Review review) userIdSelector,
  }) async {
    final missionIds = reviews
        .map((review) => review.missionId.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (missionIds.isEmpty) return const {};

    try {
      final missions = await _supabase
          .from('missions')
          .select('id, client_id, assigned_presta_id')
          .inFilter('id', missionIds);

      final missionById = <String, Map<String, dynamic>>{};
      for (final row in (missions as List).whereType<Map>()) {
        final map = Map<String, dynamic>.from(row);
        final missionId = '${map['id']}'.trim();
        if (missionId.isNotEmpty) {
          missionById[missionId] = map;
        }
      }

      final roleByMissionAndUser = <String, String>{};
      for (final review in reviews) {
        final missionId = review.missionId.trim();
        final mission = missionById[missionId];
        if (mission == null) continue;

        final userId = userIdSelector(review);
        final role = _roleFromMissionForUser(mission, userId);
        if (role == null) continue;

        roleByMissionAndUser['$missionId|$userId'] = role;
      }

      return roleByMissionAndUser;
    } catch (e) {
      debugPrint('_loadRolesFromMissions error: $e');
      return const {};
    }
  }

  Future<Map<String, String>> _loadRolesFromProfiles(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return const {};

    try {
      final profiles = await _supabase
          .from('profiles')
          .select('id, user_type')
          .inFilter('id', userIds);

      final roleById = <String, String>{};
      for (final row in (profiles as List).whereType<Map>()) {
        final id = '${row['id']}'.trim();
        final role = _normalizeUserType('${row['user_type']}');
        if (id.isNotEmpty && role.isNotEmpty) {
          roleById[id] = role;
        }
      }
      return roleById;
    } catch (e) {
      debugPrint('_loadRolesFromProfiles error: $e');
      return const {};
    }
  }

  String? _roleFromMissionForUser(Map<String, dynamic> mission, String userId) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) return null;

    final clientId = '${mission['client_id']}'.trim();
    if (clientId.isNotEmpty && clientId == normalizedUserId) {
      return _clientRole;
    }

    final freelancerId = '${mission['assigned_presta_id']}'.trim();
    if (freelancerId.isNotEmpty && freelancerId == normalizedUserId) {
      return _freelancerRole;
    }

    return null;
  }

  String _normalizeUserType(String value) {
    final v = value.trim().toLowerCase();
    if (v.isEmpty) return '';

    if (v == _clientRole || v == 'customer') return _clientRole;
    if (v == _freelancerRole || v == 'provider' || v == 'presta') {
      return _freelancerRole;
    }
    return v;
  }
}
