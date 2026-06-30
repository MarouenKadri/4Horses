import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mission.dart';
import 'mission_repository.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📦 Inkern - SupabaseMissionRepository
/// ═══════════════════════════════════════════════════════════════════════════

class SupabaseMissionRepository implements MissionRepository {
  final _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  // Only fetch profile columns actually used by _clientFromJson / _prestaFromJson
  static const _select =
      '*, '
      'client:profiles!client_id(id, first_name, last_name, avatar_url, rating, completed_missions, is_verified, phone), '
      'presta:profiles!assigned_presta_id(id, first_name, last_name, avatar_url, rating, reviews_count, completed_missions, is_verified, phone)';

  // ─── Fetch ───────────────────────────────────────────────────────────────

  @override
  Future<List<Mission>> fetchClientMissions() async {
    if (_userId == null) return [];
    try {
      final data = await _supabase
          .from('missions')
          .select(_select)
          .eq('client_id', _userId!)
          .order('created_at', ascending: false)
          .limit(100);
      return (data as List)
          .map<Mission>((e) => _fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      debugPrint('fetchClientMissions error: $e\n$st');
      return [];
    }
  }

  @override
  Future<List<Mission>> fetchPublicMissions() async {
    try {
      var query = _supabase
          .from('missions')
          .select(_select)
          .eq('is_public', true);

      if (_userId != null) {
        query = query.neq('client_id', _userId!);
      }

      final data = await query.order('created_at', ascending: false).limit(100);
      debugPrint('fetchPublicMissions: ${(data as List).length} missions');
      return data.map<Mission>((e) => _fromJson(e)).toList();
    } catch (e, st) {
      debugPrint('fetchPublicMissions error: $e\n$st');
      return [];
    }
  }

  @override
  Future<List<Mission>> fetchFreelancerMissions() async {
    if (_userId == null) return [];
    try {
      final candidateRows = await _supabase
          .from('candidates')
          .select('mission_id')
          .eq('freelancer_id', _userId!);

      final candidateMissionIds = (candidateRows as List)
          .map((r) => r['mission_id'] as String)
          .toList();

      debugPrint(
        'fetchFreelancerMissions: ${candidateMissionIds.length} candidatures',
      );

      final List<dynamic> data;
      if (candidateMissionIds.isEmpty) {
        data = await _supabase
            .from('missions')
            .select(_select)
            .eq('assigned_presta_id', _userId!)
            .order('created_at', ascending: false)
            .limit(100);
      } else {
        data = await _supabase
            .from('missions')
            .select(_select)
            .or(
              'assigned_presta_id.eq.$_userId,id.in.(${candidateMissionIds.join(',')})',
            )
            .order('created_at', ascending: false)
            .limit(100);
      }

      debugPrint('fetchFreelancerMissions: ${data.length} missions');
      return data
          .map<Mission>((e) => _fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      debugPrint('fetchFreelancerMissions error: $e\n$st');
      return [];
    }
  }

  // ─── Write ───────────────────────────────────────────────────────────────

  @override
  Future<void> saveMission(Mission mission) async {
    final clientId = _userId;
    if (clientId == null) {
      throw StateError('saveMission: user not authenticated');
    }
    final json = _toJson(mission, clientId);
    debugPrint('saveMission payload: $json');
    try {
      await _supabase.from('missions').upsert(json);
      debugPrint('saveMission OK: ${mission.id}');
    } catch (e, st) {
      debugPrint('saveMission ERROR: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> updateMission(Mission mission) async {
    final clientId = _userId;
    if (clientId == null) {
      throw StateError('updateMission: user not authenticated');
    }
    final json = _toJson(mission, clientId);
    debugPrint('updateMission payload: $json');
    try {
      await _supabase.from('missions').upsert(json);
      debugPrint('updateMission OK: ${mission.id}');
    } catch (e, st) {
      debugPrint('updateMission ERROR: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> updateStatus(String id, MissionStatus status) async {
    try {
      await _supabase
          .from('missions')
          .update({'status': _statusToDb(status)})
          .eq('id', id);
    } catch (e) {
      debugPrint('updateStatus error: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchCandidates(String missionId) async {
    try {
      // Step 1: fetch candidates
      dynamic raw;
      try {
        raw = await _supabase
            .from('candidates')
            .select('*')
            .eq('mission_id', missionId)
            .order('applied_at', ascending: false);
      } catch (e1, st1) {
        debugPrint(
          'fetchCandidates order applied_at failed, retry with created_at: $e1\n$st1',
        );
        try {
          raw = await _supabase
              .from('candidates')
              .select('*')
              .eq('mission_id', missionId)
              .order('created_at', ascending: false);
        } catch (e2, st2) {
          debugPrint(
            'fetchCandidates order created_at failed, retry without order: $e2\n$st2',
          );
          raw = await _supabase
              .from('candidates')
              .select('*')
              .eq('mission_id', missionId);
        }
      }

      final data = (raw as List)
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();

      debugPrint('fetchCandidates: ${data.length} rows for mission $missionId');

      if (data.isEmpty) return [];

      // Step 2: fetch freelancer profiles separately (avoids FK name issues)
      final freelancerIds = data
          .map((r) => r['freelancer_id']?.toString())
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      Map<String, Map<String, dynamic>> profileMap = {};
      if (freelancerIds.isNotEmpty) {
        try {
          final profiles = await _supabase
              .from('profiles')
              .select('*')
              .inFilter('id', freelancerIds);

          profileMap = {
            for (final p in (profiles as List).whereType<Map>())
              (p['id'] ?? '').toString(): Map<String, dynamic>.from(p),
          };
        } catch (e, st) {
          // Keep candidate rows visible even if profiles query fails.
          debugPrint('fetchCandidates profiles lookup error: $e\n$st');
        }
      }

      return data.map<Map<String, dynamic>>((row) {
        final freelancerId = row['freelancer_id']?.toString() ?? '';
        final r = Map<String, dynamic>.from(row);
        r['freelancer'] = profileMap[freelancerId] ?? <String, dynamic>{};
        return r;
      }).toList();
    } catch (e, st) {
      debugPrint('fetchCandidates error: $e\n$st');
      return [];
    }
  }

  @override
  Future<void> submitProposal(
    String missionId,
    double price,
    String message,
  ) async {
    if (_userId == null) return;
    try {
      // 1. Enregistrer la candidature
      await _supabase.from('candidates').upsert({
        'mission_id': missionId,
        'freelancer_id': _userId!,
        'proposed_price': price,
        'message': message,
        'status': 'en_attente',
      }, onConflict: 'mission_id,freelancer_id');

      // 2. Passer la mission en candidate_received si elle était encore en attente
      //    (seulement si aucun candidat n'avait encore postulé)
      await _supabase
          .from('missions')
          .update({'status': 'candidate_received'})
          .eq('id', missionId)
          .eq('status', 'waiting_candidates');
    } catch (e) {
      debugPrint('submitProposal error: $e');
      rethrow;
    }
  }

  // ─── Sérialisation ───────────────────────────────────────────────────────

  static Mission _fromJson(Map<String, dynamic> j) {
    final clientMap = j['client'] as Map<String, dynamic>?;
    final prestaMap = j['presta'] as Map<String, dynamic>?;

    return Mission(
      id: j['id'] as String,
      title: j['title'] as String,
      description: j['description'] as String? ?? '',
      categoryId: j['service_category_id'] as String? ?? '',
      date: DateTime.parse(
        j['scheduled_at'] as String? ?? j['created_at'] as String,
      ),
      timeSlot: '',
      address: MissionAddress(
        fullAddress: j['full_address'] as String? ?? '',
        shortAddress: j['short_address'] as String? ?? '',
      ),
      budget: BudgetInfo(
        type: BudgetType.values.firstWhere(
          (t) => t.name == (j['budget_type'] as String? ?? 'quote'),
          orElse: () => BudgetType.quote,
        ),
        amount: (j['budget_amount'] as num?)?.toDouble(),
        estimatedHours: (j['estimated_hours'] as num?)?.toDouble(),
      ),
      status: _statusFromDb(j['status'] as String?),
      images: const [],
      createdAt: DateTime.parse(j['created_at'] as String),
      candidatesCount: (j['candidates_count'] as num?)?.toInt() ?? 0,
      rating: null,
      client: clientMap != null ? _clientFromJson(clientMap) : null,
      assignedPresta: prestaMap != null ? _prestaFromJson(prestaMap) : null,
      startCode: j['start_code'] as String?,
    );
  }

  static ClientInfo _clientFromJson(Map<String, dynamic> j) => ClientInfo(
    id: j['id'] as String,
    name: '${j['first_name'] ?? ''} ${j['last_name'] ?? ''}'.trim(),
    avatarUrl: j['avatar_url'] as String? ?? '',
    rating: (j['rating'] as num?)?.toDouble() ?? 0,
    missionsCount: j['completed_missions'] as int? ?? 0,
    isVerified: j['is_verified'] as bool? ?? false,
    phone: j['phone'] as String?,
  );

  static PrestaInfo _prestaFromJson(Map<String, dynamic> j) => PrestaInfo(
    id: j['id'] as String,
    name: '${j['first_name'] ?? ''} ${j['last_name'] ?? ''}'.trim(),
    avatarUrl: j['avatar_url'] as String? ?? '',
    rating: (j['rating'] as num?)?.toDouble() ?? 0,
    reviewsCount: j['reviews_count'] as int? ?? 0,
    completedMissions: j['completed_missions'] as int? ?? 0,
    isVerified: j['is_verified'] as bool? ?? false,
    phone: j['phone'] as String?,
  );

  static Map<String, dynamic> _toJson(Mission m, String clientId) {
    final map = <String, dynamic>{
      'id': m.id,
      'client_id': clientId,
      'title': m.title,
      'description': m.description,
      'service_category_id': m.categoryId,
      'scheduled_at': m.date.toIso8601String(),
      'full_address': m.address.fullAddress,
      'short_address': m.address.shortAddress,
      'budget_type': m.budget.type.name,
      'budget_amount': m.budget.amount,
      'estimated_hours': m.budget.estimatedHours,
      'status': _statusToDb(m.status),
      'is_public': m.status != MissionStatus.draft,
    };
    if (m.assignedPresta != null) {
      map['assigned_presta_id'] = m.assignedPresta!.id;
    }
    return map;
  }

  // ─── Status mapping (Dart enum ↔ DB snake_case) ───────────────────────────

  static String _statusToDb(MissionStatus s) => switch (s) {
    MissionStatus.draft => 'draft',
    MissionStatus.waitingCandidates => 'waiting_candidates',
    MissionStatus.candidateReceived => 'candidate_received',
    MissionStatus.confirmed => 'confirmed',
    MissionStatus.onTheWay => 'on_the_way',
    MissionStatus.inProgress => 'in_progress',
    MissionStatus.completionRequested => 'completion_requested',
    MissionStatus.completed => 'completed',
    MissionStatus.paymentHeld => 'payment_held',
    MissionStatus.awaitingRelease => 'awaiting_release',
    MissionStatus.inDispute => 'in_dispute',
    MissionStatus.closed => 'closed',
    MissionStatus.cancelled => 'cancelled',
    MissionStatus.expired => 'expired',
  };

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
    'waiting_payment' => MissionStatus.awaitingRelease, // rétro-compatibilité
    'in_dispute' => MissionStatus.inDispute,
    'dispute' => MissionStatus.inDispute, // rétro-compatibilité
    'closed' => MissionStatus.closed,
    'cancelled' => MissionStatus.cancelled,
    'expired' => MissionStatus.expired,
    _ => MissionStatus.waitingCandidates,
  };
}
