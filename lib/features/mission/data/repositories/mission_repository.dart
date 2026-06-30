import '../models/mission.dart';
import '../fixtures/mission_demo_data.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📦 Inkern - MissionRepository (interface async)
/// ═══════════════════════════════════════════════════════════════════════════

abstract class MissionRepository {
  Future<List<Mission>> fetchClientMissions();
  Future<List<Mission>> fetchPublicMissions();
  Future<List<Mission>> fetchFreelancerMissions();
  Future<void> saveMission(Mission mission);
  Future<void> updateMission(Mission mission);
  Future<void> updateStatus(String id, MissionStatus status);
  Future<void> submitProposal(String missionId, double price, String message);
  Future<List<Map<String, dynamic>>> fetchCandidates(String missionId);
  Future<void> withdrawCandidacy(String missionId);
}

/// ─── Implémentation In-Memory (données de démo) ───────────────────────────

class InMemoryMissionRepository implements MissionRepository {
  const InMemoryMissionRepository();

  @override
  Future<List<Mission>> fetchClientMissions() async => [
    ...MissionDemoData.getClientMissions(),
    ...MissionDemoData.getCompletedMissions(),
    ...MissionDemoData.getDraftMissions(),
  ];

  @override
  Future<List<Mission>> fetchPublicMissions() async =>
      MissionDemoData.getAvailableMissions();

  @override
  Future<List<Mission>> fetchFreelancerMissions() async =>
      MissionDemoData.getFreelancerMissions();

  @override
  Future<void> saveMission(Mission mission) async {}

  @override
  Future<void> updateMission(Mission mission) async {}

  @override
  Future<void> updateStatus(String id, MissionStatus status) async {}

  @override
  Future<void> submitProposal(String missionId, double price, String message) async {}

  @override
  Future<List<Map<String, dynamic>>> fetchCandidates(String missionId) async => [];

  @override
  Future<void> withdrawCandidacy(String missionId) async {}
}
