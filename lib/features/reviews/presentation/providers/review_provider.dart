import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/supabase_review_repository.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/get_given_reviews.dart';
import '../../domain/usecases/get_received_reviews.dart';

class ReviewProvider extends ChangeNotifier {
  final GetReceivedReviews _getReceivedReviews;
  final GetGivenReviews _getGivenReviews;
  final SupabaseReviewRepository _reviewRepository = SupabaseReviewRepository();
  final _supabase = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSub;

  List<Review> _receivedReviews = [];
  List<Review> _givenReviews = [];
  bool isLoading = false;
  String? error;

  /// [autoLoad] à false pour les providers isolés (profil public)
  /// qui ne doivent pas écouter l'auth globale.
  ReviewProvider({
    GetReceivedReviews? getReceivedReviews,
    GetGivenReviews? getGivenReviews,
    bool autoLoad = true,
  })  : _getReceivedReviews = getReceivedReviews ??
            GetReceivedReviews(SupabaseReviewRepository()),
        _getGivenReviews =
            getGivenReviews ?? GetGivenReviews(SupabaseReviewRepository()) {
    if (autoLoad) {
      _authSub = _supabase.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.signedIn ||
            data.event == AuthChangeEvent.signedOut) {
          _reset();
        }
      });
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  List<Review> get receivedReviews => List.unmodifiable(_receivedReviews);
  List<Review> get givenReviews => List.unmodifiable(_givenReviews);

  String? get _userId => _supabase.auth.currentUser?.id;

  void _reset() {
    _receivedReviews = [];
    _givenReviews = [];
    isLoading = false;
    error = null;
    notifyListeners();
  }

  Future<void> loadReviews() async {
    final userId = _userId;
    if (userId == null) {
      _reset();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _getReceivedReviews(userId),
        _getGivenReviews(userId),
      ]);
      _receivedReviews = results[0];
      _givenReviews = results[1];
    } catch (e) {
      debugPrint('ReviewProvider loadReviews error: $e');
      error = 'Impossible de charger les avis';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Charge uniquement les avis reçus pour un utilisateur public (profil tiers).
  Future<void> loadReceivedFor(String userId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _receivedReviews = await _getReceivedReviews(userId);
    } catch (e) {
      debugPrint('ReviewProvider loadReceivedFor error: $e');
      error = 'Impossible de charger les avis';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> submitReview({
    required String revieweeId,
    required String reviewerName,
    required String? reviewerAvatar,
    required int rating,
    required String missionId,
    required String missionTitle,
    String comment = '',
  }) async {
    final reviewerId = _userId;
    if (reviewerId == null) return 'Non connecté';
    return _reviewRepository.addReview(
      revieweeId: revieweeId,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      reviewerAvatar: reviewerAvatar,
      rating: rating,
      comment: comment,
      missionId: missionId,
      missionTitle: missionTitle,
    );
  }

  Future<void> loadReviewsForMode({required bool isFreelancer}) async {
    final userId = _userId;
    if (userId == null) {
      _reset();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final receivedFromType = isFreelancer ? 'client' : 'freelancer';
      final givenToType = isFreelancer ? 'client' : 'freelancer';
      final results = await Future.wait([
        _reviewRepository.getReceivedReviewsByReviewerType(
          revieweeId: userId,
          reviewerUserType: receivedFromType,
        ),
        _reviewRepository.getGivenReviewsByRevieweeType(
          reviewerId: userId,
          revieweeUserType: givenToType,
        ),
      ]);
      _receivedReviews = results[0];
      _givenReviews = results[1];
    } catch (e) {
      debugPrint('ReviewProvider loadReviewsForMode error: $e');
      error = 'Impossible de charger les avis';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
