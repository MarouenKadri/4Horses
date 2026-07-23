import 'package:flutter/foundation.dart';

import '../../data/repositories/supabase_freelancer_public_profile_repository.dart';
import '../../domain/entities/freelancer_public_profile.dart';
import '../../domain/usecases/get_freelancer_public_profile.dart';

class FreelancerPublicProfileProvider extends ChangeNotifier {
  final GetFreelancerPublicProfile _getFreelancerPublicProfile;

  FreelancerPublicProfile? profile;
  bool isLoading = false;
  String? error;
  bool _disposed = false;

  FreelancerPublicProfileProvider({
    GetFreelancerPublicProfile? getFreelancerPublicProfile,
  }) : _getFreelancerPublicProfile =
           getFreelancerPublicProfile ??
           GetFreelancerPublicProfile(
             SupabaseFreelancerPublicProfileRepository(),
           );

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  Future<void> load(String? freelancerId) async {
    if (freelancerId == null || freelancerId.isEmpty) {
      profile = null;
      isLoading = false;
      error = null;
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      profile = await _getFreelancerPublicProfile(freelancerId);
    } catch (e) {
      debugPrint('FreelancerPublicProfileProvider load error: $e');
      error = 'Impossible de charger le profil';
      profile = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
