import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/widgets/app_segmented_tab_bar.dart';
import '../../../../core/design/app_design_system.dart';
import '../providers/review_provider.dart';
import '../reviews_view_config.dart';
import '../widgets/reviews_error_card.dart';
import '../widgets/reviews_summary.dart';
import '../widgets/reviews_tab.dart';

/// Page d'avis unique, pilotée par [ReviewsViewConfig].
///
/// - [ReviewsViewConfig.myAccount]      → 2 onglets, provider global
/// - [ReviewsViewConfig.publicProfile]  → reçus seulement, provider local isolé
class ReviewsPage extends StatelessWidget {
  final ReviewsViewConfig config;

  const ReviewsPage({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    if (config.isPublicProfile) {
      // Provider isolé : ne pollue pas le state global de l'utilisateur connecté.
      return ChangeNotifierProvider(
        create: (_) => ReviewProvider(autoLoad: false)
          ..loadReceivedFor(config.userId),
        child: _ReviewsPageContent(config: config),
      );
    }
    // Mon compte : réutilise le provider global déjà enregistré.
    return _ReviewsPageContent(config: config);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contenu partagé — reçoit sa config, lit le provider du contexte
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewsPageContent extends StatefulWidget {
  final ReviewsViewConfig config;
  const _ReviewsPageContent({required this.config});

  @override
  State<_ReviewsPageContent> createState() => _ReviewsPageContentState();
}

class _ReviewsPageContentState extends State<_ReviewsPageContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool get _hasTabs => widget.config.showGivenTab;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _hasTabs ? 2 : 1, vsync: this);

    if (!widget.config.isPublicProfile) {
      // Mon compte : déclenche le chargement si pas déjà fait.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ReviewProvider>().loadReviews();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewProvider>();
    final received = provider.receivedReviews;
    final given = provider.givenReviews;
    final isLoading = provider.isLoading && received.isEmpty && given.isEmpty;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: const AppBackButtonLeading(),
        titleWidget: Text(widget.config.title, style: context.reviewPageTitleStyle),
        centerTitle: true,
        bottom: _hasTabs
            ? AppSegmentedTabBar(
                controller: _tabController,
                tabs: const [
                  AppSegmentedTab(icon: Icons.star_rounded, label: 'Reçus'),
                  AppSegmentedTab(
                      icon: Icons.rate_review_rounded, label: 'Donnés'),
                ],
              )
            : null,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: context.colors.primary))
          : Column(
              children: [
                ReviewsSummary(reviews: received),
                if (provider.error != null && received.isEmpty && given.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: ReviewsErrorCard(
                      message: provider.error!,
                      onRetry: () => widget.config.isPublicProfile
                          ? context
                              .read<ReviewProvider>()
                              .loadReceivedFor(widget.config.userId)
                          : context.read<ReviewProvider>().loadReviews(),
                    ),
                  ),
                Expanded(
                  child: _hasTabs
                      ? RefreshIndicator(
                          onRefresh: () =>
                              context.read<ReviewProvider>().loadReviews(),
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              ReviewsTab(
                                reviews: received,
                                emptyLabel: 'Aucun avis reçu pour le moment',
                                isReceived: true,
                              ),
                              ReviewsTab(
                                reviews: given,
                                emptyLabel: 'Aucun avis donné pour le moment',
                                isReceived: false,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => context
                              .read<ReviewProvider>()
                              .loadReceivedFor(widget.config.userId),
                          child: ReviewsTab(
                            reviews: received,
                            emptyLabel: 'Aucun avis pour le moment',
                            isReceived: true,
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
