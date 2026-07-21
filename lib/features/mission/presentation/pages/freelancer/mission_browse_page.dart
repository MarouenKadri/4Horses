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

enum _MissionBudgetFilter {
  all,
  under50,
  from50To150,
  from150To300,
  over300,
  quote,
}

class MissionBrowsePage extends StatefulWidget {
  final List<Mission>? missions;
  final bool showAppBar;
  final String? locationLabel;
  final VoidCallback? onLocationTap;
  final String? initialCategoryId;
  final PublisherType? publisherType;

  /// Mode embarqué (ex. dans un TabBarView de l'accueil) : pas de flèche
  /// retour ni de titre — seul le bouton filtres reste accessible.
  final bool embedded;

  const MissionBrowsePage({
    super.key,
    this.missions,
    this.showAppBar = false,
    this.locationLabel,
    this.onLocationTap,
    this.initialCategoryId,
    this.publisherType,
    this.embedded = false,
  });

  @override
  State<MissionBrowsePage> createState() => _MissionBrowsePageState();
}

class _MissionBrowsePageState extends State<MissionBrowsePage> {
  late String? _selectedCategoryId;
  late PublisherType? _publisherFilter;
  bool _showAppliedOnly = false;
  _MissionDateFilter _selectedDateFilter = _MissionDateFilter.all;
  _MissionBudgetFilter _selectedBudgetFilter = _MissionBudgetFilter.all;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _publisherFilter = widget.publisherType;
  }

  List<Mission> _filtered(List<Mission> all, Set<String> appliedIds) {
    var list = all
        .where(
          (m) =>
              m.status == MissionStatus.waitingCandidates ||
              m.status == MissionStatus.candidateReceived,
        )
        .toList();

    if (_selectedCategoryId != null) {
      list = list.where((m) => m.categoryId == _selectedCategoryId).toList();
    }

    if (_showAppliedOnly) {
      list = list.where((m) => appliedIds.contains(m.id)).toList();
    }

    if (_publisherFilter != null) {
      list = list.where((m) {
        final isAgency = _isAgencyMission(m);
        return _publisherFilter == PublisherType.agence ? isAgency : !isAgency;
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
      final day = DateTime(
        mission.date.year,
        mission.date.month,
        mission.date.day,
      );
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
        !missionDay.isBefore(today) && missionDay.difference(today).inDays <= 7,
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
      'agence',
      'agency',
      'sarl',
      'sas',
      'sasu',
      'eurl',
      'entreprise',
      'societe',
      'société',
      'groupe',
      'holding',
      'studio',
      'cabinet',
      'immobilier',
    ];
    return agencyTokens.any(rawName.contains);
  }

  Future<void> _refresh() async {
    await context.read<MissionProvider>().refresh();
  }

  void _resetFilters() {
    _selectedCategoryId = widget.initialCategoryId;
    _publisherFilter = widget.publisherType;
    _showAppliedOnly = false;
    _selectedDateFilter = _MissionDateFilter.all;
    _selectedBudgetFilter = _MissionBudgetFilter.all;
  }

  bool get _hasActiveFilters =>
      _selectedCategoryId != null ||
      _publisherFilter != widget.publisherType ||
      _showAppliedOnly ||
      _selectedDateFilter != _MissionDateFilter.all ||
      _selectedBudgetFilter != _MissionBudgetFilter.all;

  int get _activeFilterCount =>
      (_selectedCategoryId != null ? 1 : 0) +
      (_publisherFilter != widget.publisherType ? 1 : 0) +
      (_showAppliedOnly ? 1 : 0) +
      (_selectedDateFilter != _MissionDateFilter.all ? 1 : 0) +
      (_selectedBudgetFilter != _MissionBudgetFilter.all ? 1 : 0);

  String get _headerTitle {
    if (widget.initialCategoryId != null) {
      return ServiceCategory.findById(widget.initialCategoryId!)?.name ??
          'Missions';
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

    final showHeader =
        widget.initialCategoryId != null || widget.publisherType != null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      appBar: widget.showAppBar ? AppSectionBar(pageTitle: _headerTitle) : null,
      body: SafeArea(
        child: Column(
          children: [
            if (widget.embedded)
              _buildEmbeddedHeader()
            else if (showHeader)
              _buildHeader(),
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
                                ? 'Vous n’avez pas encore postulé à une mission dans cette liste.'
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
                              // Labels de section en texte noir simple —
                              // même langage que les titres de profil.
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: 14,
                                  bottom: 8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isTodayLabel) ...[
                                      Icon(
                                        Icons.bolt_rounded,
                                        size: 16,
                                        color: context.colors.textPrimary,
                                      ),
                                      AppGap.w4,
                                    ],
                                    Text(
                                      item,
                                      style: context.text.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: context.colors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final mission = item as Mission;
                            return MissionBrowseCard(
                              mission: mission,
                              isApplied: appliedIds.contains(mission.id),
                              onTap: () => Navigator.push(
                                context,
                                slideUpRoute(
                                  page: FreelancerMissionDetailPage(
                                    mission: mission,
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
          AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
          Text(
            _headerTitle,
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: context.colors.textPrimary,
            ),
          ),
          const Spacer(),
          _buildFilterButton(),
        ],
      ),
    );
  }

  /// Rangée compacte du mode embarqué : uniquement le bouton filtres.
  Widget _buildEmbeddedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          if (_hasActiveFilters)
            GestureDetector(
              onTap: () => setState(_resetFilters),
              child: Text(
                'Réinitialiser les filtres',
                style: context.text.labelMedium?.copyWith(
                  color: context.colors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          const Spacer(),
          _buildFilterButton(size: 38, iconSize: 18),
        ],
      ),
    );
  }

  Widget _buildFilterButton({double size = 44, double iconSize = 20}) {
    final active = _hasActiveFilters;
    return GestureDetector(
      onTap: _showFilterSheet,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: active
                  ? context.colors.textPrimary
                  : context.colors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.tune_rounded,
              size: iconSize,
              color: active
                  ? context.colors.background
                  : context.colors.textPrimary,
            ),
          ),
          if (active)
            Positioned(
              top: -2,
              right: -2,
              child: AppCountBadge(
                label: '$_activeFilterCount',
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: AppInsets.h4v1,
              ),
            ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
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
                AppGap.h20,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filtres missions',
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
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
                AppGap.h24,
                _buildFilterSectionTitle(context, 'Affichage'),
                AppGap.h16,
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
                AppGap.h24,
                _buildFilterSectionTitle(context, 'Type de client'),
                AppGap.h16,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterPill(
                      label: 'Tous',
                      selected: _publisherFilter == null,
                      onTap: () {
                        setState(() => _publisherFilter = null);
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: 'Particulier',
                      icon: Icons.person_outline_rounded,
                      selected: _publisherFilter == PublisherType.particulier,
                      onTap: () {
                        setState(
                          () => _publisherFilter = PublisherType.particulier,
                        );
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: 'Agence',
                      icon: Icons.business_outlined,
                      selected: _publisherFilter == PublisherType.agence,
                      onTap: () {
                        setState(() => _publisherFilter = PublisherType.agence);
                        setSheet(() {});
                      },
                    ),
                  ],
                ),
                AppGap.h24,
                _buildFilterSectionTitle(context, 'Type de service'),
                AppGap.h16,
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
                AppGap.h24,
                _buildFilterSectionTitle(context, 'Date'),
                AppGap.h16,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterPill(
                      label: 'Toutes',
                      selected: _selectedDateFilter == _MissionDateFilter.all,
                      onTap: () {
                        setState(
                          () => _selectedDateFilter = _MissionDateFilter.all,
                        );
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: 'Aujourd hui',
                      selected: _selectedDateFilter == _MissionDateFilter.today,
                      onTap: () {
                        setState(
                          () => _selectedDateFilter = _MissionDateFilter.today,
                        );
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: '7 jours',
                      selected:
                          _selectedDateFilter == _MissionDateFilter.thisWeek,
                      onTap: () {
                        setState(
                          () =>
                              _selectedDateFilter = _MissionDateFilter.thisWeek,
                        );
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: 'Ce mois',
                      selected:
                          _selectedDateFilter == _MissionDateFilter.thisMonth,
                      onTap: () {
                        setState(
                          () => _selectedDateFilter =
                              _MissionDateFilter.thisMonth,
                        );
                        setSheet(() {});
                      },
                    ),
                  ],
                ),
                AppGap.h24,
                _buildFilterSectionTitle(context, 'Tarif'),
                AppGap.h16,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterPill(
                      label: 'Tous',
                      selected:
                          _selectedBudgetFilter == _MissionBudgetFilter.all,
                      onTap: () {
                        setState(
                          () =>
                              _selectedBudgetFilter = _MissionBudgetFilter.all,
                        );
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: '< 50€',
                      selected:
                          _selectedBudgetFilter == _MissionBudgetFilter.under50,
                      onTap: () {
                        setState(
                          () => _selectedBudgetFilter =
                              _MissionBudgetFilter.under50,
                        );
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: '50€ - 150€',
                      selected:
                          _selectedBudgetFilter ==
                          _MissionBudgetFilter.from50To150,
                      onTap: () {
                        setState(
                          () => _selectedBudgetFilter =
                              _MissionBudgetFilter.from50To150,
                        );
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: '150€ - 300€',
                      selected:
                          _selectedBudgetFilter ==
                          _MissionBudgetFilter.from150To300,
                      onTap: () {
                        setState(
                          () => _selectedBudgetFilter =
                              _MissionBudgetFilter.from150To300,
                        );
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: '> 300€',
                      selected:
                          _selectedBudgetFilter == _MissionBudgetFilter.over300,
                      onTap: () {
                        setState(
                          () => _selectedBudgetFilter =
                              _MissionBudgetFilter.over300,
                        );
                        setSheet(() {});
                      },
                    ),
                    _FilterPill(
                      label: 'Sur devis',
                      selected:
                          _selectedBudgetFilter == _MissionBudgetFilter.quote,
                      onTap: () {
                        setState(
                          () => _selectedBudgetFilter =
                              _MissionBudgetFilter.quote,
                        );
                        setSheet(() {});
                      },
                    ),
                  ],
                ),
                AppGap.h28,
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
    final accent = color ?? context.colors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? context.colors.textPrimary
              : context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: selected ? context.colors.background : accent,
              ),
              AppGap.w6,
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? context.colors.background
                    : context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
