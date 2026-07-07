import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_design_system.dart';
import '../../data/models/story.dart';
import '../../story_provider.dart';
import '../pages/story_viewer_page.dart';

/// Grille de posts (3 colonnes) — remplace la rangée de stories des accueils.
/// Posts triés par popularité (♥ puis récence), compteur de likes sur chaque
/// tuile, tap → viewer plein écran. [onCreateTap] ajoute l'entrée « Publier »
/// (accueil prestataire uniquement).
class PostsGrid extends StatelessWidget {
  final void Function(StoryGroup group)? onProfileTap;
  final VoidCallback? onCreateTap;

  const PostsGrid({super.key, this.onProfileTap, this.onCreateTap});

  void _openViewer(BuildContext context, List<StoryGroup> groups, Story story) {
    final groupIdx = groups.indexWhere((g) => g.stories.contains(story));
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => StoryViewerPage(
          groups: groups,
          initialIndex: groupIdx >= 0 ? groupIdx : 0,
          onViewed: (_) {},
          onProfileTap: onProfileTap,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
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
          if (onCreateTap != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                child: _PublishRow(onTap: onCreateTap!),
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
            SliverToBoxAdapter(child: _EmptyPosts(canCreate: onCreateTap != null))
          else
            SliverPadding(
              padding: const EdgeInsets.all(2),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: 0.8,
                ),
                itemCount: posts.length,
                itemBuilder: (context, i) => _PostTile(
                  post: posts[i],
                  onTap: () => _openViewer(context, groups, posts[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PostTile extends StatelessWidget {
  final Story post;
  final VoidCallback onTap;

  const _PostTile({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          post.imageUrl.isNotEmpty
              ? Image.network(
                  post.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _TileFallback(),
                )
              : const _TileFallback(),
          // Dégradé léger pour la lisibilité du compteur
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  AppColors.blackAlpha55,
                ],
                stops: [0.0, 0.65, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 6,
            bottom: 5,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  size: 13,
                  color: Colors.white,
                ),
                AppGap.w3,
                Text(
                  '${post.likesCount}',
                  style: context.text.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TileFallback extends StatelessWidget {
  const _TileFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.secondary,
      child: Icon(Icons.image_rounded, color: AppColors.primary),
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
