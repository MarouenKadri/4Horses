import 'package:flutter/material.dart';

import '../../../../core/design/app_design_system.dart';
import 'service_category.dart';
import 'mission_address.dart';
import 'budget_info.dart';
import 'user_models.dart';

// Ré-exporte les types dépendants pour que les consommateurs n'aient qu'un seul import
export 'service_category.dart';
export 'mission_address.dart';
export 'budget_info.dart';
export 'user_models.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🎯 Inkern - Modèle Mission
/// ═══════════════════════════════════════════════════════════════════════════

// ─── Statuts ─────────────────────────────────────────────────────────────────

enum MissionStatus {
  draft, // Brouillon (création en cours)
  waitingCandidates, // Publiée, aucune candidature
  candidateReceived, // ≥1 candidature reçue
  pendingAcceptance, // Réservation directe — attente d'acceptation du freelancer
  confirmed, // Freelancer accepté et payé → prêt à démarrer
  onTheWay, // Freelancer en route
  inProgress, // Mission démarrée (timer actif)
  completionRequested, // Freelancer a signalé la fin, attente action client
  completed, // Mission terminée côté exécution
  paymentHeld, // Fonds débités et sécurisés (Stripe hold)
  awaitingRelease, // Délai 24h après livraison — client peut signaler un problème
  inDispute, // Litige ouvert — paiement suspendu
  closed, // Versement effectué, archivé
  cancelled, // Annulée
  expired, // Pas de candidat dans le délai
}

extension MissionStatusX on MissionStatus {
  String get label => switch (this) {
    MissionStatus.draft => 'Brouillon',
    MissionStatus.waitingCandidates => 'En attente',
    MissionStatus.candidateReceived => 'Candidatures',
    MissionStatus.pendingAcceptance => 'Attente presta',
    MissionStatus.confirmed => 'Confirmée',
    MissionStatus.onTheWay => 'En route',
    MissionStatus.inProgress => 'En cours',
    MissionStatus.completionRequested => 'Fin demandée',
    MissionStatus.completed => 'Terminée',
    MissionStatus.paymentHeld => 'Fonds réservés',
    MissionStatus.awaitingRelease => 'Versement 24h',
    MissionStatus.inDispute => 'Litige en cours',
    MissionStatus.closed => 'Versement effectué',
    MissionStatus.cancelled => 'Annulée',
    MissionStatus.expired => 'Expirée',
  };

  Color get color => switch (this) {
    MissionStatus.draft => AppColors.draftAmber,
    MissionStatus.waitingCandidates => AppColors.warning,
    MissionStatus.candidateReceived => AppColors.secondary,
    MissionStatus.pendingAcceptance => AppColors.warning,
    MissionStatus.confirmed => AppColors.primary,
    MissionStatus.onTheWay => AppColors.primary,
    MissionStatus.inProgress => AppColors.indigo,
    MissionStatus.completionRequested => AppColors.warning,
    MissionStatus.completed => AppColors.primary,
    MissionStatus.paymentHeld => AppColors.success,
    MissionStatus.awaitingRelease => AppColors.warning,
    MissionStatus.inDispute => AppColors.error,
    MissionStatus.closed => AppColors.textTertiary,
    MissionStatus.cancelled => AppColors.error,
    MissionStatus.expired => AppColors.textTertiary,
  };

  IconData get icon => switch (this) {
    MissionStatus.draft => Icons.edit_note_rounded,
    MissionStatus.waitingCandidates => Icons.hourglass_empty_rounded,
    MissionStatus.candidateReceived => Icons.people_rounded,
    MissionStatus.pendingAcceptance => Icons.hourglass_top_rounded,
    MissionStatus.confirmed => Icons.check_circle_rounded,
    MissionStatus.onTheWay => Icons.directions_car_rounded,
    MissionStatus.inProgress => Icons.play_circle_rounded,
    MissionStatus.completionRequested => Icons.hourglass_top_rounded,
    MissionStatus.completed => Icons.done_all_rounded,
    MissionStatus.paymentHeld => Icons.lock_rounded,
    MissionStatus.awaitingRelease => Icons.schedule_rounded,
    MissionStatus.inDispute => Icons.flag_rounded,
    MissionStatus.closed => Icons.inventory_2_rounded,
    MissionStatus.cancelled => Icons.cancel_rounded,
    MissionStatus.expired => Icons.timer_off_rounded,
  };

  bool get isActive =>
      this == MissionStatus.waitingCandidates ||
      this == MissionStatus.candidateReceived ||
      this == MissionStatus.pendingAcceptance ||
      this == MissionStatus.confirmed ||
      this == MissionStatus.onTheWay ||
      this == MissionStatus.inProgress ||
      this == MissionStatus.completionRequested ||
      this == MissionStatus.completed ||
      this == MissionStatus.paymentHeld ||
      this == MissionStatus.awaitingRelease;
}

// ─── Mission ──────────────────────────────────────────────────────────────────

class Mission {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final DateTime date;
  final String timeSlot;
  final MissionAddress address;
  final BudgetInfo budget;
  final MissionStatus status;
  final List<String> images;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final ClientInfo? client;
  final PrestaInfo? assignedPresta;
  final int candidatesCount;
  final int? rating;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.date,
    required this.timeSlot,
    required this.address,
    required this.budget,
    this.status = MissionStatus.waitingCandidates,
    this.images = const [],
    required this.createdAt,
    this.updatedAt,
    this.client,
    this.assignedPresta,
    this.candidatesCount = 0,
    this.rating,
  });

  ServiceCategory? get category => ServiceCategory.findById(categoryId);
  String get categoryName => category?.name ?? 'Autre';
  IconData get categoryIcon => category?.icon ?? Icons.help_outline;
  Color get categoryColor => category?.color ?? AppColors.textTertiary;

  String get duration {
    if (budget.type == BudgetType.hourly && budget.estimatedHours != null) {
      final h = budget.estimatedHours!;
      return h == h.truncateToDouble()
          ? '${h.toInt()}h'
          : '${h.toStringAsFixed(1)}h';
    }
    return '-';
  }

  String get postedAtText {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return 'Il y a ${(diff.inDays / 7).floor()} sem.';
  }

  /// Heure de début calculée depuis date + timeSlot (ex. "14h00 - 18h00" → 14:00)
  DateTime get scheduledStart {
    if (timeSlot.isEmpty) return date;
    final startStr = timeSlot.split(' - ').first.trim(); // "14h00"
    final parts = startStr.split('h');
    if (parts.length != 2) return date;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final missionDay = DateTime(date.year, date.month, date.day);
    final diff = missionDay.difference(today).inDays;
    if (diff == 0) return 'Aujourd\'hui';
    if (diff == 1) return 'Demain';
    const mois = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    if (diff < 0) return '${date.day} ${mois[date.month - 1]}';
    if (diff < 7) {
      const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return jours[date.weekday - 1];
    }
    return '${date.day} ${mois[date.month - 1]}';
  }

  Mission copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    DateTime? date,
    String? timeSlot,
    MissionAddress? address,
    BudgetInfo? budget,
    MissionStatus? status,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    ClientInfo? client,
    PrestaInfo? assignedPresta,
    int? candidatesCount,
    int? rating,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      address: address ?? this.address,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      // Le statut change → l'horodatage de mise à jour doit suivre, sinon un
      // compte à rebours basé dessus (ex. clôture auto 24h) resterait figé
      // sur une ancienne valeur après une transition de statut locale.
      updatedAt:
          updatedAt ?? (status != null ? DateTime.now() : this.updatedAt),
      client: client ?? this.client,
      assignedPresta: assignedPresta ?? this.assignedPresta,
      candidatesCount: candidatesCount ?? this.candidatesCount,
      rating: rating ?? this.rating,
    );
  }
}
