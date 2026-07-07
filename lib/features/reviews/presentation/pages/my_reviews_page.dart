import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/widgets/app_segmented_tab_bar.dart';
import '../../../../core/design/app_design_system.dart';
import '../providers/review_provider.dart';
import '../widgets/reviews_error_card.dart';
import '../widgets/reviews_summary.dart';
import '../widgets/reviews_tab.dart';

class MyReviewsPage extends StatefulWidget {
  final bool isFreelancer;

  const MyReviewsPage({super.key, required this.isFreelancer});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().loadReviewsForMode(
        isFreelancer: widget.isFreelancer,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewProvider>();
    final receivedReviews = provider.receivedReviews;
    final givenReviews = provider.givenReviews;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: const AppBackButtonLeading(),
        titleWidget: Text('Mes avis', style: context.reviewPageTitleStyle),
        centerTitle: true,
        bottom: AppSegmentedTabBar(
          controller: _tabController,
          tabs: const [
            AppSegmentedTab(icon: Icons.star_rounded, label: 'Reçus'),
            AppSegmentedTab(icon: Icons.rate_review_rounded, label: 'Donnés'),
          ],
        ),
      ),
      body:
          provider.isLoading &&
              receivedReviews.isEmpty &&
              givenReviews.isEmpty &&
              provider.error == null
          ? Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            )
          : Column(
              children: [
                ReviewsSummary(reviews: receivedReviews),
                if (provider.error != null &&
                    receivedReviews.isEmpty &&
                    givenReviews.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: ReviewsErrorCard(
                      message: provider.error!,
                      onRetry: () =>
                          context.read<ReviewProvider>().loadReviewsForMode(
                            isFreelancer: widget.isFreelancer,
                          ),
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context
                        .read<ReviewProvider>()
                        .loadReviewsForMode(isFreelancer: widget.isFreelancer),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        ReviewsTab(
                          reviews: receivedReviews,
                          emptyLabel: 'Aucun avis reçu pour le moment',
                          isReceived: true,
                        ),
                        ReviewsTab(
                          reviews: givenReviews,
                          emptyLabel: 'Aucun avis donné pour le moment',
                          isReceived: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
