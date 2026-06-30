import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../app/app_bar/location_app_bar.dart';
import '../../../../app/widgets/app_segmented_tab_bar.dart';
import '../../../story/story.dart';
import '../../../story/presentation/widgets/stories_section.dart';
import '../../../profile/profile_provider.dart';
import '../../../mission/data/models/mission.dart';
import '../../../mission/presentation/mission_provider.dart';
import '../../../mission/presentation/widgets/shared/mission_shared_widgets.dart';
import '../../../mission/presentation/widgets/cards/primitives/mission_card_frame.dart';
import '../../../mission/presentation/pages/client/client_mission_detail_page.dart';
import '../../../mission/presentation/pages/client/create_mission_page.dart';
import '../../../auth/data/models/freelancer.dart';
import '../../../auth/presentation/widgets/freelancer_preview_card.dart';
import 'freelancer_profile_view.dart';

Map<String, dynamic> _normalizeFreelancerRow(Map<String, dynamic> row) {
  final firstName = (row['first_name'] ?? '') as String;
  final lastName = (row['last_name'] ?? '') as String;
  final fullName = '$firstName $lastName'.trim();
  final rawHourlyRate = row['hourly_rate'];
  final hourlyRate = rawHourlyRate is num
      ? rawHourlyRate.toInt()
      : int.tryParse('$rawHourlyRate') ?? 0;
  final categoryIds = ServiceCategory.resolveIds(row['service_categories']);
  final categoryNames = ServiceCategory.resolveNames(row['service_categories']);
  final rawRating = row['rating'];
  final rating = rawRating is num ? rawRating.toDouble() : 0.0;
  final rawReviewsCount = row['reviews_count'];
  final reviewsCount = rawReviewsCount is num
      ? rawReviewsCount.toInt()
      : int.tryParse('$rawReviewsCount') ?? 0;
  final rawMissionsCount = row['completed_missions'];
  final missionsCount = rawMissionsCount is num
      ? rawMissionsCount.toInt()
      : int.tryParse('$rawMissionsCount') ?? 0;

  return {
    'id': row['id'] ?? '',
    'name': fullName.isEmpty ? 'Prestataire' : fullName,
    'avatar': (row['avatar_url'] ?? '') as String,
    'category': categoryNames.isNotEmpty
        ? categoryNames.first
        : 'Multi-services',
    'categoryIds': categoryIds,
    'services': categoryNames,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'hourlyRate': hourlyRate,
    'isVerified': (row['is_verified'] ?? false) as bool,
    'isOnline': false,
    'missionsCount': missionsCount,
    'responseTime': (row['response_time'] ?? '2h') as String,
    'experienceLevel': categoryNames.isNotEmpty ? 'Spécialisé' : 'Pro',
    'zone': (row['address'] ?? '') as String,
  };
}

/// ─────────────────────────────────────────────────────────────
/// 🏠 Inkern - Page d'accueil Client
/// Haut : CTA mission + catégories + accès prestataires + stories
/// Bas  : fil d'actualité
/// ─────────────────────────────────────────────────────────────
class ClientDiscoverContent extends StatefulWidget {
  final VoidCallback? onGoToAccount;
  final VoidCallback? onGoToMissions;
  const ClientDiscoverContent({
    super.key,
    this.onGoToAccount,
    this.onGoToMissions,
  });

  @override
  State<ClientDiscoverContent> createState() => _ClientDiscoverContentState();
}

class _ClientDiscoverContentState extends State<ClientDiscoverContent>
    with SingleTickerProviderStateMixin {
  late final TabController _discoverTabController;

  @override
  void initState() {
    super.initState();
    _discoverTabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadFreelancers();
    });
  }

  @override
  void dispose() {
    _discoverTabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<ProfileProvider>().loadFreelancers(),
      context.read<StoryProvider>().refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      appBar: HomeAppBar(
        onGoToAccount: widget.onGoToAccount,
        bottom: AppSegmentedTabBar(
          controller: _discoverTabController,
          tabs: const [
            AppSegmentedTab(icon: Icons.home_rounded, label: 'Home'),
            AppSegmentedTab(icon: Icons.search_rounded, label: 'Freelancer'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _discoverTabController,
        children: [
          RefreshIndicator(
            onRefresh: _refresh,
            color: context.colors.primary,
            child: CustomScrollView(
              slivers: [
                // ── Stories des freelancers ──────────────────────────
                SliverToBoxAdapter(
                  child: Consumer<StoryProvider>(
                    builder: (context, storyProvider, _) => StoriesSection(
                      storyGroups: storyProvider.storyGroups,
                      isFreelancer: false,
                      onProfileTap: (group) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FreelancerProfileView(
                            freelancerId: group.groupId,
                            freelancerName: group.groupName,
                            freelancerAvatar: group.avatarUrl,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Missions en cours — remplit l'espace restant ─────
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ActiveMissionsSection(
                    onGoToMissions: widget.onGoToMissions,
                  ),
                ),
              ],
            ),
          ),
          const _FreelancerDiscoveryView(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section missions du jour — masquée si vide, remplit l'espace
// ─────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Section missions du jour
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveMissionsSection extends StatelessWidget {
  final VoidCallback? onGoToMissions;
  const _ActiveMissionsSection({this.onGoToMissions});

  String _todayLabel() {
    final now = DateTime.now();
    const days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${days[now.weekday - 1]} ${now.day} ${months[now.month - 1]}';
  }

  static bool _isArchived(MissionStatus s) =>
      s == MissionStatus.closed ||
      s == MissionStatus.cancelled ||
      s == MissionStatus.expired ||
      s == MissionStatus.inDispute;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final all = context.watch<MissionProvider>().clientMissions;

    // Today: any non-archived mission dated today
    final todayMissions = all.where((m) {
      final mDay = DateTime(m.date.year, m.date.month, m.date.day);
      return mDay == todayDate && !_isArchived(m.status);
    }).toList();

    // Upcoming: confirmed missions within the next 7 days (excl. today)
    final upcomingMissions = todayMissions.isEmpty
        ? (all.where((m) {
            final mDay = DateTime(m.date.year, m.date.month, m.date.day);
            final diff = mDay.difference(todayDate).inDays;
            return diff > 0 && diff <= 7 && m.status == MissionStatus.confirmed;
          }).toList()
          ..sort((a, b) => a.date.compareTo(b.date)))
        : <Mission>[];

    final missions = todayMissions.isNotEmpty ? todayMissions : upcomingMissions;
    final isToday = todayMissions.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête ────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? "Aujourd'hui" : "À venir",
                    style: context.text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _todayLabel(),
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (missions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${missions.length} mission${missions.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: AppFontSize.sm,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Contenu ───────────────────────────────────────────
          if (missions.isEmpty)
            _EmptyTodayCard(onGoToMissions: onGoToMissions)
          else
            ...missions.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ActiveMissionCard(mission: m, showDate: !isToday),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyTodayCard extends StatelessWidget {
  final VoidCallback? onGoToMissions;
  const _EmptyTodayCard({this.onGoToMissions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackAlpha03,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "Pas de mission aujourd'hui",
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Publiez une mission pour trouver un prestataire rapidement.',
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Créer une mission',
            variant: ButtonVariant.black,
            icon: Icons.add_rounded,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PostMissionFlow()),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Carte mission active ─────────────────────────────────────────────────────

class _ActiveMissionCard extends StatelessWidget {
  final Mission mission;
  final bool showDate;
  const _ActiveMissionCard({required this.mission, this.showDate = false});

  String _dateLabel(DateTime date) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc',
    ];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final presta = mission.assignedPresta;
    final location = mission.address.shortAddress;
    final subtitle = [
      if (location.isNotEmpty) location,
      if (presta != null) presta.name,
    ].join(' · ');
    final timeLabel = mission.timeSlot.isNotEmpty
        ? mission.timeSlot.split(' - ').first
        : null;
    final topLabel = showDate
        ? _dateLabel(mission.date)
        : (timeLabel ?? '—');

    return ClipRRect(
      borderRadius: BorderRadius.circular(MissionCardFrame.radiusSmall),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          slideUpRoute(page: ClientMissionDetailPage(mission: mission)),
        ),
        borderRadius: BorderRadius.circular(MissionCardFrame.radiusSmall),
        splashColor: Colors.black.withValues(alpha: 0.04),
        highlightColor: Colors.black.withValues(alpha: 0.02),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(MissionCardFrame.radiusSmall),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Date/heure + flèche ────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  topLabel,
                  style: context.text.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ── Titre ───────────────────────────────────────────
            Text(
              mission.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            // ── Sous-titre ──────────────────────────────────────
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MissionCardFrame.metaStyle,
              ),
            ],
            // ── Heure (when showing date in topLabel) ──────────
            if (showDate && timeLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                timeLabel,
                style: MissionCardFrame.metaStyle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// Page découverte freelancers (standalone via "Voir plus")
// ─────────────────────────────────────────────────────────────
class FreelancerDiscoveryPage extends StatelessWidget {
  final String? initialCategoryId;

  const FreelancerDiscoveryPage({super.key, this.initialCategoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        title: 'Prestataires',
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
      ),
      body: _FreelancerDiscoveryView(initialCategoryId: initialCategoryId),
    );
  }
}

/// Page d'accueil du client — recherche et filtrage des Freelancers
class _FreelancerDiscoveryView extends StatefulWidget {
  final String? initialCategoryId;

  const _FreelancerDiscoveryView({this.initialCategoryId});

  @override
  State<_FreelancerDiscoveryView> createState() =>
      _FreelancerDiscoveryViewState();
}

class _FreelancerDiscoveryViewState extends State<_FreelancerDiscoveryView> {
  final _searchController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadFreelancers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredFreelancers {
    final rawList = context.watch<ProfileProvider>().freelancers;
    final normalized = rawList.map(_normalizeFreelancerRow).toList();

    return normalized.where((f) {
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final name = (f['name'] as String).toLowerCase();
        final services = (f['services'] as List).join(' ').toLowerCase();
        if (!name.contains(query) && !services.contains(query)) return false;
      }
      if (_selectedCategoryId != null) {
        final categoryIds = f['categoryIds'] as List<String>;
        if (!categoryIds.contains(_selectedCategoryId)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search & Filters Header — iOS pill style
        Container(
          color: context.colors.surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              // Pill search field
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: context.colors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.blackAlpha07,
                        blurRadius: 16,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) {
                      setState(() {});
                      context.read<ProfileProvider>().loadFreelancers(
                        search: _searchController.text,
                      );
                    },
                    style: context.text.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un service, un nom...',
                      hintStyle: context.text.bodyMedium?.copyWith(
                        color: context.colors.textTertiary,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: context.colors.textTertiary,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: context.colors.textTertiary,
                                size: 18,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                                context
                                    .read<ProfileProvider>()
                                    .loadFreelancers();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Filter button — rounded square
              GestureDetector(
                onTap: _showFilterSheet,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _selectedCategoryId != null
                        ? AppColors.inkDark
                        : context.colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedCategoryId != null
                          ? AppColors.inkDark
                          : context.colors.border,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.blackAlpha07,
                        blurRadius: 16,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: _selectedCategoryId != null
                        ? Colors.white
                        : context.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Freelancers list
        Expanded(
          child: Consumer<ProfileProvider>(
            builder: (context, provider, _) {
              if (provider.isLoadingFreelancers) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = _filteredFreelancers;
              if (items.isEmpty) return _buildEmptyState();
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 700;
                  final crossAxisCount = isWide ? 3 : 2;
                  return GridView.builder(
                    padding: AppInsets.a16,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isWide ? 0.65 : 0.62,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final f = items[index];
                      return FreelancerPreviewCard(
                        freelancer: Freelancer(
                          name: f['name'] as String,
                          imageUrl: f['avatar'] as String,
                          rating: f['rating'] as double,
                          job: '${f['hourlyRate']}€/h',
                          subtitle: f['category'] as String,
                          isVerified: f['isVerified'] as bool,
                        ),
                        missionsCount: f['missionsCount'] as int,
                        reviewsCount: f['reviewsCount'] as int,
                        onTap: () => _openFreelancerProfile(f),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: context.colors.border,
          ),
          AppGap.h16,
          Text(
            'Aucun freelancer trouvé',
            style: context.text.titleMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          AppGap.h8,
          Text(
            'Essayez de modifier vos filtres',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.textTertiary,
            ),
          ),
          AppGap.h24,
          AppButton(
            label: 'Réinitialiser les filtres',
            variant: ButtonVariant.ghost,
            icon: Icons.refresh_rounded,
            onPressed: _resetFilters,
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategoryId = null;
    });
    context.read<ProfileProvider>().loadFreelancers();
  }

  void _showFilterSheet() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => AppSheetSurface(
          color: ctx.colors.sheetBg,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppBottomSheetHandle(),
                  AppGap.h12,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Catégorie',
                        style: ctx.text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (_selectedCategoryId != null)
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedCategoryId = null);
                            setSheet(() {});
                            Navigator.pop(ctx);
                          },
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
                  AppGap.h16,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _CategoryChip(
                        label: 'Tous',
                        selected: _selectedCategoryId == null,
                        onTap: () {
                          setState(() => _selectedCategoryId = null);
                          setSheet(() {});
                          Navigator.pop(ctx);
                        },
                      ),
                      ...ServiceCategory.all.map(
                        (cat) => _CategoryChip(
                          label: cat.name,
                          icon: cat.icon,
                          color: cat.color,
                          selected: _selectedCategoryId == cat.id,
                          onTap: () {
                            setState(() => _selectedCategoryId = cat.id);
                            setSheet(() {});
                            Navigator.pop(ctx);
                          },
                        ),
                      ),
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

  void _openFreelancerProfile(Map<String, dynamic> freelancer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FreelancerProfileView(
          freelancerId: freelancer['id'] as String?,
          freelancerName: freelancer['name'] as String,
          freelancerAvatar: freelancer['avatar'] as String,
          hourlyRate: (freelancer['hourlyRate'] as int).toDouble(),
          experienceLevel: freelancer['experienceLevel'] as String,
          rating: freelancer['rating'] as double,
          reviewsCount: freelancer['reviewsCount'] as int,
          missionsCount: freelancer['missionsCount'] as int,
          responseTime: 'Répond en ${freelancer['responseTime']}',
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
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
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.45)
                : context.colors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: selected ? accent : context.colors.textTertiary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? accent : context.colors.textSecondary,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
