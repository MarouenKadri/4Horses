import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/mission.dart';
import 'create_mission/create_mission_models.dart';
import '../../mission_provider.dart';
import 'create_mission/step_service.dart';
import 'create_mission/step_datetime.dart';
import 'create_mission/step_address.dart';
import 'create_mission/step_details.dart';
import 'create_mission/step_budget_type.dart';
import 'create_mission/step_tarif.dart';
import 'create_mission/step_summary.dart';
import '../../../../profile/presentation/pages/widgets/shared/payment_common_widgets.dart';
import '../../../../profile/presentation/payment_methods_provider.dart';

/// ─────────────────────────────────────────────────────────────
/// 📝 Post Mission Flow — style BlaBlaCar
///    8 pages séparées, flèche → en bas à droite
/// ─────────────────────────────────────────────────────────────
class PostMissionFlow extends StatefulWidget {
  final Mission? mission;
  final String? preAssignedFreelancerId;
  final String? preAssignedFreelancerName;
  final String? preAssignedFreelancerAvatar;

  const PostMissionFlow({
    super.key,
    this.mission,
    this.preAssignedFreelancerId,
    this.preAssignedFreelancerName,
    this.preAssignedFreelancerAvatar,
  });

  @override
  State<PostMissionFlow> createState() => _PostMissionFlowState();
}

class _PostMissionFlowState extends State<PostMissionFlow> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _submitted = false;
  MissionProvider? _providerRef;

  // Données du formulaire
  String? _selectedService;
  String? _selectedSubService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _address = '';
  String _description = '';
  List<String> _photos = [];
  String _budgetType = '';
  double _hourlyRate = 0;
  double _estimatedHours = 2;
  double _fixedBudget = 0;

  // ─── Step indices ────────────────────────────────────────
  static const int _kService    = 0;
  static const int _kDate       = 1;
  static const int _kTime       = 2;
  static const int _kAddress    = 3;
  static const int _kDetails    = 4;
  static const int _kBudgetType = 5;
  static const int _kTarif      = 6;
  String? get _resolvedPreAssignedFreelancerId {
    final raw = widget.preAssignedFreelancerId?.trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _providerRef = Provider.of<MissionProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    final m = widget.mission;
    if (m != null) {
      _selectedService = m.categoryId;
      _selectedSubService = m.title;
      _selectedDate = m.date;
      _selectedTime = _parseTimeSlot(m.timeSlot);
      _address = m.address.fullAddress;
      _description = m.description;
      _photos = List<String>.from(m.images);
      switch (m.budget.type) {
        case BudgetType.hourly:
          _budgetType = CreateBudgetType.hourly;
          _hourlyRate = m.budget.amount ?? 0;
          _estimatedHours = m.budget.estimatedHours ?? 2;
        case BudgetType.fixed:
          _budgetType = CreateBudgetType.fixed;
          _fixedBudget = m.budget.amount ?? 0;
        case BudgetType.quote:
          _budgetType = CreateBudgetType.quote;
      }
    }
  }

  @override
  void dispose() {
    _saveDraftIfNeeded();
    _pageController.dispose();
    super.dispose();
  }

  void _saveDraftIfNeeded() {
    if (_submitted || widget.mission != null || _selectedService == null) return;
    final now = DateTime.now();
    final budget = _buildBudget();
    final serviceLabel = missionServices.firstWhere(
      (s) => s['id'] == _selectedService,
      orElse: () => <String, dynamic>{'name': _selectedService ?? 'Service'},
    )['name'] as String;

    final draft = Mission(
      id: const Uuid().v4(),
      title: _selectedSubService ?? serviceLabel,
      description: _description,
      categoryId: _selectedService!,
      date: _selectedDate ?? now.add(const Duration(days: 1)),
      timeSlot: _formatTimeSlot(_selectedTime),
      address: _address.isNotEmpty
          ? MissionAddress(
              fullAddress: _address,
              shortAddress: _address.contains(',')
                  ? _address.split(',').first.trim()
                  : _address,
            )
          : const MissionAddress(fullAddress: 'Non renseignée', shortAddress: ''),
      budget: budget,
      status: MissionStatus.draft,
      images: List<String>.from(_photos),
      createdAt: now,
      candidatesCount: 0,
    );
    _providerRef?.saveDraft(draft);
  }

  TimeOfDay? _parseTimeSlot(String timeSlot) {
    if (timeSlot.isEmpty) return null;
    final part = timeSlot.split(' - ').first.trim();
    final segments = part.split('h');
    if (segments.length < 2) return null;
    final h = int.tryParse(segments[0]);
    final min = int.tryParse(segments[1]);
    if (h == null) return null;
    return TimeOfDay(hour: h, minute: min ?? 0);
  }

  String _formatTimeSlot(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}h${time.minute.toString().padLeft(2, '0')}';
  }

  BudgetInfo _buildBudget() {
    if (_budgetType == CreateBudgetType.fixed) {
      return BudgetInfo(type: BudgetType.fixed, amount: _fixedBudget);
    } else if (_budgetType == CreateBudgetType.hourly) {
      return BudgetInfo(
          type: BudgetType.hourly,
          amount: _hourlyRate,
          estimatedHours: _estimatedHours);
    }
    return const BudgetInfo(type: BudgetType.quote);
  }

  double get _totalBudget {
    if (_budgetType == CreateBudgetType.hourly) return _hourlyRate * _estimatedHours;
    if (_budgetType == CreateBudgetType.fixed) return _fixedBudget;
    return 0;
  }

  // ─── Navigation ─────────────────────────────────────────
  void _nextStep() {
    final next = _currentStep + 1;
    if (next < missionSteps.length) {
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = next);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      final prev = _currentStep - 1;
      _pageController.animateToPage(
        prev,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = prev);
    } else {
      Navigator.pop(context);
    }
  }

  bool _canContinue() {
    switch (_currentStep) {
      case _kService:
        return _selectedService != null;
      case _kDate:
        return _selectedDate != null;
      case _kTime:
        return _selectedTime != null;
      case _kAddress:
        return _address.isNotEmpty;
      case _kDetails:
        return true;
      case _kBudgetType:
        return _budgetType.isNotEmpty;
      case _kTarif:
        if (_budgetType == CreateBudgetType.hourly) {
          return _hourlyRate > 0 && _estimatedHours > 0;
        }
        if (_budgetType == CreateBudgetType.fixed) return _fixedBudget > 0;
        return true;
      default:
        return true;
    }
  }

  // ─── Build ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentStep == missionSteps.length - 1;
    final serviceLabel = missionServices.firstWhere(
      (s) => s['id'] == _selectedService,
      orElse: () => <String, dynamic>{'name': 'Nouvelle mission'},
    )['name'] as String;
    final headerTitle = widget.mission != null
        ? (_selectedSubService ?? serviceLabel)
        : (_selectedSubService ?? (_selectedService != null ? serviceLabel : 'Nouvelle mission'));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      body: AppPageBody(
        useSafeAreaTop: true,
        child: Column(
          children: [
            AppFlowHeader(
              title: headerTitle,
              onBack: _previousStep,
              trailing: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.textSecondary,
                  textStyle: context.text.bodyMedium,
                ),
                child: const Text('Annuler'),
              ),
            ),
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                // 0 — Service
                StepService(
                  services: missionServices,
                  selectedService: _selectedService,
                  selectedSubService: _selectedSubService,
                  onServiceSelected: (service, sub) {
                    setState(() {
                      _selectedService = service;
                      _selectedSubService = sub;
                    });
                  },
                  onCompleted: _nextStep,
                ),
                // 1 — Date
                StepDate(
                  selectedDate: _selectedDate,
                  onDateSelected: (d) => setState(() => _selectedDate = d),
                  onCompleted: _nextStep,
                ),
                // 2 — Heure
                StepTime(
                  selectedDate: _selectedDate,
                  selectedTime: _selectedTime,
                  onTimeSelected: (t) => setState(() => _selectedTime = t),
                  onCompleted: _nextStep,
                ),
                // 3 — Adresse
                StepAddress(
                  address: _address,
                  onAddressChanged: (v) => setState(() => _address = v),
                ),
                // 4 — Détails
                StepDetails(
                  description: _description,
                  photos: _photos,
                  onDescriptionChanged: (v) =>
                      setState(() => _description = v),
                  onPhotosChanged: (p) => setState(() => _photos = p),
                ),
                // 5 — Type de budget
                StepBudgetType(
                  budgetType: _budgetType,
                  onBudgetTypeChanged: (t) =>
                      setState(() => _budgetType = t),
                  onCompleted: _nextStep,
                ),
                // 6 — Tarif
                StepTarif(
                  budgetType: _budgetType,
                  hourlyRate: _hourlyRate,
                  estimatedHours: _estimatedHours,
                  fixedBudget: _fixedBudget,
                  onHourlyRateChanged: (r) =>
                      setState(() => _hourlyRate = r),
                  onEstimatedHoursChanged: (h) =>
                      setState(() => _estimatedHours = h),
                  onFixedBudgetChanged: (b) =>
                      setState(() => _fixedBudget = b),
                ),
                // 7 — Récapitulatif
                StepSummary(
                  service: _selectedService,
                  subService: _selectedSubService,
                  date: _selectedDate,
                  time: _selectedTime,
                  address: _address,
                  description: _description,
                  photos: _photos,
                  budgetType: _budgetType,
                  totalBudget: _totalBudget,
                  estimatedHours: _estimatedHours,
                  services: missionServices,
                  isEdit: widget.mission != null,
                ),
                ],
              ),
            ),
            _buildBottomNav(isLastStep),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return AppSection(
      color: context.colors.surface,
      padding: EdgeInsets.zero,
      child: AppProgressBar(
        currentStep: _currentStep + 1,
        totalSteps: missionSteps.length,
        stepLabel: missionSteps[_currentStep],
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      ),
    );
  }

  Widget _buildBottomNav(bool isLastStep) {
    final canGo = _canContinue();

    if (isLastStep) {
      return AppActionFooter(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: AppButton(
            label: widget.mission != null &&
                    widget.mission!.status != MissionStatus.draft
                ? 'Enregistrer les modifications'
                : 'Publier la mission',
            variant: ButtonVariant.black,
            onPressed: _submitMission,
          ),
        ),
      );
    }

    return AppActionFooter(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Continuer',
              variant: ButtonVariant.black,
              onPressed: canGo ? _nextStep : null,
            ),
          ),
          AppGap.h10,
          Text(
            'Paiement securise. Aucun debit avant la fin de la mission.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: context.colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitMission() async {
    final isEdit = widget.mission != null;
    final original = widget.mission;
    final isPublishingDraft =
        isEdit && original!.status == MissionStatus.draft;
    final now = DateTime.now();
    final preAssignedFreelancerId = _resolvedPreAssignedFreelancerId;
    final hasPreAssignedFreelancer = preAssignedFreelancerId != null;

    final budget = _buildBudget();
    final serviceLabel = missionServices
        .firstWhere((s) => s['id'] == _selectedService,
            orElse: () =>
                <String, dynamic>{'name': _selectedService ?? 'Service'})
        ['name'] as String;

    final mission = Mission(
      id: isEdit ? original!.id : const Uuid().v4(),
      title: _selectedSubService ?? serviceLabel,
      description: _description.isNotEmpty
          ? _description
          : 'Mission créée via l\'application.',
      categoryId: _selectedService ?? 'menage',
      date: _selectedDate ?? now.add(const Duration(days: 1)),
      timeSlot: _formatTimeSlot(_selectedTime),
      address: MissionAddress(
        fullAddress: _address,
        shortAddress: _address.contains(',')
            ? _address.split(',').first.trim()
            : _address,
      ),
      budget: budget,
      status: (isEdit && !isPublishingDraft)
          ? original!.status
          : hasPreAssignedFreelancer
              ? MissionStatus.confirmed
              : MissionStatus.waitingCandidates,
      images: List<String>.from(_photos),
      createdAt: isEdit ? original!.createdAt : now,
      candidatesCount: isEdit ? original!.candidatesCount : 0,
      client: isEdit ? original!.client : null,
      assignedPresta: isEdit
          ? original!.assignedPresta
          : hasPreAssignedFreelancer
              ? PrestaInfo(
                  id: preAssignedFreelancerId,
                  name: widget.preAssignedFreelancerName ?? '',
                  avatarUrl: widget.preAssignedFreelancerAvatar ?? '',
                )
              : null,
      rating: isEdit ? original!.rating : null,
    );

    _submitted = true;
    try {
      if (isPublishingDraft) {
        await context.read<MissionProvider>().publishDraft(mission);
      } else if (isEdit) {
        await context.read<MissionProvider>().updateMission(mission);
      } else {
        await context.read<MissionProvider>().publishMission(mission);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _submitted = false);
        showAppSnackBar(
          context,
          'Erreur lors de la création de la mission. Réessayez.',
          type: SnackBarType.error,
        );
      }
      return;
    }

    if (!mounted) return;

    if (!isEdit && hasPreAssignedFreelancer) {
      final paid = await showAppBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        wrapWithSurface: false,
        child: _MissionPaymentSheet(
          freelancerName: widget.preAssignedFreelancerName ?? '',
          freelancerAvatar: widget.preAssignedFreelancerAvatar ?? '',
          missionTitle: mission.title,
          amount: mission.budget.amount ?? _totalBudget,
        ),
      );
      if (paid != true || !mounted) {
        setState(() => _submitted = false);
        return;
      }
    }

    if (!mounted) return;
    final title = mission.title;
    Navigator.pop(context, isEdit && !isPublishingDraft ? null : 'published:${mission.id}:$title');
  }
}

// ─── Payment sheet (même flux que CandidatesPage) ────────────────────────────

class _MissionPaymentSheet extends StatefulWidget {
  final String freelancerName;
  final String freelancerAvatar;
  final String missionTitle;
  final double amount;

  const _MissionPaymentSheet({
    required this.freelancerName,
    required this.freelancerAvatar,
    required this.missionTitle,
    required this.amount,
  });

  @override
  State<_MissionPaymentSheet> createState() => _MissionPaymentSheetState();
}

class _MissionPaymentSheetState extends State<_MissionPaymentSheet> {
  bool _isProcessing = false;
  int? _selectedCardIdx;

  double get _presta => widget.amount * 0.9;
  double get _cigale => widget.amount * 0.1;

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
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final cards = context.watch<PaymentMethodsProvider>().cards;
    final defaultIdx = cards.indexWhere((c) => c.isDefault);
    final selectedIdx = (_selectedCardIdx ?? defaultIdx).clamp(0, cards.isEmpty ? 0 : cards.length - 1);
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
          Text(
            'Finaliser le paiement',
            style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          AppGap.h2,
          Text(
            widget.missionTitle,
            style: context.text.bodySmall?.copyWith(color: context.colors.textTertiary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppGap.h16,
          // ─── Freelancer ───
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
                  child: widget.freelancerAvatar.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(widget.freelancerAvatar, fit: BoxFit.cover),
                        )
                      : Center(
                          child: Text(
                            widget.freelancerName.isNotEmpty
                                ? widget.freelancerName[0].toUpperCase()
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
                        widget.freelancerName,
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
                      '${widget.amount.round()} €',
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
                _PayRow(
                  icon: Icons.handyman_outlined,
                  label: 'Prestataire (90 %)',
                  amount: '${_presta.round()} €',
                  amountColor: AppColors.ink,
                ),
                Divider(height: 1, indent: 68, color: context.colors.divider),
                _PayRow(
                  icon: Icons.percent_rounded,
                  label: 'Commission (10 %)',
                  amount: '${_cigale.round()} €',
                  amountColor: context.colors.textTertiary,
                ),
              ],
            ),
          ),
          AppGap.h16,
          // ─── Cartes ───
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
                ...cards.asMap().entries.expand((entry) => [
                  InkWell(
                    onTap: () => setState(() => _selectedCardIdx = entry.key),
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
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
                            child: const Icon(Icons.credit_card_rounded, size: 18, color: AppColors.textSecondary),
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
                                  style: context.text.bodySmall?.copyWith(color: context.colors.textTertiary),
                                ),
                              ],
                            ),
                          ),
                          if (selectedIdx == entry.key)
                            const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.ink)
                          else
                            Icon(Icons.radio_button_unchecked, size: 18, color: context.colors.textHint),
                        ],
                      ),
                    ),
                  ),
                  if (entry.key < cards.length - 1)
                    Divider(height: 1, indent: 68, color: context.colors.divider),
                ]),
              ],
            ),
          ),
          AppGap.h8,
          PaymentAddButton(label: 'Ajouter une carte', onTap: _showAddCardDialog),
          AppGap.h12,
          const PaymentInfoNote(
            icon: Icons.shield_outlined,
            body: 'Montant bloqué — libéré au prestataire uniquement après votre validation.',
          ),
          AppGap.h20,
          AppButton(
            label: 'Payer ${widget.amount.round()} €',
            variant: ButtonVariant.black,
            isLoading: _isProcessing,
            onPressed: _isProcessing ? null : _pay,
          ),
          AppGap.h10,
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded, size: 12, color: context.colors.textHint),
                AppGap.w4,
                Text(
                  'Paiement sécurisé',
                  style: context.text.labelSmall?.copyWith(color: context.colors.textHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color amountColor;

  const _PayRow({
    required this.icon,
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            child: Icon(icon, size: 18, color: context.colors.textSecondary),
          ),
          AppGap.w12,
          Expanded(
            child: Text(
              label,
              style: context.text.bodyMedium?.copyWith(color: context.colors.textPrimary),
            ),
          ),
          Text(
            amount,
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
