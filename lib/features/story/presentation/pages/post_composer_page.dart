import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_design_system.dart';
import '../../../mission/data/models/service_category.dart';
import '../../story_provider.dart';
import '../widgets/stories_bar.dart' show StoryMediaPickerSheet;

/// Composer de post façon Quora : une seule page claire — légende,
/// photos (multi), catégorie et publication au même endroit.
class PostComposerPage extends StatefulWidget {
  const PostComposerPage({super.key});

  @override
  State<PostComposerPage> createState() => _PostComposerPageState();
}

class _PostComposerPageState extends State<PostComposerPage> {
  final _captionController = TextEditingController();
  final List<File> _files = [];
  String? _categoryId;
  bool _isPosting = false;

  bool get _canPublish => _files.isNotEmpty && _categoryId != null && !_isPosting;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final source = await showAppBottomSheet<ImageSource>(
      context: context,
      wrapWithSurface: false,
      child: const StoryMediaPickerSheet(),
    );
    if (source == null || !mounted) return;

    if (source == ImageSource.camera) {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      setState(() => _files.add(File(picked.path)));
    } else {
      final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
      if (picked.isEmpty || !mounted) return;
      setState(() => _files.addAll(picked.map((f) => File(f.path))));
    }
  }

  void _removeImage(int index) {
    setState(() => _files.removeAt(index));
  }

  Future<void> _openCategorySheet() async {
    final selected = await showAppBottomSheet<String>(
      context: context,
      child: _CategorySheet(selected: _categoryId),
    );
    if (selected != null && mounted) {
      setState(() => _categoryId = selected);
    }
  }

  Future<void> _publish() async {
    if (!_canPublish) return;
    HapticFeedback.lightImpact();
    setState(() => _isPosting = true);

    // Un seul post avec toutes les images.
    final story = await context.read<StoryProvider>().createStory(
          imageFiles: List.of(_files),
          caption: _captionController.text.trim(),
          serviceCategory: _categoryId ?? '',
        );

    if (!mounted) return;
    if (story != null) {
      Navigator.pop(context);
      showAppSnackBar(context, 'Post publié');
    } else {
      setState(() => _isPosting = false);
      showAppSnackBar(context, 'Erreur lors de la publication');
    }
  }

  @override
  Widget build(BuildContext context) {
    final category =
        _categoryId != null ? ServiceCategory.findById(_categoryId!) : null;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header : fermer · titre · Publier ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _isPosting ? null : () => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      Icons.close_rounded,
                      size: 26,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Nouveau post',
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  _isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : GestureDetector(
                          onTap: _canPublish ? _publish : null,
                          behavior: HitTestBehavior.opaque,
                          child: Text(
                            'Publier',
                            style: context.text.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _canPublish
                                  ? context.colors.textPrimary
                                  : context.colors.textHint,
                            ),
                          ),
                        ),
                ],
              ),
            ),
            Divider(height: 1, color: context.colors.divider),
            // ── Corps ──────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _captionController,
                      enabled: !_isPosting,
                      minLines: 2,
                      maxLines: 6,
                      maxLength: 200,
                      style: context.text.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Décrivez votre réalisation…',
                        hintStyle: context.text.bodyLarge?.copyWith(
                          color: context.colors.textHint,
                        ),
                        border: InputBorder.none,
                        counterStyle: context.text.labelSmall?.copyWith(
                          color: context.colors.textHint,
                        ),
                      ),
                    ),
                    AppGap.h8,
                    if (_files.isEmpty)
                      _EmptyPhotoZone(onTap: _isPosting ? null : _pickImages)
                    else
                      _PhotoStrip(
                        files: _files,
                        enabled: !_isPosting,
                        onAdd: _pickImages,
                        onRemove: _removeImage,
                      ),
                    AppGap.h20,
                    // ── Catégorie ──────────────────────────────────────
                    GestureDetector(
                      onTap: _isPosting ? null : _openCategorySheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: context.colors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              category?.icon ?? Icons.sell_outlined,
                              size: 18,
                              color: category != null
                                  ? context.colors.textPrimary
                                  : context.colors.textSecondary,
                            ),
                            AppGap.w10,
                            Expanded(
                              child: Text(
                                category?.name ?? 'Choisir une catégorie',
                                style: context.text.bodyMedium?.copyWith(
                                  fontWeight: category != null
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: category != null
                                      ? context.colors.textPrimary
                                      : context.colors.textSecondary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 20,
                              color: context.colors.textSecondary,
                            ),
                          ],
                        ),
                      ),
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

// ─── Zone photo vide ──────────────────────────────────────────────────────────

class _EmptyPhotoZone extends StatelessWidget {
  final VoidCallback? onTap;

  const _EmptyPhotoZone({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 34,
                color: context.colors.textSecondary,
              ),
              AppGap.h10,
              Text(
                'Ajouter des photos',
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Aperçu + vignettes ───────────────────────────────────────────────────────

class _PhotoStrip extends StatelessWidget {
  final List<File> files;
  final bool enabled;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  const _PhotoStrip({
    required this.files,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Aperçu principal — même cadrage 4:3 que le fil
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.file(files.first, fit: BoxFit.cover),
          ),
        ),
        AppGap.h10,
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: files.length + 1,
            separatorBuilder: (_, __) => AppGap.w8,
            itemBuilder: (context, i) {
              if (i == files.length) {
                return GestureDetector(
                  onTap: enabled ? onAdd : null,
                  child: Container(
                    width: 64,
                    decoration: BoxDecoration(
                      color: context.colors.surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: context.colors.textSecondary,
                    ),
                  ),
                );
              }
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      files[i],
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (enabled && files.length > 1)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () => onRemove(i),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: context.colors.textPrimary,
                            shape: BoxShape.circle,
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
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Sheet catégorie (clair) ──────────────────────────────────────────────────

class _CategorySheet extends StatelessWidget {
  final String? selected;

  const _CategorySheet({this.selected});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.6;

    return SizedBox(
      height: maxHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Text(
              'Catégorie',
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: ServiceCategory.all.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: context.colors.divider),
              itemBuilder: (context, i) {
                final cat = ServiceCategory.all[i];
                final isSelected = cat.id == selected;
                return InkWell(
                  onTap: () => Navigator.pop(context, cat.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          cat.icon,
                          size: 20,
                          color: isSelected
                              ? context.colors.textPrimary
                              : context.colors.textSecondary,
                        ),
                        AppGap.w12,
                        Expanded(
                          child: Text(
                            cat.name,
                            style: context.text.bodyMedium?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: context.colors.textPrimary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
