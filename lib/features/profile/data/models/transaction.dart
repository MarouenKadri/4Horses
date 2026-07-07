import 'package:flutter/material.dart';
import '../../../../core/design/app_design_system.dart';

/// Types de transaction
enum TransactionType {
  income, // Paiement reçu (versé)
  held, // Fonds sécurisés en attente de versement
  released, // Versement libéré après délai 24h
  withdrawal, // Retrait vers compte bancaire
  refund, // Remboursement
  fee, // Frais de service
  bonus, // Bonus/Prime
}

extension TransactionTypeExtension on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Paiement reçu';
      case TransactionType.held:
        return 'En attente de versement';
      case TransactionType.released:
        return 'Versement libéré';
      case TransactionType.withdrawal:
        return 'Retrait';
      case TransactionType.refund:
        return 'Remboursement';
      case TransactionType.fee:
        return 'Frais de service';
      case TransactionType.bonus:
        return 'Bonus';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.income:
        return Icons.arrow_downward_rounded;
      case TransactionType.held:
        return Icons.lock_clock_rounded;
      case TransactionType.released:
        return Icons.lock_open_rounded;
      case TransactionType.withdrawal:
        return Icons.arrow_upward_rounded;
      case TransactionType.refund:
        return Icons.replay_rounded;
      case TransactionType.fee:
        return Icons.receipt_long_rounded;
      case TransactionType.bonus:
        return Icons.card_giftcard_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.income:
        return AppColors.success;
      case TransactionType.held:
        return AppColors.warning;
      case TransactionType.released:
        return AppColors.success;
      case TransactionType.withdrawal:
        return AppColors.info;
      case TransactionType.refund:
        return AppColors.warning;
      case TransactionType.fee:
        return AppColors.error;
      case TransactionType.bonus:
        return AppColors.primaryDark;
    }
  }

  bool get isPositive {
    switch (this) {
      case TransactionType.income:
      case TransactionType.held:
      case TransactionType.released:
      case TransactionType.refund:
      case TransactionType.bonus:
        return true;
      case TransactionType.withdrawal:
      case TransactionType.fee:
        return false;
    }
  }
}

/// Statut de transaction
enum TransactionStatus {
  completed, // Versement effectué
  held, // Fonds sécurisés (Stripe hold)
  awaitingRelease, // Délai 24h en cours
  inDispute, // Litige — versement suspendu
  pending, // En cours de traitement
  failed, // Échoué
}

extension TransactionStatusExtension on TransactionStatus {
  String get label {
    switch (this) {
      case TransactionStatus.completed:
        return 'Effectué';
      case TransactionStatus.held:
        return 'Fonds sécurisés';
      case TransactionStatus.awaitingRelease:
        return 'Versement sous 24h';
      case TransactionStatus.inDispute:
        return 'Litige en cours';
      case TransactionStatus.pending:
        return 'En cours';
      case TransactionStatus.failed:
        return 'Échoué';
    }
  }

  Color get color {
    switch (this) {
      case TransactionStatus.completed:
        return AppColors.success;
      case TransactionStatus.held:
        return AppColors.warning;
      case TransactionStatus.awaitingRelease:
        return AppColors.warning;
      case TransactionStatus.inDispute:
        return AppColors.error;
      case TransactionStatus.pending:
        return AppColors.warning;
      case TransactionStatus.failed:
        return AppColors.error;
    }
  }
}

/// Modèle de transaction
class Transaction {
  final String id;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final DateTime date;
  final String? description;
  final String? missionTitle;
  final String? clientName;
  final String? paymentMethod;

  Transaction({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.date,
    this.description,
    this.missionTitle,
    this.clientName,
    this.paymentMethod,
  });
}
