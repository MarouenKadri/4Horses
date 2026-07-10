import 'package:flutter_test/flutter_test.dart';
import 'package:fourhorses/features/mission/data/models/mission.dart';
import 'package:fourhorses/features/mission/presentation/widgets/shared/mission_finance_ui.dart';
import 'package:fourhorses/features/mission/presentation/widgets/shared/mission_status_ui.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

Mission _mission({
  required MissionStatus status,
  double amount = 100,
  String timeSlot = '14h00 - 17h00',
  DateTime? date,
  PrestaInfo? presta,
}) {
  return Mission(
    id: 'test-id',
    title: 'Test',
    description: 'Desc',
    categoryId: 'menage',
    date: date ?? DateTime(2026, 6, 15),
    timeSlot: timeSlot,
    address: const MissionAddress(
      fullAddress: '1 rue Test',
      shortAddress: 'Paris',
    ),
    budget: BudgetInfo(type: BudgetType.fixed, amount: amount),
    status: status,
    createdAt: DateTime(2026, 1, 1),
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

void main() {
  // ─── BudgetInfo ──────────────────────────────────────────────────────────

  group('BudgetInfo.totalAmount', () {
    test('fixe 100€ → 100', () {
      expect(
        const BudgetInfo(type: BudgetType.fixed, amount: 100).totalAmount,
        100,
      );
    });

    test('horaire 20€/h × 3h → 60', () {
      expect(
        const BudgetInfo(
          type: BudgetType.hourly,
          amount: 20,
          estimatedHours: 3,
        ).totalAmount,
        60,
      );
    });

    test('horaire sans heures estimées → amount × 1', () {
      expect(
        const BudgetInfo(type: BudgetType.hourly, amount: 20).totalAmount,
        20,
      );
    });

    test('devis → 0', () {
      expect(const BudgetInfo(type: BudgetType.quote).totalAmount, 0);
    });

    test('fixe sans montant → 0', () {
      expect(const BudgetInfo(type: BudgetType.fixed).totalAmount, 0);
    });
  });

  group('BudgetInfo.displayText', () {
    test('fixe → "100 €"', () {
      expect(
        const BudgetInfo(type: BudgetType.fixed, amount: 100).displayText,
        '100 €',
      );
    });

    test('horaire → "20 €/h"', () {
      expect(
        const BudgetInfo(type: BudgetType.hourly, amount: 20).displayText,
        '20 €/h',
      );
    });

    test('devis → "Sur devis"', () {
      expect(const BudgetInfo(type: BudgetType.quote).displayText, 'Sur devis');
    });

    test('fixe sans montant → "À définir"', () {
      expect(const BudgetInfo(type: BudgetType.fixed).displayText, 'À définir');
    });
  });

  // ─── Mission.scheduledStart ──────────────────────────────────────────────

  group('Mission.scheduledStart', () {
    test('parse "14h00 - 17h00" → 14:00', () {
      final m = _mission(
        status: MissionStatus.confirmed,
        timeSlot: '14h00 - 17h00',
      );
      expect(m.scheduledStart.hour, 14);
      expect(m.scheduledStart.minute, 0);
    });

    test('parse "09h30 - 11h00" → 9:30', () {
      final m = _mission(
        status: MissionStatus.confirmed,
        timeSlot: '09h30 - 11h00',
      );
      expect(m.scheduledStart.hour, 9);
      expect(m.scheduledStart.minute, 30);
    });

    test('timeSlot vide → retourne date brute', () {
      final date = DateTime(2026, 6, 15);
      final m = _mission(
        status: MissionStatus.confirmed,
        timeSlot: '',
        date: date,
      );
      expect(m.scheduledStart, date);
    });

    test('conserve la date de la mission', () {
      final m = _mission(
        status: MissionStatus.confirmed,
        date: DateTime(2026, 6, 15),
        timeSlot: '10h00 - 12h00',
      );
      expect(m.scheduledStart.year, 2026);
      expect(m.scheduledStart.month, 6);
      expect(m.scheduledStart.day, 15);
    });
  });

  // ─── Mission.duration ────────────────────────────────────────────────────

  group('Mission.duration', () {
    test('horaire 2h → "2h"', () {
      final m = Mission(
        id: 'x',
        title: 'T',
        description: 'D',
        categoryId: 'c',
        date: DateTime(2026, 6, 15),
        timeSlot: '10h00 - 12h00',
        address: const MissionAddress(fullAddress: 'A', shortAddress: 'A'),
        budget: const BudgetInfo(
          type: BudgetType.hourly,
          amount: 20,
          estimatedHours: 2,
        ),
        createdAt: DateTime(2026, 1, 1),
      );
      expect(m.duration, '2h');
    });

    test('horaire 1.5h → "1.5h"', () {
      final m = Mission(
        id: 'x',
        title: 'T',
        description: 'D',
        categoryId: 'c',
        date: DateTime(2026, 6, 15),
        timeSlot: '10h00 - 12h00',
        address: const MissionAddress(fullAddress: 'A', shortAddress: 'A'),
        budget: const BudgetInfo(
          type: BudgetType.hourly,
          amount: 20,
          estimatedHours: 1.5,
        ),
        createdAt: DateTime(2026, 1, 1),
      );
      expect(m.duration, '1.5h');
    });

    test('fixe → "-"', () {
      final m = _mission(status: MissionStatus.confirmed);
      expect(m.duration, '-');
    });
  });

  // ─── MissionStatusX.isActive ─────────────────────────────────────────────

  group('MissionStatusX.isActive', () {
    test(
      'confirmed → actif',
      () => expect(MissionStatus.confirmed.isActive, true),
    );
    test(
      'inProgress → actif',
      () => expect(MissionStatus.inProgress.isActive, true),
    );
    test(
      'awaitingRelease → actif',
      () => expect(MissionStatus.awaitingRelease.isActive, true),
    );
    test(
      'closed → inactif',
      () => expect(MissionStatus.closed.isActive, false),
    );
    test(
      'cancelled → inactif',
      () => expect(MissionStatus.cancelled.isActive, false),
    );
    test('draft → inactif', () => expect(MissionStatus.draft.isActive, false));
    test(
      'expired → inactif',
      () => expect(MissionStatus.expired.isActive, false),
    );
  });

  // ─── MissionFinanceUi.outsideLabel ──────────────────────────────────────

  group('MissionFinanceUi.outsideLabel — client', () {
    test('pending → "Paiement en attente"', () {
      final m = _mission(status: MissionStatus.waitingCandidates);
      expect(
        MissionFinanceUi.outsideLabel(mission: m, role: MissionUiRole.client),
        'Paiement en attente',
      );
    });

    test('secured → "Argent sécurisé"', () {
      final m = _mission(status: MissionStatus.confirmed);
      expect(
        MissionFinanceUi.outsideLabel(mission: m, role: MissionUiRole.client),
        'Argent sécurisé',
      );
    });

    test('awaitingRelease → "Versement auto dans 24h"', () {
      final m = _mission(status: MissionStatus.awaitingRelease);
      expect(
        MissionFinanceUi.outsideLabel(mission: m, role: MissionUiRole.client),
        'Versement auto dans 24h',
      );
    });

    test('closed → "Prestataire payé"', () {
      final m = _mission(status: MissionStatus.closed);
      expect(
        MissionFinanceUi.outsideLabel(mission: m, role: MissionUiRole.client),
        'Prestataire payé',
      );
    });

    test('inDispute → "Paiement suspendu"', () {
      final m = _mission(status: MissionStatus.inDispute);
      expect(
        MissionFinanceUi.outsideLabel(mission: m, role: MissionUiRole.client),
        'Paiement suspendu',
      );
    });
  });

  group('MissionFinanceUi.outsideLabel — freelancer', () {
    test('pending → "Paiement garanti à la fin"', () {
      final m = _mission(status: MissionStatus.waitingCandidates);
      expect(
        MissionFinanceUi.outsideLabel(
          mission: m,
          role: MissionUiRole.freelancer,
        ),
        'Paiement garanti à la fin',
      );
    });

    test('secured → "Fonds réservés pour vous"', () {
      final m = _mission(status: MissionStatus.confirmed);
      expect(
        MissionFinanceUi.outsideLabel(
          mission: m,
          role: MissionUiRole.freelancer,
        ),
        'Fonds réservés pour vous',
      );
    });

    test('awaitingRelease → "Versement automatique sous 24h"', () {
      final m = _mission(status: MissionStatus.awaitingRelease);
      expect(
        MissionFinanceUi.outsideLabel(
          mission: m,
          role: MissionUiRole.freelancer,
        ),
        'Versement automatique sous 24h',
      );
    });

    test('closed → "Versement reçu"', () {
      final m = _mission(status: MissionStatus.closed);
      expect(
        MissionFinanceUi.outsideLabel(
          mission: m,
          role: MissionUiRole.freelancer,
        ),
        'Versement reçu',
      );
    });

    test('cancelled + presta → "Mission annulée"', () {
      final m = _mission(
        status: MissionStatus.cancelled,
        presta: _presta,
        date: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(
        MissionFinanceUi.outsideLabel(
          mission: m,
          role: MissionUiRole.freelancer,
        ),
        'Mission annulée',
      );
    });
  });

  // ─── MissionFinanceUi.amountLine ────────────────────────────────────────

  group('MissionFinanceUi.amountLine — client', () {
    test('pending 100€ → "Montant à payer: 100 €"', () {
      final m = _mission(status: MissionStatus.waitingCandidates, amount: 100);
      expect(
        MissionFinanceUi.amountLine(
          mission: m,
          state: MissionFinanceState.pending,
          role: MissionUiRole.client,
        ),
        'Montant à payer: 100 €',
      );
    });

    test('secured 100€ → "Montant payé: 100 €"', () {
      final m = _mission(status: MissionStatus.confirmed, amount: 100);
      expect(
        MissionFinanceUi.amountLine(
          mission: m,
          state: MissionFinanceState.secured,
          role: MissionUiRole.client,
        ),
        'Montant payé: 100 €',
      );
    });

    test('refund100 100€ → "Remboursement estimé: 100 €"', () {
      final m = _mission(
        status: MissionStatus.cancelled,
        amount: 100,
        presta: _presta,
      );
      expect(
        MissionFinanceUi.amountLine(
          mission: m,
          state: MissionFinanceState.refund100,
          role: MissionUiRole.client,
        ),
        'Remboursement estimé: 100 €',
      );
    });

    test('refund50 100€ → "Remboursement estimé: 50 €"', () {
      final m = _mission(
        status: MissionStatus.cancelled,
        amount: 100,
        presta: _presta,
      );
      expect(
        MissionFinanceUi.amountLine(
          mission: m,
          state: MissionFinanceState.refund50,
          role: MissionUiRole.client,
        ),
        'Remboursement estimé: 50 €',
      );
    });
  });

  group('MissionFinanceUi.amountLine — freelancer', () {
    test('pending 100€ → potentiel 90 €', () {
      final m = _mission(status: MissionStatus.waitingCandidates, amount: 100);
      expect(
        MissionFinanceUi.amountLine(
          mission: m,
          state: MissionFinanceState.pending,
          role: MissionUiRole.freelancer,
        ),
        'Montant potentiel: 90 €',
      );
    });

    test('paidOut 100€ → reçu 90 €', () {
      final m = _mission(status: MissionStatus.closed, amount: 100);
      expect(
        MissionFinanceUi.amountLine(
          mission: m,
          state: MissionFinanceState.paidOut,
          role: MissionUiRole.freelancer,
        ),
        'Montant reçu: 90 €',
      );
    });

    test('refund → "Montant à recevoir: 0 €"', () {
      final m = _mission(
        status: MissionStatus.cancelled,
        amount: 100,
        presta: _presta,
      );
      expect(
        MissionFinanceUi.amountLine(
          mission: m,
          state: MissionFinanceState.refund100,
          role: MissionUiRole.freelancer,
        ),
        'Montant à recevoir: 0 €',
      );
    });

    test('secured 100€ → à recevoir 90 €', () {
      final m = _mission(status: MissionStatus.confirmed, amount: 100);
      expect(
        MissionFinanceUi.amountLine(
          mission: m,
          state: MissionFinanceState.secured,
          role: MissionUiRole.freelancer,
        ),
        'Montant à recevoir: 90 €',
      );
    });
  });

  // ─── MissionFinanceUi.amountPills ───────────────────────────────────────

  group('MissionFinanceUi.amountPills', () {
    test('secured client 100€ → reserved "100 €", paid "0 €"', () {
      final m = _mission(status: MissionStatus.confirmed, amount: 100);
      final pills = MissionFinanceUi.amountPills(
        mission: m,
        state: MissionFinanceState.secured,
        role: MissionUiRole.client,
      );
      expect(pills.reserved, '100 €');
      expect(pills.paid, '0 €');
    });

    test('paidOut client 100€ → reserved "0 €", paid "100 €"', () {
      final m = _mission(status: MissionStatus.closed, amount: 100);
      final pills = MissionFinanceUi.amountPills(
        mission: m,
        state: MissionFinanceState.paidOut,
        role: MissionUiRole.client,
      );
      expect(pills.reserved, '0 €');
      expect(pills.paid, '100 €');
    });

    test('secured freelancer 100€ → reserved "90 €"', () {
      final m = _mission(status: MissionStatus.confirmed, amount: 100);
      final pills = MissionFinanceUi.amountPills(
        mission: m,
        state: MissionFinanceState.secured,
        role: MissionUiRole.freelancer,
      );
      expect(pills.reserved, '90 €');
    });

    test('pending → reserved "0 €", paid "0 €"', () {
      final m = _mission(status: MissionStatus.waitingCandidates, amount: 100);
      final pills = MissionFinanceUi.amountPills(
        mission: m,
        state: MissionFinanceState.pending,
        role: MissionUiRole.client,
      );
      expect(pills.reserved, '0 €');
      expect(pills.paid, '0 €');
    });
  });
}
