import 'package:flutter/material.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/mission.dart';
import 'mission_status_ui.dart';

enum MissionFinanceState {
  pending,
  secured,
  awaitingRelease24h,
  paidOut,
  disputeHold,
  refund100,
  refund50,
}

class MissionFinanceUi {
  static const Set<MissionStatus> _paymentLinkedStatuses = {
    MissionStatus.confirmed,
    MissionStatus.onTheWay,
    MissionStatus.inProgress,
    MissionStatus.completionRequested,
    MissionStatus.completed,
    MissionStatus.paymentHeld,
    MissionStatus.awaitingRelease,
    MissionStatus.closed,
    MissionStatus.inDispute,
  };

  static bool isPaymentLinkedMission(Mission mission) {
    if (_paymentLinkedStatuses.contains(mission.status)) return true;
    if (mission.status == MissionStatus.cancelled) {
      // Annulation après réservation/presta assigné => logique de remboursement.
      return mission.assignedPresta != null;
    }
    return false;
  }

  static MissionFinanceState resolveState(Mission mission, {DateTime? now}) {
    switch (mission.status) {
      case MissionStatus.draft:
      case MissionStatus.waitingCandidates:
      case MissionStatus.candidateReceived:
      case MissionStatus.pendingAcceptance:
      case MissionStatus.expired:
        return MissionFinanceState.pending;
      case MissionStatus.confirmed:
      case MissionStatus.onTheWay:
      case MissionStatus.inProgress:
      case MissionStatus.completionRequested:
      case MissionStatus.completed:
      case MissionStatus.paymentHeld:
        return MissionFinanceState.secured;
      case MissionStatus.awaitingRelease:
        return MissionFinanceState.awaitingRelease24h;
      case MissionStatus.closed:
        return MissionFinanceState.paidOut;
      case MissionStatus.inDispute:
        return MissionFinanceState.disputeHold;
      case MissionStatus.cancelled:
        if (!isPaymentLinkedMission(mission)) {
          return MissionFinanceState.pending;
        }
        return _cancelRefundState(mission, now: now);
    }
  }

  static MissionFinanceState _cancelRefundState(
    Mission mission, {
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    final startsIn = mission.scheduledStart.difference(ref);
    final isMoreThan24h = startsIn.inMinutes >= 24 * 60;
    return isMoreThan24h
        ? MissionFinanceState.refund100
        : MissionFinanceState.refund50;
  }

  static bool isRefund(MissionFinanceState state) {
    return state == MissionFinanceState.refund100 ||
        state == MissionFinanceState.refund50;
  }

  static Color accentColor(BuildContext context, MissionFinanceState state) {
    return switch (state) {
      MissionFinanceState.pending => context.colors.textTertiary,
      MissionFinanceState.secured => AppColors.primary,
      MissionFinanceState.awaitingRelease24h => AppColors.warning,
      MissionFinanceState.paidOut => AppColors.primary,
      MissionFinanceState.disputeHold => context.colors.error,
      MissionFinanceState.refund100 => AppColors.info,
      MissionFinanceState.refund50 => AppColors.warning,
    };
  }

  static IconData stateIcon(MissionFinanceState state) {
    return switch (state) {
      MissionFinanceState.pending => Icons.hourglass_empty_rounded,
      MissionFinanceState.secured => Icons.shield_rounded,
      MissionFinanceState.awaitingRelease24h => Icons.timer_rounded,
      MissionFinanceState.paidOut => Icons.check_circle_rounded,
      MissionFinanceState.disputeHold => Icons.gavel_rounded,
      MissionFinanceState.refund100 => Icons.undo_rounded,
      MissionFinanceState.refund50 => Icons.undo_rounded,
    };
  }

  static String outsideLabel({
    required Mission mission,
    required MissionUiRole role,
    DateTime? now,
  }) {
    final state = resolveState(mission, now: now);

    return switch (role) {
      MissionUiRole.client => switch (state) {
        MissionFinanceState.pending => 'Paiement en attente',
        MissionFinanceState.secured => 'Argent sécurisé',
        MissionFinanceState.awaitingRelease24h => 'Versement auto dans 24h',
        MissionFinanceState.paidOut => 'Prestataire payé',
        MissionFinanceState.disputeHold => 'Paiement suspendu',
        MissionFinanceState.refund100 => 'Remboursement total',
        MissionFinanceState.refund50 => 'Remboursement 50 %',
      },
      MissionUiRole.freelancer => switch (state) {
        MissionFinanceState.pending => 'Paiement garanti à la fin',
        MissionFinanceState.secured => 'Fonds réservés pour vous',
        MissionFinanceState.awaitingRelease24h =>
          'Versement automatique sous 24h',
        MissionFinanceState.paidOut => 'Versement reçu',
        MissionFinanceState.disputeHold => 'Versement suspendu',
        MissionFinanceState.refund100 ||
        MissionFinanceState.refund50 => 'Mission annulée',
      },
    };
  }

  static String detailTitle({
    required MissionFinanceState state,
    required MissionUiRole role,
  }) {
    return switch (role) {
      MissionUiRole.client => switch (state) {
        MissionFinanceState.pending => 'Paiement a venir',
        MissionFinanceState.secured => 'Montant réservé',
        MissionFinanceState.awaitingRelease24h => 'Libération programmée',
        MissionFinanceState.paidOut => 'Paiement libéré',
        MissionFinanceState.disputeHold => 'Paiement suspendu',
        MissionFinanceState.refund100 => 'Remboursement intégral',
        MissionFinanceState.refund50 => 'Remboursement partiel',
      },
      MissionUiRole.freelancer => switch (state) {
        MissionFinanceState.pending => 'Paiement en attente',
        MissionFinanceState.secured => 'Fonds réservés',
        MissionFinanceState.awaitingRelease24h => 'Versement programmé',
        MissionFinanceState.paidOut => 'Versement effectué',
        MissionFinanceState.disputeHold => 'Versement suspendu',
        MissionFinanceState.refund100 ||
        MissionFinanceState.refund50 => 'Mission annulée',
      },
    };
  }

  static String detailSubtitle({
    required MissionFinanceState state,
    required MissionUiRole role,
  }) {
    return switch (role) {
      MissionUiRole.client => switch (state) {
        MissionFinanceState.pending =>
          'Vous payez uniquement lorsque la mission est terminée et validée.',
        MissionFinanceState.secured =>
          'Le montant est prélevé et conservé de manière sécurisée.',
        MissionFinanceState.awaitingRelease24h =>
          'Le prestataire sera versé automatiquement après 24h sans litige.',
        MissionFinanceState.paidOut =>
          'Le paiement a été envoyé au prestataire.',
        MissionFinanceState.disputeHold =>
          'L’argent reste bloqué jusqu’à résolution du problème.',
        MissionFinanceState.refund100 =>
          'Annulation plus de 24h avant la mission: remboursement 100%.',
        MissionFinanceState.refund50 =>
          'Annulation à moins de 24h ou le jour J: remboursement 50%.',
      },
      MissionUiRole.freelancer => switch (state) {
        MissionFinanceState.pending =>
          'Le client n’a pas encore validé et réglé la mission.',
        MissionFinanceState.secured =>
          'Les fonds sont bloqués, ils sont bien réservés pour vous.',
        MissionFinanceState.awaitingRelease24h =>
          'Le versement arrive automatiquement sous 24 heures sans litige.',
        MissionFinanceState.paidOut =>
          'Le versement est effectué sur votre portefeuille.',
        MissionFinanceState.disputeHold =>
          'Le versement est suspendu le temps de traiter le litige.',
        MissionFinanceState.refund100 || MissionFinanceState.refund50 =>
          'Mission annulée: aucun versement pour cette mission.',
      },
    };
  }

  static String amountLine({
    required Mission mission,
    required MissionFinanceState state,
    required MissionUiRole role,
  }) {
    final total = mission.budget.averageAmount;
    final freelancerPayout = total * 0.9;

    if (role == MissionUiRole.client) {
      if (state == MissionFinanceState.pending) {
        return 'Montant à payer: ${_euro(total)}';
      }
      if (state == MissionFinanceState.refund100) {
        return 'Remboursement estimé: ${_euro(total)}';
      }
      if (state == MissionFinanceState.refund50) {
        return 'Remboursement estimé: ${_euro(total * 0.5)}';
      }
      return 'Montant payé: ${_euro(total)}';
    }

    if (state == MissionFinanceState.pending) {
      return 'Montant potentiel: ${_euro(freelancerPayout)}';
    }
    if (state == MissionFinanceState.paidOut) {
      return 'Montant reçu: ${_euro(freelancerPayout)}';
    }
    if (isRefund(state)) {
      return 'Montant à recevoir: 0 €';
    }
    return 'Montant à recevoir: ${_euro(freelancerPayout)}';
  }

  static IconData amountIcon({
    required MissionFinanceState state,
    required MissionUiRole role,
  }) {
    if (role == MissionUiRole.client) {
      return switch (state) {
        MissionFinanceState.pending => Icons.payments_outlined,
        MissionFinanceState.refund100 ||
        MissionFinanceState.refund50 => Icons.replay_rounded,
        MissionFinanceState.disputeHold => Icons.pause_circle_outline_rounded,
        _ => Icons.payments_rounded,
      };
    }

    return switch (state) {
      MissionFinanceState.pending => Icons.wallet_outlined,
      MissionFinanceState.paidOut => Icons.account_balance_wallet_rounded,
      MissionFinanceState.disputeHold => Icons.pause_circle_outline_rounded,
      MissionFinanceState.refund100 ||
      MissionFinanceState.refund50 => Icons.money_off_csred_rounded,
      _ => Icons.savings_rounded,
    };
  }

  static ({String reserved, String paid}) amountPills({
    required Mission mission,
    required MissionFinanceState state,
    required MissionUiRole role,
  }) {
    final total = mission.budget.averageAmount;
    final freelancerPayout = total * 0.9;
    final base = role == MissionUiRole.client ? total : freelancerPayout;

    final reserved = switch (state) {
      MissionFinanceState.secured ||
      MissionFinanceState.awaitingRelease24h ||
      MissionFinanceState.disputeHold => base,
      _ => 0.0,
    };

    final paid = switch (state) {
      MissionFinanceState.paidOut => base,
      _ => 0.0,
    };

    return (reserved: _euro(reserved), paid: _euro(paid));
  }

  static String _euro(double value) {
    // ignore: library_private_types_in_public_api
    final rounded = value.roundToDouble();
    if (rounded == value) return '${rounded.toInt()} €';
    return '${value.toStringAsFixed(2)} €';
  }
}

class MissionFinanceStatusBadge extends StatelessWidget {
  final Mission mission;
  final MissionUiRole role;

  const MissionFinanceStatusBadge({
    super.key,
    required this.mission,
    required this.role,
  });

  static bool shouldDisplay(Mission mission) {
    return MissionFinanceUi.isPaymentLinkedMission(mission);
  }

  @override
  Widget build(BuildContext context) {
    final state = MissionFinanceUi.resolveState(mission);
    final accent = MissionFinanceUi.accentColor(context, state);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(MissionFinanceUi.stateIcon(state), size: 13, color: accent),
          const SizedBox(width: 6),
          Text(
            MissionFinanceUi.outsideLabel(mission: mission, role: role),
            style: context.text.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class MissionFinanceExposureCard extends StatelessWidget {
  final Mission mission;
  final MissionUiRole role;

  const MissionFinanceExposureCard({
    super.key,
    required this.mission,
    required this.role,
  });

  static bool shouldDisplay(Mission mission) {
    return MissionFinanceUi.isPaymentLinkedMission(mission);
  }

  @override
  Widget build(BuildContext context) {
    final state = MissionFinanceUi.resolveState(mission);
    final accent = MissionFinanceUi.accentColor(context, state);
    final icon = MissionFinanceUi.stateIcon(state);
    final label = MissionFinanceUi.outsideLabel(mission: mission, role: role);
    final amount = MissionFinanceUi._euro(
      role == MissionUiRole.client
          ? mission.budget.averageAmount
          : mission.budget.averageAmount * 0.9,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: context.text.labelMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            amount,
            style: context.text.labelMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
