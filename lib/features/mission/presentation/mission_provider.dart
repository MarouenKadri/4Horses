import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/mission.dart';
import '../data/repositories/mission_repository.dart';
import '../data/repositories/supabase_mission_repository.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📦 Inkern - MissionProvider
/// ═══════════════════════════════════════════════════════════════════════════

class MissionProvider extends ChangeNotifier {
  final MissionRepository _repository;
  final _supabase = Supabase.instance.client;

  List<Mission> _clientMissions = [];
  List<Mission> _publicMissions = [];
  List<Mission> _freelancerMissions = [];
  bool isLoading = false;

  /// Missions pour lesquelles le freelancer a ouvert l'écran de suivi au
  /// moins une fois — sert uniquement à éteindre la bordure pulsante de la
  /// carte "Confirmées" (état en mémoire, pas persisté ni synchronisé).
  final Set<String> _trackingStartedMissionIds = {};

  bool hasTrackingStarted(String missionId) =>
      _trackingStartedMissionIds.contains(missionId);

  void markTrackingStarted(String missionId) {
    if (_trackingStartedMissionIds.add(missionId)) notifyListeners();
  }

  StreamSubscription<AuthState>? _authSub;
  RealtimeChannel? _channel;

  String? get _userId => _supabase.auth.currentUser?.id;

  MissionProvider({MissionRepository? repository})
    : _repository = repository ?? SupabaseMissionRepository() {
    _authSub = _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        _channel?.unsubscribe();
        _channel = null;
        _init();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _reset();
      }
    });
    if (_supabase.auth.currentUser != null) _init();
  }

  void _reset() {
    _channel?.unsubscribe();
    _channel = null;
    _clientMissions = [];
    _publicMissions = [];
    _freelancerMissions = [];
    isLoading = false;
    notifyListeners();
  }

  List<Mission> get clientMissions => List.unmodifiable(_clientMissions);
  List<Mission> get publicMissions => List.unmodifiable(_publicMissions);
  List<Mission> get freelancerMissions =>
      List.unmodifiable(_freelancerMissions);

  // ─── Init ─────────────────────────────────────────────────────────────────

  Future<void> _init() async {
    final userId = _userId;
    if (userId == null) return;
    await _load();
    _subscribeRealtime(userId);
  }

  // ─── Chargement initial ───────────────────────────────────────────────────

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();
    final results = await Future.wait([
      _repository.fetchClientMissions(),
      _repository.fetchPublicMissions(),
      _repository.fetchFreelancerMissions(),
    ]);
    _clientMissions = results[0];
    _publicMissions = results[1];
    _freelancerMissions = results[2];
    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _load();

  Future<List<Map<String, dynamic>>> fetchCandidates(String missionId) =>
      _repository.fetchCandidates(missionId);

  // ─── Publication d'une nouvelle mission ───────────────────────────────────

  Future<void> publishMission(Mission mission) async {
    final previous = List<Mission>.from(_clientMissions);
    _clientMissions = _prependUniqueById(_clientMissions, mission);
    notifyListeners();
    try {
      await _repository.saveMission(mission);
    } catch (e) {
      debugPrint('publishMission failed: $e');
      _clientMissions = previous;
      notifyListeners();
      rethrow;
    }
  }

  // ─── Mise à jour d'une mission ────────────────────────────────────────────

  Future<void> updateMission(Mission updated) async {
    final prevClient = List<Mission>.from(_clientMissions);
    final prevPublic = List<Mission>.from(_publicMissions);
    final prevFreelancer = List<Mission>.from(_freelancerMissions);
    _clientMissions = _clientMissions
        .map((m) => m.id == updated.id ? updated : m)
        .toList();
    _publicMissions = _publicMissions
        .map((m) => m.id == updated.id ? updated : m)
        .toList();
    _freelancerMissions = _freelancerMissions
        .map((m) => m.id == updated.id ? updated : m)
        .toList();
    notifyListeners();
    try {
      await _repository.updateMission(updated);
    } catch (e) {
      debugPrint('updateMission failed: $e');
      _clientMissions = prevClient;
      _publicMissions = prevPublic;
      _freelancerMissions = prevFreelancer;
      notifyListeners();
      rethrow;
    }
  }

  // ─── Mise à jour du statut ────────────────────────────────────────────────

  Future<void> updateMissionStatus(String id, MissionStatus newStatus) async {
    final prevClient = List<Mission>.from(_clientMissions);
    final prevPublic = List<Mission>.from(_publicMissions);
    final prevFreelancer = List<Mission>.from(_freelancerMissions);
    bool changed = false;

    _clientMissions = _clientMissions.map((m) {
      if (m.id != id || m.status == newStatus) return m;
      changed = true;
      return m.copyWith(status: newStatus);
    }).toList();

    _publicMissions = _publicMissions.map((m) {
      if (m.id != id || m.status == newStatus) return m;
      changed = true;
      return m.copyWith(status: newStatus);
    }).toList();

    _freelancerMissions = _freelancerMissions.map((m) {
      if (m.id != id || m.status == newStatus) return m;
      changed = true;
      return m.copyWith(status: newStatus);
    }).toList();

    if (!changed) return;
    notifyListeners();
    try {
      await _repository.updateStatus(id, newStatus);
    } catch (e) {
      debugPrint('updateMissionStatus failed: $e');
      _clientMissions = prevClient;
      _publicMissions = prevPublic;
      _freelancerMissions = prevFreelancer;
      notifyListeners();
      rethrow;
    }
  }

  // ─── Accepter un candidat ─────────────────────────────────────────────────

  Future<void> acceptCandidate(String missionId, PrestaInfo presta) async {
    final prevClient = List<Mission>.from(_clientMissions);
    final prevPublic = List<Mission>.from(_publicMissions);
    final prevFreelancer = List<Mission>.from(_freelancerMissions);
    bool changed = false;

    Mission update(Mission m) {
      if (m.id != missionId) return m;
      final p = m.assignedPresta;
      final samePresta = p != null && p.id == presta.id;
      final sameStatus = m.status == MissionStatus.confirmed;
      if (sameStatus && samePresta) return m;
      changed = true;
      return m.copyWith(
        status: MissionStatus.confirmed,
        assignedPresta: presta,
      );
    }

    _clientMissions = _clientMissions.map(update).toList();
    _publicMissions = _publicMissions.map(update).toList();
    _freelancerMissions = _freelancerMissions.map(update).toList();

    if (!changed) return;
    notifyListeners();
    final updated = _clientMissions.firstWhere(
      (m) => m.id == missionId,
      orElse: () => _publicMissions.firstWhere(
        (m) => m.id == missionId,
        orElse: () => _freelancerMissions.firstWhere((m) => m.id == missionId),
      ),
    );
    try {
      await _repository.updateMission(updated);
    } catch (e) {
      debugPrint('acceptCandidate failed: $e');
      _clientMissions = prevClient;
      _publicMissions = prevPublic;
      _freelancerMissions = prevFreelancer;
      notifyListeners();
      rethrow;
    }
  }

  // ─── Candidature freelancer ───────────────────────────────────────────────

  Future<void> submitProposal(
    Mission publicMission, {
    double price = 0,
    String message = '',
  }) async {
    final alreadyApplied = _freelancerMissions.any(
      (m) => m.id == publicMission.id,
    );
    if (alreadyApplied) return;

    final source = _publicMissions.firstWhere(
      (m) => m.id == publicMission.id,
      orElse: () => publicMission,
    );
    final nextCount = source.candidatesCount + 1;

    // 1. Ajouter à la liste "Postulées" du freelancer
    final applied = publicMission.copyWith(
      status: MissionStatus.candidateReceived,
      candidatesCount: nextCount,
    );
    _freelancerMissions = _prependUniqueById(_freelancerMissions, applied);

    // 2. Mettre à jour le statut + compteur dans le fil public
    _publicMissions = _publicMissions
        .map(
          (m) => m.id == publicMission.id
              ? m.copyWith(
                  status: MissionStatus.candidateReceived,
                  candidatesCount: nextCount,
                )
              : m,
        )
        .toList();

    // 3. Mettre à jour la liste client si la mission est présente
    //    (évite que le client soit bloqué sur waitingCandidates jusqu'au prochain refresh)
    _clientMissions = _clientMissions.map((m) {
      if (m.id != publicMission.id) return m;
      if (m.status != MissionStatus.waitingCandidates) return m;
      return m.copyWith(
        status: MissionStatus.candidateReceived,
        candidatesCount: nextCount,
      );
    }).toList();

    notifyListeners();
    try {
      await _repository.submitProposal(publicMission.id, price, message);
    } catch (e) {
      debugPrint('submitProposal failed: $e');
      // Rollback
      _freelancerMissions = _freelancerMissions
          .where((m) => m.id != publicMission.id)
          .toList();
      _publicMissions = _publicMissions
          .map(
            (m) => m.id == publicMission.id
                ? m.copyWith(
                    status: source.status,
                    candidatesCount: source.candidatesCount,
                  )
                : m,
          )
          .toList();
      _clientMissions = _clientMissions
          .map(
            (m) => m.id == publicMission.id
                ? m.copyWith(
                    status: source.status,
                    candidatesCount: source.candidatesCount,
                  )
                : m,
          )
          .toList();
      notifyListeners();
      rethrow;
    }
  }

  // ─── Retrait de candidature ───────────────────────────────────────────────

  Future<void> withdrawCandidacy(String missionId) async {
    final prevPublic = List<Mission>.from(_publicMissions);
    final prevFreelancer = List<Mission>.from(_freelancerMissions);

    // Optimistic: décrémente le compteur et retire de la liste freelancer
    _publicMissions = _publicMissions.map((m) {
      if (m.id != missionId) return m;
      return m.copyWith(candidatesCount: (m.candidatesCount - 1).clamp(0, 999));
    }).toList();
    _freelancerMissions = _freelancerMissions
        .where((m) => m.id != missionId)
        .toList();
    notifyListeners();

    try {
      await _repository.withdrawCandidacy(missionId);
      await _load();
    } catch (e) {
      debugPrint('withdrawCandidacy failed: $e');
      _publicMissions = prevPublic;
      _freelancerMissions = prevFreelancer;
      notifyListeners();
      rethrow;
    }
  }

  /// Le freelancer annule sa participation à une mission confirmée —
  /// elle repasse en recherche de prestataire côté client.
  Future<void> withdrawFromConfirmedMission(String missionId) async {
    final prevFreelancer = List<Mission>.from(_freelancerMissions);

    _freelancerMissions = _freelancerMissions
        .where((m) => m.id != missionId)
        .toList();
    notifyListeners();

    try {
      await _repository.withdrawFromConfirmedMission(missionId);
      await _load();
    } catch (e) {
      debugPrint('withdrawFromConfirmedMission failed: $e');
      _freelancerMissions = prevFreelancer;
      notifyListeners();
      rethrow;
    }
  }

  // ─── Brouillon ───────────────────────────────────────────────────────────

  Future<void> saveDraft(Mission draft) async {
    final prevClient = List<Mission>.from(_clientMissions);
    final exists = _clientMissions.any((m) => m.id == draft.id);
    if (exists) {
      _clientMissions = _clientMissions
          .map((m) => m.id == draft.id ? draft : m)
          .toList();
    } else {
      _clientMissions = [draft, ..._clientMissions];
    }
    notifyListeners();
    try {
      await _repository.saveMission(draft);
    } catch (e) {
      debugPrint('saveDraft failed: $e');
      _clientMissions = prevClient;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> publishDraft(Mission mission) async {
    final prevClient = List<Mission>.from(_clientMissions);
    final prevPublic = List<Mission>.from(_publicMissions);
    _clientMissions = _clientMissions
        .map((m) => m.id == mission.id ? mission : m)
        .toList();
    _publicMissions = _prependUniqueById(_publicMissions, mission);
    notifyListeners();
    try {
      await _repository.updateMission(mission);
    } catch (e) {
      debugPrint('publishDraft failed: $e');
      _clientMissions = prevClient;
      _publicMissions = prevPublic;
      notifyListeners();
      rethrow;
    }
  }

  /// Démarre la mission — le freelancer confirme être arrivé chez le client
  /// et l'intervention commence. Pas de code à échanger.
  Future<bool> startMission(String missionId) async {
    final mission = _findMissionById(missionId);
    if (mission == null) return false;
    if (mission.status != MissionStatus.confirmed &&
        mission.status != MissionStatus.onTheWay) {
      return false;
    }
    await updateMissionStatus(missionId, MissionStatus.inProgress);
    return true;
  }

  // ─── Realtime ─────────────────────────────────────────────────────────────

  void _subscribeRealtime(String userId) {
    _channel = _supabase
        .channel('missions_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'missions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'client_id',
            value: userId,
          ),
          callback: _onMissionUpdate,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'missions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'assigned_presta_id',
            value: userId,
          ),
          callback: _onMissionUpdate,
        )
        .subscribe();
  }

  void _onMissionUpdate(PostgresChangePayload payload) {
    try {
      final record = payload.newRecord;
      final id = record['id'] as String?;
      final statusStr = record['status'] as String?;
      if (id == null || statusStr == null) return;
      final newStatus = _statusFromDb(statusStr);
      _updateMissionStatusLocally(id, newStatus);
    } catch (e) {
      debugPrint('realtime mission update error: $e');
    }
  }

  void _updateMissionStatusLocally(String id, MissionStatus newStatus) {
    bool changed = false;

    _clientMissions = _clientMissions.map((m) {
      if (m.id != id || m.status == newStatus) return m;
      changed = true;
      return m.copyWith(status: newStatus);
    }).toList();

    _publicMissions = _publicMissions.map((m) {
      if (m.id != id || m.status == newStatus) return m;
      changed = true;
      return m.copyWith(status: newStatus);
    }).toList();

    _freelancerMissions = _freelancerMissions.map((m) {
      if (m.id != id || m.status == newStatus) return m;
      changed = true;
      return m.copyWith(status: newStatus);
    }).toList();

    if (changed) notifyListeners();
  }

  static MissionStatus _statusFromDb(String? s) => switch (s) {
    'draft' => MissionStatus.draft,
    'waiting_candidates' => MissionStatus.waitingCandidates,
    'candidate_received' => MissionStatus.candidateReceived,
    'presta_chosen' => MissionStatus.confirmed,
    'confirmed' => MissionStatus.confirmed,
    'on_the_way' => MissionStatus.onTheWay,
    'in_progress' => MissionStatus.inProgress,
    'completion_requested' => MissionStatus.completionRequested,
    'completed' => MissionStatus.completed,
    'payment_held' => MissionStatus.paymentHeld,
    'awaiting_release' => MissionStatus.awaitingRelease,
    'waiting_payment' => MissionStatus.awaitingRelease,
    'in_dispute' => MissionStatus.inDispute,
    'dispute' => MissionStatus.inDispute,
    'closed' => MissionStatus.closed,
    'cancelled' => MissionStatus.cancelled,
    'expired' => MissionStatus.expired,
    _ => MissionStatus.waitingCandidates,
  };

  // ─── Helpers ─────────────────────────────────────────────────────────────

  List<Mission> _prependUniqueById(List<Mission> source, Mission mission) {
    return [mission, ...source.where((m) => m.id != mission.id)];
  }

  Mission? _findMissionById(String id) {
    for (final mission in _clientMissions) {
      if (mission.id == id) return mission;
    }
    for (final mission in _freelancerMissions) {
      if (mission.id == id) return mission;
    }
    for (final mission in _publicMissions) {
      if (mission.id == id) return mission;
    }
    return null;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _channel?.unsubscribe();
    super.dispose();
  }
}
