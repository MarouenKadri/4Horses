import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../../../../story/story.dart';

class FreelancerMyPublicationsTab extends StatefulWidget {
  const FreelancerMyPublicationsTab({super.key});

  @override
  State<FreelancerMyPublicationsTab> createState() =>
      _FreelancerMyPublicationsTabState();
}

class _FreelancerMyPublicationsTabState
    extends State<FreelancerMyPublicationsTab> {
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  void _enterSelection(String id) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll(List<Story> stories) {
    setState(
      () => _selectedIds
        ..clear()
        ..addAll(stories.map((story) => story.id)),
    );
  }

  bool _isAllSelected(List<Story> stories) =>
      stories.isNotEmpty && _selectedIds.length == stories.length;

  Future<void> _deleteSelected() async {
    final provider = context.read<StoryProvider>();
    for (final id in List.of(_selectedIds)) {
      await provider.deleteStory(id);
    }
    _exitSelection();
  }

  void _openViewer(BuildContext context, List<Story> stories, int index) {
    final story = stories[index];
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) =>
            PostPhotosViewer(images: story.images, caption: story.caption),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stories = context
        .watch<StoryProvider>()
        .stories
        .where((story) => story.isOwner)
        .toList();

    if (stories.isEmpty) {
      return _MyPublicationsEmptyState(
        onAdd: () => pickAndOpenComposer(context),
      );
    }

    final allSelected = _isAllSelected(stories);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compactActions =
                  _selectionMode && constraints.maxWidth < 380;

              final title = Text(
                _selectionMode
                    ? '${_selectedIds.length} sélectionné${_selectedIds.length > 1 ? 's' : ''}'
                    : '${stories.length} publication${stories.length > 1 ? 's' : ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              );

              final selectionActions = Wrap(
                spacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    onPressed: allSelected
                        ? _exitSelection
                        : () => _selectAll(stories),
                    child: Text(allSelected ? 'Désélectionner' : 'Tout'),
                  ),
                  IconButton(
                    onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                    ),
                  ),
                ],
              );

              if (compactActions) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    AppGap.h8,
                    Align(
                      alignment: Alignment.centerRight,
                      child: selectionActions,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: title),
                  if (_selectionMode)
                    selectionActions
                  else
                    AppButton(
                      label: 'Ajouter',
                      variant: ButtonVariant.secondary,
                      icon: Icons.add_rounded,
                      iconTrailing: false,
                      height: 42,
                      width: 122,
                      onPressed: () => pickAndOpenComposer(context),
                    ),
                ],
              );
            },
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: _selectionMode
              ? Container(
                  width: double.infinity,
                  color: context.colors.surfaceAlt,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: allSelected
                            ? _exitSelection
                            : () => _selectAll(stories),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: allSelected
                                    ? context.colors.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: allSelected
                                      ? context.colors.primary
                                      : context.colors.border,
                                  width: 2,
                                ),
                              ),
                              child: allSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            AppGap.w10,
                            Text(
                              'Tout sélectionner',
                              style: context.text.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedIds.isNotEmpty) AppGap.h10,
                      if (_selectedIds.isNotEmpty)
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _deleteSelected,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                    color: AppColors.error,
                                  ),
                                  AppGap.w6,
                                  Text(
                                    'Supprimer (${_selectedIds.length})',
                                    style: context.text.bodySmall?.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(2, 2, 2, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1,
            ),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              final selected = _selectedIds.contains(story.id);
              return GestureDetector(
                onTap: () {
                  if (_selectionMode) {
                    _toggleSelect(story.id);
                  } else {
                    _openViewer(context, stories, index);
                  }
                },
                onLongPress: () => _enterSelection(story.id),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    story.imageUrl.isNotEmpty
                        ? Image.network(
                            story.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.secondary,
                              child: const Icon(
                                Icons.image_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.secondary,
                            child: const Icon(
                              Icons.image_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                    // Badges façon grille du profil public
                    if (story.images.length > 1 && !_selectionMode)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Icon(
                          Icons.collections_rounded,
                          size: 14,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    if (story.likesCount > 0 && !_selectionMode)
                      Positioned(
                        left: 5,
                        bottom: 4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              size: 12,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            AppGap.w3,
                            Text(
                              '${story.likesCount}',
                              style: context.text.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_selectionMode)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        color: selected
                            ? context.colors.primary.withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                    if (_selectionMode)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? context.colors.primary
                                : Colors.white.withValues(alpha: 0.9),
                            border: Border.all(
                              color: selected
                                  ? context.colors.primary
                                  : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 13,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MyPublicationsEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _MyPublicationsEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AppSurfaceCard(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: context.colors.border),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: context.colors.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 26,
                  color: context.colors.textPrimary,
                ),
              ),
              AppGap.h16,
              Text(
                'Aucune publication pour le moment',
                textAlign: TextAlign.center,
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              AppGap.h8,
              Text(
                'Ajoutez une photo pour commencer.',
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.4,
                ),
              ),
              AppGap.h18,
              AppButton(
                label: 'Ajouter',
                variant: ButtonVariant.secondary,
                icon: Icons.add_rounded,
                iconTrailing: false,
                width: 170,
                height: 48,
                onPressed: onAdd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
