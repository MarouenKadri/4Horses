import 'package:flutter/material.dart';

import '../../../../core/design/app_design_system.dart';
import '../../data/models/story.dart';
import '../mappers/story_category_presentation.dart';
import '../pages/story_viewer_page.dart';
import 'stories_bar.dart' show pickAndOpenComposer;

/// Widget stories unifié — utilisé côté client ET côté freelancer.
///
/// • [isFreelancer] = true  → affiche le bouton "Ma story / Publier" en premier
/// • [onProfileTap]         → appelé quand l'utilisateur tape sur avatar/nom
///                             → navigation vers FreelancerProfileView
class StoriesSection extends StatefulWidget {
  final List<StoryGroup> storyGroups;
  final bool isFreelancer;
  final void Function(StoryGroup group)? onProfileTap;

  const StoriesSection({
    super.key,
    required this.storyGroups,
    this.isFreelancer = false,
    this.onProfileTap,
  });

  @override
  State<StoriesSection> createState() => _StoriesSectionState();
}

class _StoriesSectionState extends State<StoriesSection> {
  final Set<String> _viewed = {};

  @override
  Widget build(BuildContext context) {
    final groups = widget.storyGroups
        .where((g) => g.stories.isNotEmpty)
        .take(8)
        .toList();

    final addSlot = widget.isFreelancer ? 1 : 0;
    final total = groups.length + addSlot;

    if (total == 0) return const SizedBox.shrink();

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
        itemCount: total,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (widget.isFreelancer && index == 0) {
            return _AddStoryCard(onTap: () => pickAndOpenComposer(context));
          }
          final idx = widget.isFreelancer ? index - 1 : index;
          final group = groups[idx];
          final isViewed = group.stories.every((s) => _viewed.contains(s.id));
          return _StoryCard(
            group: group,
            isViewed: isViewed,
            onTap: () => _openViewer(context, groups, idx),
            onProfileTap: widget.onProfileTap != null
                ? () => widget.onProfileTap!(group)
                : null,
          );
        },
      ),
    );
  }

  void _openViewer(BuildContext context, List<StoryGroup> groups, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => StoryViewerPage(
          groups: groups,
          initialIndex: index,
          onViewed: (id) => setState(() => _viewed.add(id)),
          onProfileTap: widget.onProfileTap,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}

// ─── Bouton "Ma story" (freelancer uniquement) ────────────────────────────────

class _AddStoryCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddStoryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: context.colors.surfaceAlt,
          border: Border.all(color: context.colors.border, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                size: 24,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ma story',
              style: context.storyLabelStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text('Publier', style: context.storyViewedLabelStyle),
          ],
        ),
      ),
    );
  }
}

// ─── Carte story ──────────────────────────────────────────────────────────────

class _StoryCard extends StatelessWidget {
  final StoryGroup group;
  final bool isViewed;
  final VoidCallback onTap;
  final VoidCallback? onProfileTap;

  const _StoryCard({
    required this.group,
    required this.isViewed,
    required this.onTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final story = group.stories.first;
    final catLabel = StoryCategoryPresentation.label(
      story.serviceCategory,
      fallback: 'Expertise',
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // Non-vu : anneau primaire net (signal « nouveau ») ;
          // vu : liseré neutre discret.
          border: Border.all(
            color: isViewed ? context.colors.border : context.colors.primary,
            width: isViewed ? 1 : 1.5,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Image de fond ──────────────────────────────────────────────
            story.imageUrl.isNotEmpty
                ? Image.network(
                    story.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _StoryPhotoFallback(label: story.serviceCategory),
                  )
                : _StoryPhotoFallback(label: story.serviceCategory),

            // ── Gradient overlay ───────────────────────────────────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.10),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.54),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            // ── Label catégorie (haut gauche) ──────────────────────────────
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.34),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  catLabel,
                  style: context.text.labelSmall!.copyWith(
                    fontSize: AppFontSize.tiny,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // ── Avatar + nom (bas) — tap → profil freelancer ───────────────
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: GestureDetector(
                onTap: onProfileTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.92),
                          width: 1.2,
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: group.avatarUrl.isNotEmpty
                          ? Image.network(
                              group.avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _StoryAvatarFallback(name: group.groupName),
                            )
                          : _StoryAvatarFallback(name: group.groupName),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        group.groupName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (onProfileTap != null)
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.70),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Fallbacks ────────────────────────────────────────────────────────────────

class _StoryPhotoFallback extends StatelessWidget {
  final String label;
  const _StoryPhotoFallback({required this.label});

  @override
  Widget build(BuildContext context) {
    final icon = StoryCategoryPresentation.icon(label);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.colors.successLight, context.colors.infoLight],
        ),
      ),
      child: Center(
        child: Icon(icon, size: 30, color: context.colors.textSecondary),
      ),
    );
  }
}

class _StoryAvatarFallback extends StatelessWidget {
  final String name;
  const _StoryAvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return Container(
      color: context.colors.surfaceAlt,
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: context.text.labelSmall!.copyWith(
          fontSize: AppFontSize.tiny,
          fontWeight: FontWeight.w700,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }
}
