// ─── Adresse ─────────────────────────────────────────────────────────────────

class MissionAddress {
  final String fullAddress;
  final String shortAddress;
  final String? distance;
  final double? latitude;
  final double? longitude;

  const MissionAddress({
    required this.fullAddress,
    required this.shortAddress,
    this.distance,
    this.latitude,
    this.longitude,
  });

  String get displayText =>
      distance != null ? '$shortAddress • $distance' : shortAddress;
}
