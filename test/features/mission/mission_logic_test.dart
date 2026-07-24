import 'package:flutter_test/flutter_test.dart';
import 'package:fourhorses/features/mission/data/models/mission.dart';
import 'package:fourhorses/features/mission/presentation/widgets/shared/mission_finance_ui.dart';
import 'package:fourhorses/features/mission/presentation/widgets/shared/mission_status_ui.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

final _baseDate = DateTime(2026, 6, 15, 10, 0);

Mission _mission({
  required MissionStatus status,
  PrestaInfo? presta,
  DateTime? date,
  String timeSlot = '10h00 - 12h00',
}) {
  return Mission(
    id: 'test-id',
    title: 'Test mission',
    description: 'Description test',
    categoryId: 'menage',
    date: date ?? _baseDate,
    timeSlot: timeSlot,
    address: const MissionAddress(
      fullAddress: '1 rue Test, Paris',
      shortAddress: 'Paris',
    ),
    budget: const BudgetInfo(type: BudgetType.fixed, amount: 100),
    status: status,
    createdAt: DateTime(2026, 6, 1),
    assignedPresta: presta,
  );
}

const _presta = PrestaInfo(
  id: 'P-1',
  name: 'Marc D.',
  avatarUrl: '',
  rating: 4.8,
  reviewsCount: 10,
  completedMissions: 50,
);

// ─── MissionFinanceUi.resolveState ────────────────────────────────────────────

void main() {
  group('MissionFinanceUi.resolveState', () {
    test('draft → pending', () {
      expect(
        MissionFinanceUi.resolveState(_mission(status: MissionStatus.draft)),
        MissionFinanceState.pending,
      );
    });

    test('waitingCandidates → pending', () {
      expect(
        MissionFinanceUi.resolveState(
          _mission(status: MissionStatus.waitingCandidates),
        ),
        MissionFinanceState.pending,
      );
    });

    test('candidateReceived → pending', () {
      expect(
        MissionFinanceUi.resolveState(
          _mission(status: MissionStatus.candidateReceived),
        ),
        MissionFinanceState.pending,
      );
    });

    test('expired → pending', () {
      expect(
        MissionFinanceUi.resolveState(_mission(status: MissionStatus.expired)),
        MissionFinanceState.pending,
      );
    });

    test('confirmed → secured', () {
      expect(
        MissionFinanceUi.resolveState(
          _mission(status: MissionStatus.confirmed),
        ),
        MissionFinanceState.secured,
      );
    });

    test('onTheWay → secured', () {
      expect(
        MissionFinanceUi.resolveState(_mission(status: MissionStatus.onTheWay)),
        MissionFinanceState.secured,
      );
    });

    test('inProgress → secured', () {
      expect(
        MissionFinanceUi.resolveState(
          _mission(status: MissionStatus.inProgress),
        ),
        MissionFinanceState.secured,
      );
    });

    test('completionRequested → secured', () {
      expect(
        MissionFinanceUi.resolveState(
          _mission(status: MissionStatus.completionRequested),
        ),
        MissionFinanceState.secured,
      );
    });

    test('completed → secured', () {
      expect(
        MissionFinanceUi.resolveState(
          _mission(status: MissionStatus.completed),
        ),
        MissionFinanceState.secured,
      );
    });

    test('paymentHeld → secured', () {
      expect(
        MissionFinanceUi.resolveState(
          _mission(status: MissionStatus.paymentHeld),
        ),
        MissionFinanceState.secured,
      );
    });

    test('awaitingRelease → awaitingRelease24h', () {
      expect(
        MissionFinanceUi.resolveState(
          _mission(status: MissionStatus.awaitingRelease),
        ),
        MissionFinanceState.awaitingRelease24h,
      );
    });

    test('closed → paidOut', () {
      expect(
        MissionFinanceUi.resolveState(_mission(status: MissionStatus.closed)),
        MissionFinanceState.paidOut,
      );
    });

    test('inDispute → disputeHold', () {
      expect(
        MissionFinanceUi.resolveState(
          _mission(status: MissionStatus.inDispute),
        ),
        MissionFinanceState.disputeHold,
      );
    });

    test('cancelled sans presta → pending', () {
      expect(
        MissionFinanceUi.resolveState(
          _mission(status: MissionStatus.cancelled),
        ),
        MissionFinanceState.pending,
      );
    });
  });

  // ─── Remboursement ────────────────────────────────────────────────────────

  group('MissionFinanceUi — remboursement annulation', () {
    test('annulation > 24h avant → refund100', () {
      final missionStart = DateTime(2026, 6, 15, 10, 0);
      final now = missionStart.subtract(const Duration(hours: 48));
      final m = _mission(
        status: MissionStatus.cancelled,
        presta: _presta,
        date: missionStart,
      );
      expect(
        MissionFinanceUi.resolveState(m, now: now),
        MissionFinanceState.refund100,
      );
    });

    test('annulation < 24h avant → refund50', () {
      final missionStart = DateTime(2026, 6, 15, 10, 0);
      final now = missionStart.subtract(const Duration(hours: 12));
      final m = _mission(
        status: MissionStatus.cancelled,
        presta: _presta,
        date: missionStart,
      );
      expect(
        MissionFinanceUi.resolveState(m, now: now),
        MissionFinanceState.refund50,
      );
    });

    test('annulation exactement 24h avant → refund100 (≥ 24h)', () {
      final missionStart = DateTime(2026, 6, 15, 10, 0);
      final now = missionStart.subtract(const Duration(hours: 24));
      final m = _mission(
        status: MissionStatus.cancelled,
        presta: _presta,
        date: missionStart,
      );
      expect(
        MissionFinanceUi.resolveState(m, now: now),
        MissionFinanceState.refund100,
      );
    });

    test('annulation le jour J → refund50', () {
      final missionStart = DateTime(2026, 6, 15, 10, 0);
      final now = missionStart.subtract(const Duration(hours: 1));
      final m = _mission(
        status: MissionStatus.cancelled,
        presta: _presta,
        date: missionStart,
      );
      expect(
        MissionFinanceUi.resolveState(m, now: now),
        MissionFinanceState.refund50,
      );
    });
  });

  // ─── isPaymentLinkedMission ───────────────────────────────────────────────

  group('MissionFinanceUi.isPaymentLinkedMission', () {
    test('confirmed → payment linked', () {
      expect(
        MissionFinanceUi.isPaymentLinkedMission(
          _mission(status: MissionStatus.confirmed),
        ),
        true,
      );
    });

    test('closed → payment linked', () {
      expect(
        MissionFinanceUi.isPaymentLinkedMission(
          _mission(status: MissionStatus.closed),
        ),
        true,
      );
    });

    test('waitingCandidates → not linked', () {
      expect(
        MissionFinanceUi.isPaymentLinkedMission(
          _mission(status: MissionStatus.waitingCandidates),
        ),
        false,
      );
    });

    test('cancelled sans presta → not linked', () {
      expect(
        MissionFinanceUi.isPaymentLinkedMission(
          _mission(status: MissionStatus.cancelled),
        ),
        false,
      );
    });

    test('cancelled avec presta → payment linked', () {
      expect(
        MissionFinanceUi.isPaymentLinkedMission(
          _mission(status: MissionStatus.cancelled, presta: _presta),
        ),
        true,
      );
    });
  });

  // ─── MissionStatusUi.belongsToTab ─────────────────────────────────────────

  group('MissionStatusUi.belongsToTab — client', () {
    test('waitingCandidates → published', () {
      expect(
        MissionStatusUi.belongsToTab(
          status: MissionStatus.waitingCandidates,
          role: MissionUiRole.client,
          tab: MissionUiTab.published,
        ),
        true,
      );
    });

    test('confirmed → confirmed tab', () {
      expect(
        MissionStatusUi.belongsToTab(
          status: MissionStatus.confirmed,
          role: MissionUiRole.client,
          tab: MissionUiTab.confirmed,
        ),
        true,
      );
    });

    test('confirmed → pas dans published', () {
      expect(
        MissionStatusUi.belongsToTab(
          status: MissionStatus.confirmed,
          role: MissionUiRole.client,
          tab: MissionUiTab.published,
        ),
        false,
      );
    });

    test('inProgress → inProgress tab', () {
      expect(
        MissionStatusUi.belongsToTab(
          status: MissionStatus.inProgress,
          role: MissionUiRole.client,
          tab: MissionUiTab.inProgress,
        ),
        true,
      );
    });

    test('closed → archived', () {
      expect(
        MissionStatusUi.belongsToTab(
          status: MissionStatus.closed,
          role: MissionUiRole.client,
          tab: MissionUiTab.archived,
        ),
        true,
      );
    });

    test('cancelled → archived', () {
      expect(
        MissionStatusUi.belongsToTab(
          status: MissionStatus.cancelled,
          role: MissionUiRole.client,
          tab: MissionUiTab.archived,
        ),
        true,
      );
    });
  });

  group('MissionStatusUi.belongsToTab — freelancer', () {
    test('confirmed → confirmed tab', () {
      expect(
        MissionStatusUi.belongsToTab(
          status: MissionStatus.confirmed,
          role: MissionUiRole.freelancer,
          tab: MissionUiTab.confirmed,
        ),
        true,
      );
    });

    test('onTheWay → inProgress tab', () {
      expect(
        MissionStatusUi.belongsToTab(
          status: MissionStatus.onTheWay,
          role: MissionUiRole.freelancer,
          tab: MissionUiTab.inProgress,
        ),
        true,
      );
    });

    test('closed → archived', () {
      expect(
        MissionStatusUi.belongsToTab(
          status: MissionStatus.closed,
          role: MissionUiRole.freelancer,
          tab: MissionUiTab.archived,
        ),
        true,
      );
    });
  });

  // ─── Promotion automatique date passée ───────────────────────────────────

  group('MissionStatusUi.missionBelongsToTab — promotion date', () {
    test('confirmed avec date passée → promu en inProgress', () {
      final m = _mission(
        status: MissionStatus.confirmed,
        date: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(
        MissionStatusUi.missionBelongsToTab(
          mission: m,
          role: MissionUiRole.client,
          tab: MissionUiTab.inProgress,
        ),
        true,
      );
    });

    test('confirmed avec date passée → retiré de confirmed', () {
      final m = _mission(
        status: MissionStatus.confirmed,
        date: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(
        MissionStatusUi.missionBelongsToTab(
          mission: m,
          role: MissionUiRole.client,
          tab: MissionUiTab.confirmed,
        ),
        false,
      );
    });

    test('confirmed avec date future → reste dans confirmed', () {
      final m = _mission(
        status: MissionStatus.confirmed,
        date: DateTime.now().add(const Duration(days: 3)),
      );
      expect(
        MissionStatusUi.missionBelongsToTab(
          mission: m,
          role: MissionUiRole.client,
          tab: MissionUiTab.confirmed,
        ),
        true,
      );
    });
  });
}
