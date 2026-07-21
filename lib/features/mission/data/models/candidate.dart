/// ─────────────────────────────────────────────────────────────
/// 📦 Inkern - Modèle Candidat (candidature à une mission)
/// ─────────────────────────────────────────────────────────────
library;

enum CandidateStatus { enAttente, accepte, refuse }

class Candidate {
  final String id;
  final String name;
  final String avatar;
  final double rating;
  final int reviewsCount;
  final String proposedPrice;
  final String message;
  final List<String> skills;
  final String responseTime;
  final int completedMissions;
  final bool isVerified;
  final String appliedAt;
  CandidateStatus status;

  Candidate({
    required this.id,
    required this.name,
    required this.avatar,
    required this.rating,
    required this.reviewsCount,
    required this.proposedPrice,
    required this.message,
    required this.skills,
    required this.responseTime,
    required this.completedMissions,
    required this.isVerified,
    required this.appliedAt,
    required this.status,
  });
}
