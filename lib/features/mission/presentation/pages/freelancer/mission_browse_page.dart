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
              _buildResultsFilterBand(filtered.length)
            else if (showHeader)
              _buildHeader(filtered.length),
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
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: EmptyState(
                            icon: Icons.search_off_rounded,
                            title: _showAppliedOnly
                                ? 'Aucune mission postulée'
                                : 'Aucune mission trouvée',
                            subtitle: _showAppliedOnly
                                ? 'Vous n’avez pas encore postulé à une mission dans cette liste.'
                                : 'Ajustez vos filtres ou revenez plus tard pour découvrir de nouvelles missions.',
                            buttonText: _hasActiveFilters
                                ? 'Réinitialiser les filtres'
                                : null,
                            onButtonPressed: _hasActiveFilters
                                ? () => setState(_resetFilters)
                                : null,
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

  Widget _buildHeader(int resultCount) {
    return Column(
      children: [
        Container(
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
            ],
          ),
        ),
        _buildResultsFilterBand(resultCount),
      ],
    );
  }

  /// Bandeau "N résultats · Filtrer" — toute la ligne est cliquable.
  /// Utilisé aussi bien en mode embarqué qu'en page standalone.
  Widget _buildResultsFilterBand(int resultCount) {
    return GestureDetector(
      onTap: _showFilterSheet,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: context.colors.surface,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          children: [
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                  children: [
                    TextSpan(text: '$resultCount '),
                    TextSpan(
                      text: _hasActiveFilters
                          ? '$_activeFilterCount filtre${_activeFilterCount > 1 ? 's' : ''} actif${_activeFilterCount > 1 ? 's' : ''}'
                          : 'missions',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              'Filtrer',
              style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.text.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: context.colors.textSecondary,
      ),
    );
  }

  void _showFilterSheet() {
    // Copies de travail : appliquées seulement au clic sur "Appliquer".
    var draftShowAppliedOnly = _showAppliedOnly;
    var draftPublisherFilter = _publisherFilter;
    var draftCategoryId = _selectedCategoryId;
    var draftDateFilter = _selectedDateFilter;
    var draftBudgetFilter = _selectedBudgetFilter;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            32 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
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
                      color: ctx.colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filtres',
                      style: ctx.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setSheet(() {
                        draftShowAppliedOnly = false;
                        draftPublisherFilter = widget.publisherType;
                        draftCategoryId = widget.initialCategoryId;
                        draftDateFilter = _MissionDateFilter.all;
                        draftBudgetFilter = _MissionBudgetFilter.all;
                      }),
                      child: Text(
                        'Réinitialiser',
                        style: ctx.text.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _sectionTitle(ctx, 'Affichage'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppFilterChip(
                      label: 'Toutes',
                      selected: !draftShowAppliedOnly,
                      onTap: () => setSheet(() => draftShowAppliedOnly = false),
                    ),
                    AppFilterChip(
                      label: 'Déjà postulé',
                      icon: Icons.task_alt_rounded,
                      selected: draftShowAppliedOnly,
                      onTap: () => setSheet(() => draftShowAppliedOnly = true),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _sectionTitle(ctx, 'Type de client'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppFilterChip(
                      label: 'Tous',
                      selected: draftPublisherFilter == null,
                      onTap: () => setSheet(() => draftPublisherFilter = null),
                    ),
                    AppFilterChip(
                      label: 'Particulier',
                      icon: Icons.person_outline_rounded,
                      selected:
                          draftPublisherFilter == PublisherType.particulier,
                      onTap: () => setSheet(
                        () => draftPublisherFilter = PublisherType.particulier,
                      ),
                    ),
                    AppFilterChip(
                      label: 'Agence',
                      icon: Icons.business_outlined,
                      selected: draftPublisherFilter == PublisherType.agence,
                      onTap: () => setSheet(
                        () => draftPublisherFilter = PublisherType.agence,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _sectionTitle(ctx, 'Type de service'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppFilterChip(
                      label: 'Tous',
                      selected: draftCategoryId == null,
                      onTap: () => setSheet(() => draftCategoryId = null),
                    ),
                    for (final category in ServiceCategory.all)
                      AppFilterChip(
                        label: category.name,
                        icon: category.icon,
                        color: category.color,
                        selected: draftCategoryId == category.id,
                        onTap: () =>
                            setSheet(() => draftCategoryId = category.id),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                _sectionTitle(ctx, 'Date'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppFilterChip(
                      label: 'Toutes',
                      selected: draftDateFilter == _MissionDateFilter.all,
                      onTap: () => setSheet(
                        () => draftDateFilter = _MissionDateFilter.all,
                      ),
                    ),
                    AppFilterChip(
                      label: 'Aujourd’hui',
                      selected: draftDateFilter == _MissionDateFilter.today,
                      onTap: () => setSheet(
                        () => draftDateFilter = _MissionDateFilter.today,
                      ),
                    ),
                    AppFilterChip(
                      label: '7 jours',
                      selected: draftDateFilter == _MissionDateFilter.thisWeek,
                      onTap: () => setSheet(
                        () => draftDateFilter = _MissionDateFilter.thisWeek,
                      ),
                    ),
                    AppFilterChip(
                      label: 'Ce mois',
                      selected: draftDateFilter == _MissionDateFilter.thisMonth,
                      onTap: () => setSheet(
                        () => draftDateFilter = _MissionDateFilter.thisMonth,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _sectionTitle(ctx, 'Tarif'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppFilterChip(
                      label: 'Tous',
                      selected: draftBudgetFilter == _MissionBudgetFilter.all,
                      onTap: () => setSheet(
                        () => draftBudgetFilter = _MissionBudgetFilter.all,
                      ),
                    ),
                    AppFilterChip(
                      label: '< 50€',
                      selected:
                          draftBudgetFilter == _MissionBudgetFilter.under50,
                      onTap: () => setSheet(
                        () => draftBudgetFilter = _MissionBudgetFilter.under50,
                      ),
                    ),
                    AppFilterChip(
                      label: '50€ - 150€',
                      selected:
                          draftBudgetFilter == _MissionBudgetFilter.from50To150,
                      onTap: () => setSheet(
                        () => draftBudgetFilter =
                            _MissionBudgetFilter.from50To150,
                      ),
                    ),
                    AppFilterChip(
                      label: '150€ - 300€',
                      selected:
                          draftBudgetFilter ==
                          _MissionBudgetFilter.from150To300,
                      onTap: () => setSheet(
                        () => draftBudgetFilter =
                            _MissionBudgetFilter.from150To300,
                      ),
                    ),
                    AppFilterChip(
                      label: '> 300€',
                      selected:
                          draftBudgetFilter == _MissionBudgetFilter.over300,
                      onTap: () => setSheet(
                        () => draftBudgetFilter = _MissionBudgetFilter.over300,
                      ),
                    ),
                    AppFilterChip(
                      label: 'Sur devis',
                      selected: draftBudgetFilter == _MissionBudgetFilter.quote,
                      onTap: () => setSheet(
                        () => draftBudgetFilter = _MissionBudgetFilter.quote,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                AppButton(
                  label: 'Appliquer',
                  variant: ButtonVariant.black,
                  onPressed: () {
                    setState(() {
                      _showAppliedOnly = draftShowAppliedOnly;
                      _publisherFilter = draftPublisherFilter;
                      _selectedCategoryId = draftCategoryId;
                      _selectedDateFilter = draftDateFilter;
                      _selectedBudgetFilter = draftBudgetFilter;
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
