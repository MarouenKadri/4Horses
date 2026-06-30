import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../features/mission/data/models/service_category.dart';
import '../../data/models/story.dart';
import '../../story_provider.dart';

class StoryViewerPage extends StatefulWidget {
  final List<StoryGroup> groups;
  final int initialIndex;
  final void Function(String groupId) onViewed;
  final void Function(StoryGroup group)? onProfileTap;

  const StoryViewerPage({
    super.key,
    required this.groups,
    required this.initialIndex,
    required this.onViewed,
    this.onProfileTap,
  });

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _progressCtrl;
  int _groupIndex = 0;
  int _storyIndex = 0;
  bool _paused = false;

  // IDs en cours de toggle (pour désactiver le bouton pendant l'async)
  final Set<String> _pendingLike = {};

  static const _duration = Duration(seconds: 6);

  StoryGroup get _group => widget.groups[_groupIndex];
  Story get _current => _group.stories[_storyIndex];

  @override
  void initState() {
    super.initState();
    _groupIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _progressCtrl = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _advance();
      })
      ..forward();
    HapticFeedback.lightImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onViewed(_group.groupId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  void _advance() {
    if (_storyIndex < _group.stories.length - 1) {
      setState(() => _storyIndex++);
      _progressCtrl.forward(from: 0);
    } else if (_groupIndex < widget.groups.length - 1) {
      _goToGroup(_groupIndex + 1);
    } else {
      Navigator.pop(context);
    }
  }

  void _goBack() {
    if (_storyIndex > 0) {
      setState(() => _storyIndex--);
      _progressCtrl.forward(from: 0);
    } else if (_groupIndex > 0) {
      _goToGroup(_groupIndex - 1);
    }
  }

  void _goToGroup(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 280), curve: Curves.easeInOut);
  }

  void _pause() {
    _paused = true;
    _progressCtrl.stop();
  }

  void _resume() {
    if (!_paused) return;
    _paused = false;
    _progressCtrl.forward();
  }

  // ── Like ──────────────────────────────────────────────────────
  Future<void> _toggleLike(String storyId) async {
    if (_pendingLike.contains(storyId)) return;
    HapticFeedback.lightImpact();
    setState(() => _pendingLike.add(storyId));
    await context.read<StoryProvider>().toggleLike(storyId);
    if (mounted) setState(() => _pendingLike.remove(storyId));
  }

  /// Trouve la version fraîche de la story dans le provider (pour les likes).
  Story _fresh(Story original) {
    final stories = context.read<StoryProvider>().stories;
    try {
      return stories.firstWhere((s) => s.id == original.id);
    } catch (_) {
      return original;
    }
  }

  // ── Owner options ─────────────────────────────────────────────
  void _showOwnerOptions() {
    _pause();
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: _OwnerOptionsSheet(
        story: _current,
        onEdit: () {
          Navigator.pop(context);
          _showEditSheet();
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete();
        },
      ),
    ).then((_) {
      if (mounted && !_paused) _resume();
      _paused = false;
    });
  }

  void _showEditSheet() {
    _pause();
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: _EditStorySheet(
        story: _current,
        onSaved: (caption, catId) async {
          Navigator.pop(context);
          final ok = await context.read<StoryProvider>().updateStory(
                _current.id,
                caption: caption,
                serviceCategory: catId,
              );
          if (mounted && ok) {
            showAppSnackBar(
              context,
              'Story modifiée ✓',
              duration: Duration(seconds: 2),
            );
          }
        },
      ),
    ).then((_) {
      if (mounted) {
        _paused = false;
        _resume();
      }
    });
  }

  void _confirmDelete() {
    _pause();
    final storyId = _current.id;
    final bottom = MediaQuery.of(context).padding.bottom;
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, bottom + 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Card principale : titre + bouton destructif
            AppSurfaceCard(
              padding: EdgeInsets.zero,
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Column(
                children: [
                  Padding(
                    padding: AppInsets.h20v14,
                    child: Text(
                      'Supprimer cette story ?',
                      textAlign: TextAlign.center,
                      style: context.storySheetBodyStyle,
                    ),
                  ),
                  Divider(height: 0.5, thickness: 0.5, color: context.colors.divider),
                  InkWell(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.card)),
                    onTap: () async {
                      Navigator.pop(context);
                      await context.read<StoryProvider>().deleteStory(storyId);
                      if (mounted) Navigator.pop(context);
                    },
                    child: Padding(
                      padding: AppInsets.v17,
                      child: Center(
                        child: Text(
                          'Supprimer',
                          style: context.storyDangerActionStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppGap.h8,
            // Bouton Annuler séparé
            AppSurfaceCard(
              padding: EdgeInsets.zero,
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () {
                  Navigator.pop(context);
                  _paused = false;
                  _resume();
                },
                child: Padding(
                  padding: AppInsets.v17,
                  child: Center(
                    child: Text(
                      'Annuler',
                      style: context.text.titleLarge,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      if (mounted) {
        _paused = false;
        _resume();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch pour que le viewer se rebuilde quand les likes changent dans le provider
    context.watch<StoryProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.groups.length,
        onPageChanged: (i) {
          setState(() {
            _groupIndex = i;
            _storyIndex = 0;
          });
          _progressCtrl.forward(from: 0);
          widget.onViewed(widget.groups[i].groupId);
          HapticFeedback.lightImpact();
        },
        itemBuilder: (_, gIdx) {
          final group = widget.groups[gIdx];
          final story = gIdx == _groupIndex ? _current : group.stories.first;
          final isActive = gIdx == _groupIndex;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.network(story.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: AppColors.deepNavy)),
              // Gradient overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.25, 0.6, 1],
                    colors: [
                      Colors.black.withValues(alpha: AppStoryMetrics.viewerTopGradientAlpha),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: AppStoryMetrics.viewerBottomGradientAlpha),
                    ],
                  ),
                ),
              ),
              // Tap zones
              if (isActive)
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _goBack,
                      onLongPressStart: (_) => _pause(),
                      onLongPressEnd: (_) => _resume(),
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox.expand(),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _advance,
                      onLongPressStart: (_) => _pause(),
                      onLongPressEnd: (_) => _resume(),
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ]),
              // UI overlay
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isActive) _buildProgressBars(),
                    AppGap.h8,
                    _buildHeader(group, isActive: isActive),
                    const Spacer(),
                    _buildBottomContent(story),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressBars() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: List.generate(
          _group.stories.length,
          (i) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedBuilder(
                animation: _progressCtrl,
                builder: (_, __) {
                  final value = i < _storyIndex
                      ? 1.0
                      : i == _storyIndex
                          ? _progressCtrl.value
                          : 0.0;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.micro),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 2.5,
                      backgroundColor: Colors.white.withValues(alpha: 
                        AppStoryMetrics.viewerProgressBackgroundAlpha,
                      ),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(StoryGroup group, {bool isActive = false}) {
    final isOwner = isActive && _current.isOwner;
    return Padding(
      padding: AppInsets.h12,
      child: Row(
        children: [
          // Avatar + nom — tap → profil freelancer
          GestureDetector(
            onTap: widget.onProfileTap != null
                ? () {
                    Navigator.pop(context);
                    widget.onProfileTap!(group);
                  }
                : null,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (group.isAuthorGroup)
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: group.avatarUrl.isNotEmpty
                          ? Image.network(group.avatarUrl, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _avatarFallback(context, group.groupName))
                          : _avatarFallback(context, group.groupName),
                    ),
                  )
                else
                  Builder(builder: (_) {
                    final cat = ServiceCategory.findById(group.categoryId);
                    return Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (cat?.themedColor(context) ?? context.colors.primary).withValues(alpha: 
                          AppStoryMetrics.viewerCategoryBadgeAlpha,
                        ),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                          cat?.icon ?? Icons.photo_library_rounded,
                          color: Colors.white,
                          size: 22),
                    );
                  }),
                AppGap.w10,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.groupName,
                      style: context.storyActionStyle.copyWith(
                        fontSize: AppFontSize.body,
                      ),
                    ),
                    Text(
                      group.isAuthorGroup
                          ? 'Prestataire'
                          : '${group.stories.length} réalisation${group.stories.length > 1 ? 's' : ''}',
                      style: context.storyMetaStyle,
                    ),
                  ],
                ),
                if (widget.onProfileTap != null) ...[
                  AppGap.w6,
                  const Icon(Icons.chevron_right_rounded,
                      color: Colors.white70, size: 18),
                ],
              ],
            ),
          ),
          const Spacer(),
          // ⋯ options (owner only)
          if (isOwner) ...[
            GestureDetector(
              onTap: _showOwnerOptions,
              child: Container(
                padding: AppInsets.a6,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 
                    AppStoryMetrics.viewerHeaderButtonAlpha,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.more_vert_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            AppGap.w6,
          ],
          // Close
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: AppInsets.a6,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 
                  AppStoryMetrics.viewerHeaderButtonAlpha,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(BuildContext context, String name) => Container(
        color: context.colors.primary.withValues(alpha: 0.18),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: context.storyFallbackStyle,
          ),
        ),
      );

  Widget _buildBottomContent(Story story) {
    final fresh = _fresh(story);
    // Pendant un toggle en cours, affiche l'état optimiste inversé
    final isPending = _pendingLike.contains(story.id);
    final isLiked = isPending ? !fresh.isLiked : fresh.isLiked;
    final count = isPending
        ? fresh.likesCount + (fresh.isLiked ? -1 : 1)
        : fresh.likesCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (story.caption.isNotEmpty) ...[
            Text(
              story.caption,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.storyOverlayCaptionStyle,
            ),
            AppGap.h8,
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // ── Heure ───────────────────────────────────────
              Icon(Icons.access_time_rounded,
                  size: 12,
                  color: Colors.white.withValues(alpha: AppStoryMetrics.viewerMetaAlpha)),
              AppGap.w3,
              Text(
                _timeAgo(story.createdAt),
                style: context.storyMetaStyle.copyWith(
                  color: Colors.white.withValues(alpha: AppStoryMetrics.viewerMetaAlpha),
                ),
              ),
              AppGap.w16,
              // ── Like button ─────────────────────────────────
              GestureDetector(
                onTap: () => _toggleLike(story.id),
                behavior: HitTestBehavior.opaque,
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
                        color: isLiked ? AppColors.pinkRed : Colors.white,
                        size: 26,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 6),
                        ],
                      ),
                    ),
                    AppGap.w5,
                    Text(
                      '$count',
                      style: context.text.labelSmall?.copyWith(
                        color: isLiked
                            ? Colors.white
                            : Colors.white.withValues(alpha: AppStoryMetrics.viewerMetaAlpha),
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(color: Colors.black45, blurRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays}j';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─────────────────────────────────────────────────────────────
// ⋯ Owner options sheet
// ─────────────────────────────────────────────────────────────
class _OwnerOptionsSheet extends StatelessWidget {
  final Story story;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OwnerOptionsSheet({
    required this.story,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppActionSheet(
      title: 'Options',
      dark: false,
      header: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Image.network(
                  story.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: context.colors.primary.withValues(alpha: 0.14),
                    child: Icon(Icons.image_rounded, color: context.colors.primary),
                  ),
                ),
              ),
            ),
            AppGap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.caption.isNotEmpty ? story.caption : 'Story',
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(_timeAgo(story.createdAt), style: context.text.labelMedium),
                ],
              ),
            ),
          ],
        ),
      ),
      children: [
        const Divider(height: 1, indent: 20, endIndent: 20),
        AppActionSheetItem(
          icon: Icons.edit_rounded,
          title: 'Modifier la story',
          onTap: onEdit,
          dark: false,
        ),
        AppActionSheetItem(
          icon: Icons.delete_outline_rounded,
          title: 'Supprimer la story',
          destructive: true,
          onTap: onDelete,
          dark: false,
        ),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─────────────────────────────────────────────────────────────
// ✏️ Edit story sheet — style Instagram
// ─────────────────────────────────────────────────────────────
class _EditStorySheet extends StatefulWidget {
  final Story story;
  final Future<void> Function(String caption, String categoryId) onSaved;

  const _EditStorySheet({required this.story, required this.onSaved});

  @override
  State<_EditStorySheet> createState() => _EditStorySheetState();
}

class _EditStorySheetState extends State<_EditStorySheet> {
  late final TextEditingController _caption;
  late String _categoryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _caption = TextEditingController(text: widget.story.caption);
    _categoryId = widget.story.serviceCategory;
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: AppFormSheet(
        title: 'Modifier la story',
        color: context.colors.surface,
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        footer: Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Annuler',
                variant: ButtonVariant.outline,
                isEnabled: !_saving,
                onPressed: _saving ? null : () => Navigator.pop(context),
              ),
            ),
            AppGap.w10,
            Expanded(
              flex: 2,
              child: AppButton(
                label: 'Enregistrer',
                variant: ButtonVariant.primary,
                isLoading: _saving,
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        await widget.onSaved(_caption.text.trim(), _categoryId);
                      },
              ),
            ),
          ],
        ),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Aperçu image + légende ───────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.input),
                child: SizedBox(
                  width: 62,
                  height: 78,
                  child: Image.network(
                    widget.story.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: context.colors.primary.withValues(alpha: 0.14),
                      child: Icon(Icons.image_rounded, color: context.colors.primary),
                    ),
                  ),
                ),
              ),
              AppGap.w12,
              Expanded(
                child: TextField(
                  controller: _caption,
                  maxLines: 4,
                  minLines: 3,
                  maxLength: 200,
                  style: context.storyEditFieldStyle,
                  decoration: AppInputDecorations.formField(
                    context,
                    hintText: 'Ajouter une légende…',
                    hintStyle: context.storyEditHintStyle,
                    fillColor: context.colors.surfaceAlt,
                    contentPadding: AppInsets.h12v10,
                  ).copyWith(
                    counterStyle: context.storyEditCounterStyle,
                  ),
                ),
              ),
            ],
          ),

          // ── Catégorie ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                Text('Catégorie',
                    style: context.storySectionFieldLabelStyle),
                const Spacer(),
                if (_categoryId.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _categoryId = ''),
                    child: Text('Retirer', style: context.storySecondaryActionStyle),
                  ),
              ],
            ),
          ),

          // Chips horizontaux
          SizedBox(
            height: AppStoryMetrics.editSheetChipHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: AppInsets.h16,
              itemCount: ServiceCategory.all.length,
              itemBuilder: (_, i) {
                final cat = ServiceCategory.all[i];
                final sel = _categoryId == cat.id;
                final catColor = cat.themedColor(context);
                return GestureDetector(
                  onTap: () =>
                      setState(() => _categoryId = sel ? '' : cat.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: AppStoryMetrics.editChipAnimationMs),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? catColor : catColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color: sel
                            ? catColor
                            : catColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icon,
                            size: 14,
                            color: sel ? Colors.white : catColor),
                        AppGap.w5,
                        Text(cat.name,
                            style: context.storyChipLabelStyle.copyWith(
                              color: sel ? Colors.white : catColor,
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        ],
      ),
      ),
    );
  }
}
