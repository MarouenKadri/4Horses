import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/app_bar/app_section_bar.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
import '../../widgets/cards/variants/mission_browse_card.dart';
import '../../widgets/shared/mission_shared_widgets.dart';
import 'freelancer_mission_detail_page.dart';

enum PublisherType { particulier, agence }

enum _MissionDateFilter { all, today, thisWeek, thisMonth }

enum _MissionBudgetFilter { all, under50, from50To150, from150To300, over300, quote }

class MissionBrowsePage extends StatefulWidget {
  final List<Mission>? missions;
  final bool showAppBar;
  final String? locationLabel;
  final VoidCallback? onLocationTap;
  final String? initialCategoryId;
  final PublisherType? publisherType;

  const MissionBrowsePage({
    super.key,
    this.missions,
    this.showAppBar = false,
    this.locationLabel,
    this.onLocationTap,
    this.initialCategoryId,
    this.publisherType,
  });

  @override
  State<MissionBrowsePage> createState() => _MissionBrowsePageState();
}

class _MissionBrowsePageState extends State<MissionBrowsePage> {
  late String? _selectedCategoryId;
  bool _showAppliedOnly = false;
  _MissionDateFilter _selectedDateFilter = _MissionDateFilter.all;
  _MissionBudgetFilter _selectedBudgetFilter = _MissionBudgetFilter.all;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
  }

  List<Mission> _filtered(List<Mission> all, Set<String> appliedIds) {
    var list = all
        .where((m) =>
            m.status == MissionStatus.waitingCandidates ||
            m.status == MissionStatus.candidateReceived)
        .toList();

    if (_selectedCategoryId != null) {
      list = list.where((m) => m.categoryId == _selectedCategoryId).toList();
    }

    if (_showAppliedOnly) {
      list = list.where((m) => appliedIds.contains(m.id)).toList();
    }

    if (widget.publisherType != null) {
      list = list.where((m) {
        final isAgency = _isAgencyMission(m);
        return widget.publisherType == PublisherType.agence ? isAgency : !isAgency;
      }).toList();
    }

    if (_selectedDateFilter != _MissionDateFilter.all) {
      list = list.where(_matchesDateFilter).toList();
    }

    if (_selectedBudgetFilter != _MissionBudgetFilter.all) {
      list = list.where(_matchesBudgetFilter).toList();
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int rank(Mission mission) {
      final day = DateTime(mission.date.year, mission.date.month, mission.date.day);
      if (day == today) return 0;
      if (day.isAfter(today)) return 1;
      return 2;
    }

    list.sort((a, b) {
      final rankCmp = rank(a).compareTo(rank(b));
      if (rankCmp != 0) return rankCmp;
      return rank(a) == 1 ? a.date.compareTo(b.date) : b.date.compareTo(a.date);
    });

    return list;
  }

  bool _matchesDateFilter(Mission mission) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final missionDay = DateTime(
      mission.date.year,
      mission.date.month,
      mission.date.day,
    );

    return switch (_selectedDateFilter) {
      _MissionDateFilter.all => true,
      _MissionDateFilter.today => missionDay == today,
      _MissionDateFilter.thisWeek =>
        !missionDay.isBefore(today) &&
        missionDay.difference(today).inDays <= 7,
      _MissionDateFilter.thisMonth =>
        missionDay.year == today.year && missionDay.month == today.month,
    };
  }

  bool _matchesBudgetFilter(Mission mission) {
    final amount = mission.budget.totalAmount;
    return switch (_selectedBudgetFilter) {
      _MissionBudgetFilter.all => true,
      _MissionBudgetFilter.quote => mission.budget.type == BudgetType.quote,
      _MissionBudgetFilter.under50 => amount > 0 && amount < 50,
      _MissionBudgetFilter.from50To150 => amount >= 50 && amount <= 150,
      _MissionBudgetFilter.from150To300 => amount > 150 && amount <= 300,
      _MissionBudgetFilter.over300 => amount > 300,
    };
  }

  bool _isAgencyMission(Mission mission) {
    final rawName = mission.client?.name.trim().toLowerCase() ?? '';
    const agencyTokens = [
      'agence', 'agency', 'sarl', 'sas', 'sasu', 'eurl',
      'entreprise', 'societe', 'société', 'groupe', 'holding',
      'studio', 'cabinet', 'immobilier',
    ];
    return agencyTokens.any(rawName.contains);
  }

  Future<void> _refresh() async {
    await context.read<MissionProvider>().refresh();
  }

  void _resetFilters() {
    _selectedCategoryId = widget.initialCategoryId;
    _showAppliedOnly = false;
    _selectedDateFilter = _MissionDateFilter.all;
    _selectedBudgetFilter = _MissionBudgetFilter.all;
  }

  bool get _hasActiveFilters =>
      _selectedCategoryId != null ||
      _showAppliedOnly ||
      _selectedDateFilter != _MissionDateFilter.all ||
      _selectedBudgetFilter != _MissionBudgetFilter.all;

  String get _headerTitle {
    if (widget.initialCategoryId != null) {
      return ServiceCategory.findById(widget.initialCategoryId!)?.name ?? 'Missions';
    }
    return switch (widget.publisherType) {
      PublisherType.particulier => 'Particulier',
      PublisherType.agence => 'Agence',
      null => 'Missions',
    };
  }

  @override
  Widget build(BuildContext context) {
    final missionProvider = context.watch<MissionProvider>();
    final isLoading = missionProvider.isLoading;
    final allMissions = missionProvider.publicMissions;
    final appliedIds = missionProvider.freelancerMissions
        .map((m) => m.id)
        .toSet();
    final filtered = _filtered(allMissions, appliedIds);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    bool isToday(Mission m) {
      final day = DateTime(m.date.year, m.date.month, m.date.day);
      return day == today;
    }

    final todayMissions = filtered.where(isToday).toList();
    final otherMissions = filtered.where((m) => !isToday(m)).toList();
    final items = <Object>[
      if (todayMissions.isNotEmpty) ...['Aujourd\'hui', ...todayMissions],
      if (otherMissions.isNotEmpty) ...[
        if (todayMissions.isNotEmpty) 'À venir',
        ...otherMissions,
      ],
    ];

    final showHeader = widget.initialCategoryId != null || widget.publisherType != null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      appBar: widget.showAppBar
          ? AppSectionBar(pageTitle: _headerTitle)
          : null,
      body: SafeArea(
        child: Column(
          children: [
            if (showHeader) _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: context.colors.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
              if (isLoading)
                const SliverToBoxAdapter(
                  child: SizedBox(height: 380, child: SkeletonList()),
                )
              else if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 260,
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: _showAppliedOnly
                          ? 'Aucune mission postulée'
                          : 'Aucune mission trouvée',
                      subtitle: _showAppliedOnly
                          ? 'Vous n avez pas encore postulé à une mission dans cette liste.'
                          : 'Ajustez vos filtres ou revenez plus tard pour découvrir de nouvelles missions.',
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  sliver: SliverList.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      if (item is String) {
                        final isTodayLabel = item == 'Aujourd\'hui';
                        return Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: isTodayLabel
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.inkDark,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.bolt_rounded, size: 13, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Aujourd\'hui',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gray600,
                                  ),
                                ),
                        );
                      }

                      final mission = item as Mission;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: MissionBrowseCard(
                          mission: mission,
                          isApplied: appliedIds.contains(mission.id),
                          onTap: () => Navigator.push(
                            context,
                            slideUpRoute(
                              page: FreelancerMissionDetailPage(mission: mission),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SliverToBoxAdapter(child: AppGap.h24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: context.colors.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            _headerTitle,
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: context.colors.textPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showFilterSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _hasActiveFilters ? AppColors.inkDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _hasActiveFilters ? AppColors.inkDark : context.colors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.tune_rounded,
                size: 20,
                color: _hasActiveFilters ? Colors.white : context.colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filtres missions',
                      style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (_hasActiveFilters)
                      GestureDetector(
                        onTap: () {
                          setState(_resetFilters);
                          setSheet(() {});
                        },
                        child: Text(
                          'Réinitialiser',
                          style: context.text.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildFilterSectionTitle(context, 'Affichage'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterPill(
                      label: 'Toutes',
                      selected: !_showAppliedOnly,
                      onTap: () {
                        setState(() => _showAppliedOnly = false);
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: 'Déjà postulé',
                      icon: Icons.task_alt_rounded,
                      selected: _showAppliedOnly,
                      onTap: () {
                        setState(() => _showAppliedOnly = true);
                        setSheet(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildFilterSectionTitle(context, 'Type de service'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterPill(
                      label: 'Tous',
                      selected: _selectedCategoryId == null,
                      onTap: () {
                        setState(() => _selectedCategoryId = null);
                        setSheet(() {});
                      },
                    ),
                    ...ServiceCategory.all.map(
                      (category) => _FilterPill(
                        label: category.name,
                        icon: category.icon,
                        color: category.color,
                        selected: _selectedCategoryId == category.id,
                        onTap: () {
                          setState(() => _selectedCategoryId = category.id);
                          setSheet(() {});
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildFilterSectionTitle(context, 'Date'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterPill(
                      label: 'Toutes',
                      selected: _selectedDateFilter == _MissionDateFilter.all,
                      onTap: () {
                        setState(() => _selectedDateFilter = _MissionDateFilter.all);
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: 'Aujourd hui',
                      selected: _selectedDateFilter == _MissionDateFilter.today,
                      onTap: () {
                        setState(() => _selectedDateFilter = _MissionDateFilter.today);
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: '7 jours',
                      selected: _selectedDateFilter == _MissionDateFilter.thisWeek,
                      onTap: () {
                        setState(() => _selectedDateFilter = _MissionDateFilter.thisWeek);
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: 'Ce mois',
                      selected: _selectedDateFilter == _MissionDateFilter.thisMonth,
                      onTap: () {
                        setState(() => _selectedDateFilter = _MissionDateFilter.thisMonth);
                        setSheet(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildFilterSectionTitle(context, 'Tarif'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterPill(
                      label: 'Tous',
                      selected: _selectedBudgetFilter == _MissionBudgetFilter.all,
                      onTap: () {
                        setState(() => _selectedBudgetFilter = _MissionBudgetFilter.all);
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: '< 50€',
                      selected: _selectedBudgetFilter == _MissionBudgetFilter.under50,
                      onTap: () {
                        setState(() => _selectedBudgetFilter = _MissionBudgetFilter.under50);
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: '50€ - 150€',
                      selected: _selectedBudgetFilter == _MissionBudgetFilter.from50To150,
                      onTap: () {
                        setState(() => _selectedBudgetFilter = _MissionBudgetFilter.from50To150);
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: '150€ - 300€',
                      selected: _selectedBudgetFilter == _MissionBudgetFilter.from150To300,
                      onTap: () {
                        setState(() => _selectedBudgetFilter = _MissionBudgetFilter.from150To300);
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: '> 300€',
                      selected: _selectedBudgetFilter == _MissionBudgetFilter.over300,
                      onTap: () {
                        setState(() => _selectedBudgetFilter = _MissionBudgetFilter.over300);
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: 'Sur devis',
                      selected: _selectedBudgetFilter == _MissionBudgetFilter.quote,
                      onTap: () {
                        setState(() => _selectedBudgetFilter = _MissionBudgetFilter.quote);
                        setSheet(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Appliquer',
                    variant: ButtonVariant.black,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.inkDark : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.inkDark : AppColors.gray50,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: AppColors.blackAlpha09,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: selected ? Colors.white : accent),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.inkDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
