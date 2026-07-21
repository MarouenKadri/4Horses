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
                        color: Color.fromRGBO(0, 0, 0, 0.05),
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
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
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
                            color: Color.fromRGBO(0, 0, 0, 0.05),
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
                    if (_selectedCategoryId != null)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedCategoryId = null);
                            context.read<ProfileProvider>().loadFreelancers();
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: context.colors.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.colors.surface,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
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
      _searchController.clear();
      _selectedCategoryId = null;
    });
    context.read<ProfileProvider>().loadFreelancers();
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
                    'Catégorie',
                    style: context.text.titleMedium?.copyWith(
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
                        style: context.text.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
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
              style: context.text.labelMedium!.copyWith(
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
