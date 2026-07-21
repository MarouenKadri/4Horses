class Freelancer {
  final String name;
  final String job;
  final double rating;
  final String subtitle;
  final String imageUrl;
  final bool isVerified;

  const Freelancer({
    required this.name,
    required this.job,
    required this.rating,
    required this.subtitle,
    required this.imageUrl,
    this.isVerified = false,
  });
}
