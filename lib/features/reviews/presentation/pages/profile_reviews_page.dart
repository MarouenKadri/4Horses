import 'package:flutter/material.dart';

import '../../../../core/design/app_design_system.dart';
import '../../data/repositories/supabase_review_repository.dart';
import '../../domain/entities/review.dart';
import '../widgets/reviews_error_card.dart';
import '../widgets/reviews_summary.dart';
import '../widgets/reviews_tab.dart';

class ProfileReviewsPage extends StatefulWidget {
  final String profileId;
  final String profileName;
  final String profileAvatar;
  final String reviewerUserType;

  const ProfileReviewsPage({
    super.key,
    required this.profileId,
    required this.profileName,
    required this.profileAvatar,
    required this.reviewerUserType,
  });

  @override
  State<ProfileReviewsPage> createState() => _ProfileReviewsPageState();
}

class _ProfileReviewsPageState extends State<ProfileReviewsPage> {
  final _repository = SupabaseReviewRepository();
  List<Review> _reviews = const [];
  bool _isLoading = false;
  String? _error;

  bool get _fromClients => widget.reviewerUserType == 'client';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reviews = await _repository.getReceivedReviewsByReviewerType(
        revieweeId: widget.profileId,
        reviewerUserType: widget.reviewerUserType,
      );
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger les avis';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _fromClients
        ? 'Avis donnés par des clients'
        : 'Avis donnés par des freelancers';

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: const AppBackButtonLeading(),
        titleWidget: Text('Avis', style: context.reviewPageTitleStyle),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: context.colors.primary))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: widget.profileAvatar.isNotEmpty
                            ? NetworkImage(widget.profileAvatar)
                            : null,
                        backgroundColor: context.colors.surfaceAlt,
                        child: widget.profileAvatar.isEmpty
                            ? Text(
                                widget.profileName.isNotEmpty
                                    ? widget.profileName[0].toUpperCase()
                                    : '?',
                                style: context.text.titleMedium,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.profileName,
                              style: context.text.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: context.text.bodySmall
                                  ?.copyWith(color: context.colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ReviewsSummary(reviews: _reviews),
                if (_error != null && _reviews.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: ReviewsErrorCard(message: _error!, onRetry: _load),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ReviewsTab(
                      reviews: _reviews,
                      emptyLabel: _fromClients
                          ? 'Aucun avis client pour le moment'
                          : 'Aucun avis freelancer pour le moment',
                      isReceived: true,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

