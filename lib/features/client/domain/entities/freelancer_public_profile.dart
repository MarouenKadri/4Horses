class FreelancerPublicProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? bio;
  final String? address;
  final double? hourlyRate;
  final bool isVerified;
  final List<String> serviceCategories;
  final double rating;
  final int reviewsCount;
  final int missionsCount;
  final DateTime? createdAt;
  final String? responseTime;
  final double? latitude;
  final double? longitude;
  final double? zoneRadius;
  final double? cancellationRate;

  const FreelancerPublicProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.bio,
    this.address,
    this.hourlyRate,
    this.isVerified = false,
    this.serviceCategories = const [],
    this.rating = 0,
    this.reviewsCount = 0,
    this.missionsCount = 0,
    this.createdAt,
    this.responseTime,
    this.latitude,
    this.longitude,
    this.zoneRadius,
    this.cancellationRate,
  });

  String get fullName => '$firstName $lastName'.trim();
}
