import '../entities/freelancer_public_profile.dart';
import '../repositories/freelancer_public_profile_repository.dart';

class GetFreelancerPublicProfile {
  final FreelancerPublicProfileRepository _repository;

  const GetFreelancerPublicProfile(this._repository);

  Future<FreelancerPublicProfile?> call(String freelancerId) {
    return _repository.getById(freelancerId);
  }
}
