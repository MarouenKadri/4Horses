import '../../../data/models/mission.dart';

enum MissionUiRole { client, freelancer }

enum MissionUiTab { published, applied, confirmed, inProgress, archived }

class MissionStatusUi {
  /// Vérifie si une mission (avec sa date) appartient à un tab donné.
  ///
  /// Règle de promotion automatique :
  ///   Une mission `confirmed` dont la date est aujourd'hui
  ///   ou passée est promue dans "En cours" et retirée de "Confirmées".
  static bool missionBelongsToTab({
    required Mission mission,
    required MissionUiRole role,
    required MissionUiTab tab,
  }) {
    final isConfirmedStatus = mission.status == MissionStatus.confirmed;

    if (isConfirmedStatus && _isScheduledNowOrPast(mission.date)) {
      // Promue → "En cours", disparaît de "Confirmées"
      return tab == MissionUiTab.inProgress;
    }

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
                status == MissionStatus.candidateReceived;
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
            return status == MissionStatus.candidateReceived;
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

  /// Vrai si la date planifiée est aujourd'hui ou dans le passé.
  static bool _isScheduledNowOrPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final missionDay = DateTime(date.year, date.month, date.day);
    return !missionDay.isAfter(today);
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
