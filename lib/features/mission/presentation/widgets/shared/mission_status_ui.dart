import '../../../data/models/mission.dart';

enum MissionUiRole { client, freelancer }

enum MissionUiTab { published, applied, confirmed, inProgress, archived }

class MissionStatusUi {
  /// Vérifie si une mission (avec sa date) appartient à un tab donné.
  ///
  /// Une mission `confirmed` reste dans "Confirmées" quelle que soit sa date
  /// planifiée — elle ne passe dans "En cours" que lorsque le prestataire
  /// démarre réellement la mission (statut `onTheWay`/`inProgress`).
  static bool missionBelongsToTab({
    required Mission mission,
    required MissionUiRole role,
    required MissionUiTab tab,
  }) {
    return belongsToTab(status: mission.status, role: role, tab: tab);
  }

  /// Version statut seul (sans date) — utilisée pour les badges et labels.
  static bool belongsToTab({
    required MissionStatus status,
    required MissionUiRole role,
    required MissionUiTab tab,
  }) {
    switch (role) {
      case MissionUiRole.client:
        switch (tab) {
          case MissionUiTab.published:
            return status == MissionStatus.waitingCandidates ||
                status == MissionStatus.candidateReceived ||
                status == MissionStatus.pendingAcceptance;
          case MissionUiTab.confirmed:
            return status == MissionStatus.confirmed;
          case MissionUiTab.inProgress:
            return status == MissionStatus.onTheWay ||
                status == MissionStatus.inProgress ||
                status == MissionStatus.completionRequested ||
                status == MissionStatus.completed ||
                status == MissionStatus.paymentHeld ||
                status == MissionStatus.awaitingRelease;
          case MissionUiTab.archived:
            return status == MissionStatus.closed ||
                status == MissionStatus.cancelled ||
                status == MissionStatus.expired ||
                status == MissionStatus.inDispute;
          case MissionUiTab.applied:
            return false;
        }
      case MissionUiRole.freelancer:
        switch (tab) {
          case MissionUiTab.applied:
            return status == MissionStatus.candidateReceived ||
                status == MissionStatus.pendingAcceptance;
          case MissionUiTab.confirmed:
            return status == MissionStatus.confirmed;
          case MissionUiTab.inProgress:
            return status == MissionStatus.onTheWay ||
                status == MissionStatus.inProgress ||
                status == MissionStatus.completionRequested ||
                status == MissionStatus.completed ||
                status == MissionStatus.paymentHeld ||
                status == MissionStatus.awaitingRelease;
          case MissionUiTab.archived:
            return status == MissionStatus.closed ||
                status == MissionStatus.cancelled ||
                status == MissionStatus.expired ||
                status == MissionStatus.inDispute;
          case MissionUiTab.published:
            return false;
        }
    }
  }

  static String badgeLabel({
    required MissionStatus status,
    required MissionUiRole role,
  }) {
    switch (role) {
      case MissionUiRole.client:
        return switch (status) {
          MissionStatus.draft => 'Publiee',
          MissionStatus.waitingCandidates => 'Publiee',
          MissionStatus.candidateReceived => 'Publiee',
          MissionStatus.pendingAcceptance => 'Attente du prestataire',
          MissionStatus.confirmed => 'Confirmee',
          MissionStatus.onTheWay => 'En cours',
          MissionStatus.inProgress => 'En cours',
          MissionStatus.completionRequested => 'Validation requise',
          MissionStatus.completed => 'Montant reserve',
          MissionStatus.paymentHeld => 'Montant reserve',
          MissionStatus.awaitingRelease => 'Liberation 24h',
          MissionStatus.closed => 'Verse',
          MissionStatus.cancelled => 'Annulee',
          MissionStatus.inDispute => 'Litige',
          MissionStatus.expired => 'Annulée',
        };
      case MissionUiRole.freelancer:
        return switch (status) {
          MissionStatus.draft => 'Postulée',
          MissionStatus.waitingCandidates => 'Postulée',
          MissionStatus.candidateReceived => 'Postulée',
          MissionStatus.pendingAcceptance => 'Réservation à accepter',
          MissionStatus.confirmed => 'Confirmée',
          MissionStatus.onTheWay => 'En cours',
          MissionStatus.inProgress => 'En cours',
          MissionStatus.completionRequested => 'Validation client',
          MissionStatus.completed => 'Fonds réservés',
          MissionStatus.paymentHeld => 'Fonds réservés',
          MissionStatus.awaitingRelease => 'Versement 24h',
          MissionStatus.closed => 'Versement effectué',
          MissionStatus.cancelled => 'Annulée',
          MissionStatus.inDispute => 'Litige en cours',
          MissionStatus.expired => 'Annulée',
        };
    }
  }
}
