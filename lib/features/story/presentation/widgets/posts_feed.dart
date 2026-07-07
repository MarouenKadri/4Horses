import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_design_system.dart';
import '../../../mission/data/models/service_category.dart';
import '../../data/models/story.dart';
import '../../story_provider.dart';
import '../pages/story_viewer_page.dart';

/// Fil de posts façon Quora : un post après l'autre, en-tête auteur,
/// légende, image pleine largeur et vote ♥ directement dans le fil.
/// Trié par popularité (♥ puis récence). [onCreateTap] ajoute l'entrée
/// « Publier » (accueil prestataire uniquement).
class PostsFeed extends StatefulWidget {
  final void Function(StoryGroup group)? onProfileTap;
  final VoidCallback? onCreateTap;

  const PostsFeed({super.key, this.onProfileTap, this.onCreateTap});

  @override
  State<PostsFeed> createState() => _PostsFeedState();
}

class _PostsFeedState extends State<PostsFeed> {
  final Set<String> _pendingLike = {};

  Future<void> _toggleLike(String storyId) async {
    if (_pendingLike.contains(storyId)) return;
    setState(() => _pendingLike.add(storyId));
    await context.read<StoryProvider>().toggleLike(storyId);
    if (mounted) setState(() => _pendingLike.remove(storyId));
  }

  void _openViewer(List<StoryGroup> groups, Story story) {
    final groupIdx = groups.indexWhere((g) => g.stories.contains(story));
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => StoryViewerPage(
          groups: groups,
          initialIndex: groupIdx >= 0 ? groupIdx : 0,
          onViewed: (_) {},
          onProfileTap: widget.onProfileTap,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  void _openAuthorProfile(List<StoryGroup> groups, Story story) {
    if (widget.onProfileTap == null) return;
    final idx = groups.indexWhere((g) => g.stories.contains(story));
    if (idx >= 0) widget.onProfileTap!(groups[idx]);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();
    final groups = provider.storyGroups;
    final posts = groups.expand((g) => g.stories).toList()
      ..sort((a, b) {
        final byLikes = b.likesCount.compareTo(a.likesCount);
        return byLikes != 0 ? byLikes : b.createdAt.compareTo(a.createdAt);
      });

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: context.colors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (widget.onCreateTap != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: _PublishRow(onTap: widget.onCreateTap!),
              ),
            ),
          if (provider.isLoading && posts.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (posts.isEmpty)
            SliverToBoxAdapter(
              child: _EmptyPosts(canCreate: widget.onCreateTap != null),
            )
          else
            SliverList.separated(
              itemCount: posts.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: context.colors.divider),
              itemBuilder: (context, i) {
                final post = posts[i];
                final isPending = _pendingLike.contains(post.id);
                return _PostRow(
                  post: post,
                  // Pendant un toggle en cours, affiche l'état optimiste
                  isLiked: isPending ? !post.isLiked : post.isLiked,
                  likesCount: isPending
                      ? post.likesCount + (post.isLiked ? -1 : 1)
                      : post.likesCount,
                  onImageTap: () => _openViewer(groups, post),
                  onAuthorTap: widget.onProfileTap != null
                      ? () => _openAuthorProfile(groups, post)
                      : null,
                  onLikeTap: () => _toggleLike(post.id),
                );
              },
            ),
          const SliverToBoxAdapter(child: AppGap.h24),
        ],
      ),
    );
  }
}

class _PostRow extends StatelessWidget {
  final Story post;
  final bool isLiked;
  final int likesCount;
  final VoidCallback onImageTap;
  final VoidCallback? onAuthorTap;
  final VoidCallback onLikeTap;

  const _PostRow({
    required this.post,
    required this.isLiked,
    required this.likesCount,
    required this.onImageTap,
    this.onAuthorTap,
    required this.onLikeTap,
  });

  String get _meta {
    final category = ServiceCategory.findById(post.serviceCategory)?.name;
    final time = _timeAgo(post.createdAt);
    return category != null ? '$category · $time' : time;
  }

  static String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    return 'il y a ${diff.inDays ~/ 7} sem';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête auteur ────────────────────────────────────────
          GestureDetector(
            onTap: onAuthorTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                _AuthorAvatar(
                  imageUrl: post.authorAvatar,
                  name: post.authorName,
                ),
                AppGap.w10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        _meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelMedium?.copyWith(
                          color: context.colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Légende ───────────────────────────────────────────────
          if (post.caption.isNotEmpty) ...[
            AppGap.h10,
            Text(
              post.caption,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
          // ── Image pleine largeur ──────────────────────────────────
          if (post.imageUrl.isNotEmpty) ...[
            AppGap.h10,
            GestureDetector(
              onTap: onImageTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.network(
                    post.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _ImageFallback(),
                  ),
                ),
              ),
            ),
          ],
          // ── Barre de vote ─────────────────────────────────────────
          AppGap.h8,
          GestureDetector(
            onTap: onLikeTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      key: ValueKey(isLiked),
                      size: 20,
                      color: isLiked
                          ? AppColors.pinkRed
                          : context.colors.textSecondary,
                    ),
                  ),
                  AppGap.w6,
                  Text(
                    '$likesCount',
                    style: context.text.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textSecondary,
                    ),
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

class _AuthorAvatar extends StatelessWidget {
  final String imageUrl;
  final String name;

  const _AuthorAvatar({required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.hardEdge,
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initial(context),
            )
          : _initial(context),
    );
  }

  Widget _initial(BuildContext context) => ColoredBox(
        color: AppColors.secondary,
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: context.text.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      );
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.secondary,
      child: Icon(Icons.image_rounded, size: 32, color: AppColors.primary),
    );
  }
}

class _PublishRow extends StatelessWidget {
  final VoidCallback onTap;

  const _PublishRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 18,
              color: context.colors.textSecondary,
            ),
            AppGap.w10,
            Text(
              'Publier une réalisation…',
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPosts extends StatelessWidget {
  final bool canCreate;

  const _EmptyPosts({required this.canCreate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 26,
              color: context.colors.textSecondary,
            ),
          ),
          AppGap.h16,
          Text(
            'Aucun post pour le moment',
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          AppGap.h6,
          Text(
            canCreate
                ? 'Partagez vos réalisations pour vous faire remarquer.'
                : 'Les réalisations des prestataires apparaîtront ici.',
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
