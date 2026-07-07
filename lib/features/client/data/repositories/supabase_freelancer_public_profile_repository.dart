import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/freelancer_public_profile.dart';
import '../../domain/repositories/freelancer_public_profile_repository.dart';
import '../../../reviews/data/repositories/supabase_review_repository.dart';
import '../../../reviews/domain/entities/review.dart';
import '../../../profile/data/utils/service_categories_resolver.dart';

class SupabaseFreelancerPublicProfileRepository
    implements FreelancerPublicProfileRepository {
  final SupabaseClient _supabase;
  final SupabaseReviewRepository _reviewRepository;

  SupabaseFreelancerPublicProfileRepository({
    SupabaseClient? supabase,
    SupabaseReviewRepository? reviewRepository,
  }) : _supabase = supabase ?? Supabase.instance.client,
       _reviewRepository = reviewRepository ?? SupabaseReviewRepository();

  @override
  Future<FreelancerPublicProfile?> getById(String freelancerId) async {
    try {
      // Run profile fetch, reviews, and mission stats in parallel
      final results = await Future.wait([
        _supabase
                .from('profiles')
                .select(
                  'id, first_name, last_name, avatar_url, bio, address, hourly_rate, '
                  'is_verified, service_categories, rating, reviews_count, '
                  'completed_missions, response_time, created_at, latitude, '
                  'longitude, zone_radius',
                )
                .eq('id', freelancerId)
                .maybeSingle()
            as Future<dynamic>,
        _reviewRepository.getReceivedReviews(freelancerId),
        _fetchMissionStats(freelancerId),
      ]);

      final row = results[0] as Map<String, dynamic>?;
      if (row == null) return null;

      final reviews = results[1] as List<Review>;
      final missionStats = results[2] as _MissionStats;

      final resolvedServiceCategories = ServiceCategoriesResolver.resolve(
        rowValue: row['service_categories'],
        metadataValue: _serviceCategoriesFromCurrentUserMetadata(freelancerId),
      );

      final reviewsCount = _readInt(row['reviews_count']) ?? reviews.length;
      final rating = reviews.isEmpty
          ? (_readDouble(row['rating']) ?? 0)
          : reviews.fold<double>(
                  0,
                  (sum, r) => sum + r.satisfaction.toInt().toDouble(),
                ) /
                reviews.length;
      final missionsCount =
          _readInt(row['completed_missions']) ?? missionStats.finished;
      final cancellationRate = missionStats.total > 0
          ? missionStats.cancelled / missionStats.total
          : null;

      return FreelancerPublicProfile(
        id: row['id'] as String? ?? freelancerId,
        firstName: row['first_name'] as String? ?? '',
        lastName: row['last_name'] as String? ?? '',
        avatarUrl: row['avatar_url'] as String?,
        bio: row['bio'] as String?,
        address: row['address'] as String?,
        hourlyRate: _readDouble(row['hourly_rate']),
        isVerified: row['is_verified'] as bool? ?? false,
        serviceCategories: resolvedServiceCategories,
        rating: rating,
        reviewsCount: reviewsCount,
        missionsCount: missionsCount,
        createdAt: _readDateTime(row['created_at']),
        responseTime: row['response_time'] as String?,
        latitude: _readDouble(row['latitude']),
        longitude: _readDouble(row['longitude']),
        zoneRadius: _readDouble(row['zone_radius']),
        cancellationRate: cancellationRate,
      );
    } catch (e, st) {
      debugPrint('getById freelancer profile error: $e\n$st');
      return null;
    }
  }

  // Single query to compute both finished count and cancellation rate
  Future<_MissionStats> _fetchMissionStats(String freelancerId) async {
    try {
      final rows = await _supabase
          .from('missions')
          .select('status')
          .eq('assigned_presta_id', freelancerId);

      final list = (rows as List).cast<Map<String, dynamic>>();
      int finished = 0;
      int cancelled = 0;
      for (final row in list) {
        final status = row['status'] as String?;
        if (status == 'completed' ||
            status == 'waiting_payment' ||
            status == 'closed') {
          finished++;
        }
        if (status == 'cancelled') cancelled++;
      }
      return _MissionStats(
        total: list.length,
        finished: finished,
        cancelled: cancelled,
      );
    } catch (e) {
      debugPrint('fetchMissionStats error: $e');
      return const _MissionStats(total: 0, finished: 0, cancelled: 0);
    }
  }

  static double? _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  List<String> _serviceCategoriesFromCurrentUserMetadata(String freelancerId) {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null || currentUser.id != freelancerId) {
      return const [];
    }
    final metadata = currentUser.userMetadata;
    if (metadata == null) return const [];
    return ServiceCategoriesResolver.parse(metadata['service_categories']);
  }
}

class _MissionStats {
  final int total;
  final int finished;
  final int cancelled;

  const _MissionStats({
    required this.total,
    required this.finished,
    required this.cancelled,
  });
}
