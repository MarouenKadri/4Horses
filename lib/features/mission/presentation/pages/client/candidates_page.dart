import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/candidate.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
import '../../../../notifications/notification_provider.dart';
import '../../../../notifications/data/models/app_notification.dart';
import '../../../../client/presentation/pages/freelancer_profile_view.dart';
import '../../../../profile/presentation/pages/widgets/shared/payment_common_widgets.dart';
import '../../../../profile/presentation/payment_methods_provider.dart';

class CandidatesPage extends StatefulWidget {
  final String missionId;
  final String missionTitle;
  final String missionBudget;

  const CandidatesPage({
    super.key,
    required this.missionId,
    required this.missionTitle,
    required this.missionBudget,
  });

  @override
  State<CandidatesPage> createState() => _CandidatesPageState();
}

class _CandidatesPageState extends State<CandidatesPage> {
  List<Candidate> _candidates = [];
  bool _hasAcceptedCandidate = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    try {
      final rows = await context.read<MissionProvider>().fetchCandidates(
        widget.missionId,
      );
      if (!mounted) return;
      setState(() {
        _candidates = rows.map(_candidateFromRow).toList();
        _hasAcceptedCandidate = _candidates.any(
          (c) => c.status == CandidateStatus.accepte,
        );
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _candidates = [];
        _hasAcceptedCandidate = false;
        _isLoading = false;
      });
    }
  }

  static CandidateStatus _candidateStatusFromDb(String s) => switch (s) {
    'en_attente' => CandidateStatus.enAttente,
    'accepte' => CandidateStatus.accepte,
    'refuse' => CandidateStatus.refuse,
    _ => CandidateStatus.enAttente,
  };

  static Candidate _candidateFromRow(Map<String, dynamic> row) {
    final f = row['freelancer'] is Map
        ? Map<String, dynamic>.from(row['freelancer'] as Map)
        : <String, dynamic>{};
    final createdAt = DateTime.tryParse(
      (row['applied_at'] ?? row['created_at'] ?? '').toString(),
    );
    String appliedAt = 'À l\'instant';
    if (createdAt != null) {
      final diff = DateTime.now().difference(createdAt);
      if (diff.inMinutes < 1) {
        appliedAt = 'À l\'instant';
      } else if (diff.inMinutes < 60) {
        appliedAt = 'Il y a ${diff.inMinutes} min';
      } else if (diff.inHours < 24) {
        appliedAt = 'Il y a ${diff.inHours}h';
      } else {
        appliedAt = 'Il y a ${diff.inDays}j';
      }
    }
    final price = _asDouble(row['proposed_price']);
    final statusStr = (row['status'] ?? 'en_attente').toString();
    final firstName = (f['first_name'] ?? '').toString().trim();
    final lastName = (f['last_name'] ?? '').toString().trim();
    final fullName = '$firstName $lastName'.trim();

    return Candidate(
      id: (row['freelancer_id'] ?? row['id'] ?? '').toString(),
      name: fullName.isNotEmpty ? fullName : 'Prestataire',
      avatar: (f['avatar_url'] ?? '').toString(),
      rating: _asDouble(f['rating']),
      reviewsCount: _asInt(f['reviews_count']),
      proposedPrice: price > 0 ? '${price.toInt()} €' : 'Devis',
      message: (row['message'] ?? '').toString(),
      skills: const [],
      responseTime: '',
      completedMissions: _asInt(f['completed_missions']),
      isVerified: f['is_verified'] as bool? ?? false,
      appliedAt: appliedAt,
      status: _candidateStatusFromDb(statusStr),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? ''}') ?? 0;
  }

  /// ─── Accepter un candidat → paiement direct ───
  void _acceptCandidate(Candidate candidate) {
    _confirmAcceptance(candidate);
  }

  /// Lance le flow de paiement après confirmation du candidat
  void _confirmAcceptance(Candidate candidate) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: _PaymentSheet(
        candidate: candidate,
        missionTitle: widget.missionTitle,
        onPaymentSuccess: () => _finalizeAcceptance(candidate),
      ),
    );
  }

  /// Finalise l'acceptation après paiement réussi
  void _finalizeAcceptance(Candidate acceptedCandidate) {
    // Convertir le candidat en PrestaInfo et accepter (status confirmed + assignedPresta)
    final presta = PrestaInfo(
      id: acceptedCandidate.id,
      name: acceptedCandidate.name,
      avatarUrl: acceptedCandidate.avatar,
      rating: acceptedCandidate.rating,
      reviewsCount: acceptedCandidate.reviewsCount,
      completedMissions: acceptedCandidate.completedMissions,
      isVerified: acceptedCandidate.isVerified,
      acceptedPrice: acceptedCandidate.proposedPrice,
    );
    context.read<MissionProvider>().acceptCandidate(widget.missionId, presta);

    // Notifier le prestataire via Supabase — il recevra via Realtime
    context.read<NotificationProvider>().sendNotification(
      acceptedCandidate.id,
      type: NotifType.candidature,
      title: 'Candidature acceptée !',
      body: 'Votre candidature pour "${widget.missionTitle}" a été acceptée.',
      avatarUrl: acceptedCandidate.avatar,
    );

    setState(() {
      _hasAcceptedCandidate = true;
      for (var candidate in _candidates) {
        if (candidate.id == acceptedCandidate.id) {
          candidate.status = CandidateStatus.accepte;
        } else {
          candidate.status = CandidateStatus.refuse;
        }
      }
      _candidates.sort((a, b) {
        if (a.status == CandidateStatus.accepte) return -1;
        if (b.status == CandidateStatus.accepte) return 1;
        return 0;
      });
    });
  }

  int _statusRank(CandidateStatus status) => switch (status) {
    CandidateStatus.enAttente => 0,
    CandidateStatus.accepte => 1,
    CandidateStatus.refuse => 2,
  };

  double? _extractPrice(String raw) {
    final normalized = raw.replaceAll(',', '.');
    final parsed = double.tryParse(
      normalized.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  String _formatPrice(double value) {
    if (value % 1 == 0) return '${value.toInt()} €';
    return '${value.toStringAsFixed(1)} €';
  }

  String get _bestPriceLabel {
    final prices = _candidates
        .map((c) => _extractPrice(c.proposedPrice))
        .whereType<double>()
        .toList();
    if (prices.isEmpty) return 'Devis';
    prices.sort();
    return _formatPrice(prices.first);
  }

  List<Candidate> get _sortedCandidates {
    final sorted = List<Candidate>.from(_candidates);
    sorted.sort(
      (a, b) => _statusRank(a.status).compareTo(_statusRank(b.status)),
    );
    return sorted;
  }

  Widget _buildSummaryMetric({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: context.colors.textTertiary,
              letterSpacing: 0.2,
            ),
          ),
          AppGap.h4,
          Text(
            value,
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor ?? context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offersCount = _candidates.length;
    final pendingCount = _candidates
        .where((c) => c.status == CandidateStatus.enAttente)
        .length;
    final displayCandidates = _sortedCandidates;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.snow,
      appBar: AppPageAppBar(
        title: 'Offres reçues',
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.missionTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.missionEntityNameStyle.copyWith(
                      fontSize: AppFontSize.title,
                    ),
                  ),
                  AppGap.h2,
                  Text(
                    'Liste des offres reçues pour cette mission',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  AppGap.h16,
                  Row(
                    children: [
                      _buildSummaryMetric(
                        label: 'Offres',
                        value: '$offersCount',
                      ),
                      _buildSummaryMetric(
                        label: 'Meilleur',
                        value: _bestPriceLabel,
                      ),
                      _buildSummaryMetric(
                        label: 'En attente',
                        value: '$pendingCount',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ─── Message si accepté ───
          if (_hasAcceptedCandidate)
            AppSurfaceCard(
              margin: AppInsets.a16,
              padding: AppInsets.a12,
              color: context.colors.successLight,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Text(
                      'Vous avez choisi votre prestataire ! Contactez-le pour finaliser les détails.',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ─── Liste des candidats ───
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  )
                : displayCandidates.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 56,
                          color: context.colors.textHint,
                        ),
                        AppGap.h12,
                        Text(
                          'Aucune offre pour l\'instant',
                          style: context.text.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      _hasAcceptedCandidate ? 8 : 18,
                      16,
                      100,
                    ),
                    itemCount: displayCandidates.length,
                    separatorBuilder: (_, __) => AppGap.h12,
                    itemBuilder: (context, index) => _CandidateCard(
                      candidate: displayCandidates[index],
                      onAccept: _hasAcceptedCandidate
                          ? null
                          : () => _acceptCandidate(displayCandidates[index]),
                      onTap: () => _openProfile(displayCandidates[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _openProfile(Candidate candidate) {
    final isPending =
        candidate.status == CandidateStatus.enAttente && !_hasAcceptedCandidate;
    final isAccepted = candidate.status == CandidateStatus.accepte;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FreelancerProfileView(
          freelancerId: candidate.id,
          freelancerName: candidate.name,
          freelancerAvatar: candidate.avatar,
          rating: candidate.rating,
          reviewsCount: candidate.reviewsCount,
          missionsCount: candidate.completedMissions,
          proposedPrice: candidate.proposedPrice,
          contactMode: isPending
              ? FreelancerContactMode.pendingCandidate
              : isAccepted
              ? FreelancerContactMode.confirmedPresta
              : FreelancerContactMode.spontaneous,
          candidatePrice: candidate.proposedPrice,
          onCandidateAccepted: isPending
              ? () => _acceptCandidate(candidate)
              : null,
          confirmedMissionTitle: isAccepted ? widget.missionTitle : null,
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 🎴 Carte Candidat
/// ─────────────────────────────────────────────────────────────
class _CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final VoidCallback? onAccept;
  final VoidCallback onTap;

  const _CandidateCard({
    required this.candidate,
    required this.onAccept,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAccepted = candidate.status == CandidateStatus.accepte;
    final isRejected = candidate.status == CandidateStatus.refuse;
    final isPending = candidate.status == CandidateStatus.enAttente;
    final canAccept = onAccept != null && isPending;
    final messagePreview = candidate.message.trim().isEmpty
        ? 'Aucun message ajoute.'
        : candidate.message.trim();

    return Opacity(
      opacity: isRejected ? 0.52 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: isAccepted
              ? Border.all(color: AppColors.ink, width: 1.0)
              : Border.all(color: AppColors.gray50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.016),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.blackAlpha07,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 29,
                          backgroundColor: AppColors.gray50,
                          backgroundImage: candidate.avatar.isNotEmpty
                              ? NetworkImage(candidate.avatar)
                              : null,
                          onBackgroundImageError: candidate.avatar.isNotEmpty
                              ? (_, __) {}
                              : null,
                          child: candidate.avatar.isEmpty
                              ? const Icon(
                                  Icons.person_outline_rounded,
                                  color: AppColors.gray400,
                                )
                              : null,
                        ),
                      ),
                      AppGap.w14,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    candidate.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.missionEntityNameStyle
                                        .copyWith(fontSize: AppFontSize.title),
                                  ),
                                ),
                                _OfferStatusChip(status: candidate.status),
                              ],
                            ),
                            AppGap.h6,
                            Text(
                              '★ ${candidate.rating.toStringAsFixed(1)} · ${candidate.reviewsCount} avis',
                              style: context.text.bodySmall?.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppGap.h16,
                  Text(
                    'Tarif proposé',
                    style: context.text.labelSmall?.copyWith(
                      color: context.colors.textTertiary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  AppGap.h4,
                  Text(
                    candidate.proposedPrice,
                    style: context.text.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  AppGap.h12,
                  Text(
                    messagePreview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      height: 1.5,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  AppGap.h14,
                  Row(
                    children: [
                      Text(
                        candidate.appliedAt,
                        style: context.text.labelSmall?.copyWith(
                          color: context.colors.textHint,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: onTap,
                        style: TextButton.styleFrom(
                          foregroundColor: context.colors.textPrimary,
                          textStyle: context.text.labelLarge,
                        ),
                        child: const Text('Voir profil'),
                      ),
                      if (canAccept) ...[
                        AppGap.w8,
                        IntrinsicWidth(
                          child: AppButton(
                            label: 'Accepter',
                            variant: ButtonVariant.black,
                            height: 38,
                            width: null,
                            onPressed: onAccept,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferStatusChip extends StatelessWidget {
  final CandidateStatus status;

  const _OfferStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      CandidateStatus.enAttente => (
        'EN ATTENTE',
        AppColors.gray50,
        AppColors.gray600,
      ),
      CandidateStatus.accepte => (
        'CHOISIE',
        AppColors.successLight,
        AppColors.successDark,
      ),
      CandidateStatus.refuse => (
        'REFUSÉE',
        AppColors.gray50,
        AppColors.gray400,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bg.withValues(alpha: 0.9)),
      ),
      child: Text(
        label,
        style: context.missionSectionLabelStyle.copyWith(
          fontSize: AppFontSize.tiny,
          color: fg,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 💳 Sheet de paiement — blocage du montant
/// ─────────────────────────────────────────────────────────────
class _PaymentSheet extends StatefulWidget {
  final Candidate candidate;
  final String missionTitle;
  final VoidCallback onPaymentSuccess;

  const _PaymentSheet({
    required this.candidate,
    required this.missionTitle,
    required this.onPaymentSuccess,
  });

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  bool _isProcessing = false;
  int? _selectedCardIdx;

  double get _amount =>
      double.tryParse(
        widget.candidate.proposedPrice.replaceAll(RegExp(r'[^0-9.]'), ''),
      ) ??
      0;
  double get _presta => _amount * 0.9;
  double get _cigale => _amount * 0.1;

  void _showAddCardDialog() {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: AddCardSheet(
        onCardAdded: (brand, last4, expiry) {
          context.read<PaymentMethodsProvider>().addCard(
            brand: brand,
            last4: last4,
            expiry: expiry,
          );
          final cards = context.read<PaymentMethodsProvider>().cards;
          setState(() => _selectedCardIdx = cards.length - 1);
        },
      ),
    );
  }

  Future<void> _pay() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    Navigator.pop(context);
    widget.onPaymentSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final cards = context.watch<PaymentMethodsProvider>().cards;
    final defaultIdx = cards.indexWhere((c) => c.isDefault);
    final selectedIdx = (_selectedCardIdx ?? defaultIdx).clamp(
      0,
      cards.isEmpty ? 0 : cards.length - 1,
    );
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Handle ───
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ─── Titre ───
          Text(
            'Finaliser le paiement',
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          AppGap.h2,
          Text(
            widget.missionTitle,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          AppGap.h16,

          // ─── Candidat ───
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.colors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: widget.candidate.avatar.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.candidate.avatar,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(
                            widget.candidate.name.isNotEmpty
                                ? widget.candidate.name[0].toUpperCase()
                                : '?',
                            style: context.text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                ),
                AppGap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.candidate.name,
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      AppGap.h2,
                      Text(
                        'Prestataire sélectionné',
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_amount.round()} €',
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      'Total TTC',
                      style: context.text.labelSmall?.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          AppGap.h16,

          // ─── Répartition ───
          const PaymentSectionLabel('RÉPARTITION'),
          AppGap.h8,
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: [
                _RepartitionRow(
                  icon: Icons.handyman_outlined,
                  label: 'Prestataire (90 %)',
                  amount: '${_presta.round()} €',
                  amountColor: AppColors.ink,
                  context: context,
                ),
                Divider(height: 1, indent: 68, color: context.colors.divider),
                _RepartitionRow(
                  icon: Icons.percent_rounded,
                  label: 'Commission (10 %)',
                  amount: '${_cigale.round()} €',
                  amountColor: context.colors.textTertiary,
                  context: context,
                ),
              ],
            ),
          ),

          AppGap.h16,

          // ─── Cartes (depuis PaymentMethodsProvider) ───
          const PaymentSectionLabel('CARTE DE PAIEMENT'),
          AppGap.h8,
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: [
                ...cards.asMap().entries.expand(
                  (entry) => [
                    InkWell(
                      onTap: () => setState(() => _selectedCardIdx = entry.key),
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: context.colors.surfaceAlt,
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                  color: context.colors.border,
                                ),
                              ),
                              child: const Icon(
                                Icons.credit_card_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            AppGap.w12,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.value.brand} •••• ${entry.value.last4}',
                                    style: context.text.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                  AppGap.h2,
                                  Text(
                                    'Expire ${entry.value.expiry}',
                                    style: context.text.bodySmall?.copyWith(
                                      color: context.colors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selectedIdx == entry.key)
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: AppColors.ink,
                              )
                            else
                              Icon(
                                Icons.radio_button_unchecked,
                                size: 18,
                                color: context.colors.textHint,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (entry.key < cards.length - 1)
                      Divider(
                        height: 1,
                        indent: 68,
                        color: context.colors.divider,
                      ),
                  ],
                ),
              ],
            ),
          ),

          AppGap.h8,
          PaymentAddButton(
            label: 'Ajouter une carte',
            onTap: _showAddCardDialog,
          ),
          AppGap.h12,
          const PaymentInfoNote(
            icon: Icons.shield_outlined,
            body:
                'Montant bloqué — libéré au prestataire uniquement après votre validation.',
          ),
          AppGap.h20,

          // ─── CTA ───
          AppButton(
            label: 'Payer ${_amount.round()} €',
            variant: ButtonVariant.black,
            isLoading: _isProcessing,
            onPressed: _isProcessing ? null : _pay,
          ),
          AppGap.h10,
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 12,
                  color: context.colors.textHint,
                ),
                AppGap.w4,
                Text(
                  'Paiement sécurisé',
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RepartitionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color amountColor;
  final BuildContext context;

  const _RepartitionRow({
    required this.icon,
    required this.label,
    required this.amount,
    required this.amountColor,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ctx.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: ctx.colors.border),
            ),
            child: Icon(icon, size: 18, color: ctx.colors.textSecondary),
          ),
          AppGap.w12,
          Expanded(
            child: Text(
              label,
              style: ctx.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            amount,
            style: ctx.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// 📊 Carte Stat
/// ─────────────────────────────────────────────────────────────
