import '../entities/freelancer_public_profile.dart';

abstract class FreelancerPublicProfileRepository {
  Future<FreelancerPublicProfile?> getById(String freelancerId);
}
