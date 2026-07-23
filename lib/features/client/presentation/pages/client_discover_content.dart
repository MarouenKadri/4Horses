import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../app/app_bar/location_app_bar.dart';
import '../../../../app/widgets/app_segmented_tab_bar.dart';
import '../../../story/presentation/widgets/posts_feed.dart';
import '../../../profile/profile_provider.dart';
import '../../../mission/data/models/service_category.dart';
import '../../../auth/data/models/freelancer.dart';
import '../../../auth/presentation/widgets/freelancer_list_tile.dart';
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
/// Home : fil d'actualité (posts) · Freelancer : découverte prestataires
/// ─────────────────────────────────────────────────────────────
class ClientDiscoverContent extends StatefulWidget {
  final VoidCallback? onGoToAccount;
  const ClientDiscoverContent({super.key, this.onGoToAccount});

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
          PostsFeed(
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
          const _FreelancerDiscoveryView(),
        ],
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

enum _FreelancerSort { relevance, ratingDesc, priceAsc, priceDesc }

class _FreelancerDiscoveryViewState extends State<_FreelancerDiscoveryView> {
  final Set<String> _selectedCategoryIds = {};
  double _minRating = 0;
  _FreelancerSort _sort = _FreelancerSort.relevance;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategoryId != null) {
      _selectedCategoryIds.add(widget.initialCategoryId!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadFreelancers();
    });
  }

  bool get _hasActiveFilters =>
      _selectedCategoryIds.isNotEmpty || _minRating > 0;

  List<Map<String, dynamic>> get _filteredFreelancers {
    final rawList = context.watch<ProfileProvider>().freelancers;
    final normalized = rawList.map(_normalizeFreelancerRow).toList();

    final filtered = normalized.where((f) {
      if (_selectedCategoryIds.isNotEmpty) {
        final categoryIds = f['categoryIds'] as List<String>;
        if (!categoryIds.any(_selectedCategoryIds.contains)) return false;
      }
      if (_minRating > 0) {
        final rating = f['rating'] as double;
        if (rating < _minRating) return false;
      }
      return true;
    }).toList();

    switch (_sort) {
      case _FreelancerSort.relevance:
        break;
      case _FreelancerSort.ratingDesc:
        filtered.sort(
          (a, b) => (b['rating'] as double).compareTo(a['rating'] as double),
        );
      case _FreelancerSort.priceAsc:
        filtered.sort(
          (a, b) => (a['hourlyRate'] as int).compareTo(b['hourlyRate'] as int),
        );
      case _FreelancerSort.priceDesc:
        filtered.sort(
          (a, b) => (b['hourlyRate'] as int).compareTo(a['hourlyRate'] as int),
        );
    }
    return filtered;
  }

  String get _filterSummary {
    final parts = <String>[];
    if (_selectedCategoryIds.isNotEmpty) {
      parts.add(
        _selectedCategoryIds.length == 1
            ? ServiceCategory.resolve(_selectedCategoryIds.first)?.name ??
                  '1 catégorie'
            : '${_selectedCategoryIds.length} catégories',
      );
    }
    if (_minRating > 0) parts.add('$_minRating★ et +');
    if (_sort != _FreelancerSort.relevance) parts.add(_sortLabels[_sort]!);
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bandeau résultats + filtre — toute la ligne est cliquable
        GestureDetector(
          onTap: _showFilterSheet,
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: context.colors.surface,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                        TextSpan(text: '${_filteredFreelancers.length} '),
                        TextSpan(
                          text: _hasActiveFilters
                              ? _filterSummary
                              : 'prestataires',
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
        ),
        Divider(height: 1, color: context.colors.divider),

        // Freelancers list
        Expanded(
          child: Consumer<ProfileProvider>(
            builder: (context, provider, _) {
              if (provider.isLoadingFreelancers) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = _filteredFreelancers;
              if (items.isEmpty) return _buildEmptyState();
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: items.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 80,
                  color: context.colors.divider,
                ),
                itemBuilder: (context, index) {
                  final f = items[index];
                  return FreelancerListTile(
                    freelancer: Freelancer(
                      name: f['name'] as String,
                      imageUrl: f['avatar'] as String,
                      rating: f['rating'] as double,
                      job: '${f['hourlyRate']}€/h',
                      subtitle: f['category'] as String,
                      isVerified: f['isVerified'] as bool,
                    ),
                    missionsCount: f['missionsCount'] as int,
                    onTap: () => _openFreelancerProfile(f),
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
    return AppEmptyStateBlock(
      icon: Icons.search_off_rounded,
      title: 'Aucun prestataire trouvé',
      message: 'Essayez de modifier vos filtres ou votre recherche.',
      action: AppButton(
        label: 'Réinitialiser les filtres',
        variant: ButtonVariant.secondary,
        icon: Icons.refresh_rounded,
        onPressed: _resetFilters,
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedCategoryIds.clear();
      _minRating = 0;
      _sort = _FreelancerSort.relevance;
    });
  }

  static const _sortLabels = {
    _FreelancerSort.relevance: 'Pertinence',
    _FreelancerSort.ratingDesc: 'Mieux notés',
    _FreelancerSort.priceAsc: 'Prix croissant',
    _FreelancerSort.priceDesc: 'Prix décroissant',
  };

  void _showFilterSheet() {
    // Copies de travail : appliquées seulement au clic sur "Appliquer".
    var draftCategoryIds = {..._selectedCategoryIds};
    var draftMinRating = _minRating;
    var draftSort = _sort;

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
                // Handle bar
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
                        draftCategoryIds = {};
                        draftMinRating = 0;
                        draftSort = _FreelancerSort.relevance;
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

                // ── Catégories (multi-sélection) ──
                Text(
                  'Catégories',
                  style: ctx.text.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ctx.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final cat in ServiceCategory.all)
                      AppFilterChip(
                        label: cat.name,
                        icon: cat.icon,
                        color: cat.color,
                        selected: draftCategoryIds.contains(cat.id),
                        onTap: () => setSheet(() {
                          if (!draftCategoryIds.remove(cat.id)) {
                            draftCategoryIds.add(cat.id);
                          }
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Note minimale ──
                Text(
                  'Note minimale',
                  style: ctx.text.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ctx.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final threshold in [0.0, 3.0, 4.0, 4.5])
                      AppFilterChip(
                        label: threshold == 0 ? 'Toutes' : '$threshold★ et +',
                        selected: draftMinRating == threshold,
                        onTap: () => setSheet(() => draftMinRating = threshold),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Tri ──
                Text(
                  'Trier par',
                  style: ctx.text.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ctx.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in _sortLabels.entries)
                      AppFilterChip(
                        label: entry.value,
                        selected: draftSort == entry.key,
                        onTap: () => setSheet(() => draftSort = entry.key),
                      ),
                  ],
                ),
                const SizedBox(height: 28),

                AppButton(
                  label: 'Appliquer',
                  variant: ButtonVariant.black,
                  onPressed: () {
                    setState(() {
                      _selectedCategoryIds
                        ..clear()
                        ..addAll(draftCategoryIds);
                      _minRating = draftMinRating;
                      _sort = draftSort;
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
