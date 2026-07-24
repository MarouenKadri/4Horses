import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_design_system.dart';
import '../../../mission/presentation/pages/client/create_mission/step_details.dart'
    show PhotoViewerPage;
import '../../story_provider.dart';

/// Composer de post façon Quora : une seule page claire — légende,
/// photos (multi), catégorie et publication au même endroit.
class PostComposerPage extends StatefulWidget {
  const PostComposerPage({super.key});

  @override
  State<PostComposerPage> createState() => _PostComposerPageState();
}

class _PostComposerPageState extends State<PostComposerPage> {
  static const _maxPhotos = 10;

  final _captionController = TextEditingController();
  final List<File> _files = [];
  bool _isPosting = false;

  bool get _canPublish => _files.isNotEmpty && !_isPosting;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  /// Même logique que l'import photos de la création de mission :
  /// feuille caméra / galerie (multi), plafonnée à [_maxPhotos].
  void _pickImages() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      builder: (sheetCtx) => AppActionSheet(
        title: 'Ajouter des photos',
        children: [
          AppActionSheetItem(
            icon: Icons.photo_camera_outlined,
            title: 'Prendre une photo',
            subtitle: 'Utiliser la caméra',
            onTap: () {
              Navigator.pop(sheetCtx);
              _takePhoto();
            },
          ),
          Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: context.colors.divider,
          ),
          AppActionSheetItem(
            icon: Icons.photo_library_outlined,
            title: 'Choisir depuis la galerie',
            subtitle: 'Sélectionner une ou plusieurs photos',
            onTap: () {
              Navigator.pop(sheetCtx);
              _pickFromGallery();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _takePhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    setState(() => _files.add(File(picked.path)));
  }

  Future<void> _pickFromGallery() async {
    final picked = await ImagePicker().pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked.isEmpty || !mounted) return;
    final remaining = _maxPhotos - _files.length;
    setState(
      () => _files.addAll(picked.take(remaining).map((f) => File(f.path))),
    );
  }

  void _removeImage(int index) {
    setState(() => _files.removeAt(index));
  }

  void _viewPhoto(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoViewerPage(
          photos: _files.map((f) => f.path).toList(),
          initialIndex: index,
          onDelete: (i) => setState(() => _files.removeAt(i)),
        ),
      ),
    );
  }

  void _confirmDeleteAll() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      builder: (ctx) => AppFormSheet(
        title: 'Supprimer toutes les photos ?',
        color: ctx.colors.surface,
        footer: Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Annuler',
                variant: ButtonVariant.outline,
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            AppGap.w12,
            Expanded(
              child: AppButton(
                label: 'Supprimer',
                variant: ButtonVariant.destructive,
                onPressed: () {
                  setState(() => _files.clear());
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSurfaceCard(
              padding: AppInsets.a16,
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 32,
              ),
            ),
            AppGap.h16,
            Text(
              '${_files.length} photo${_files.length > 1 ? 's' : ''} seront supprimées.',
              style: ctx.text.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _publish() async {
    if (!_canPublish) return;
    HapticFeedback.lightImpact();
    setState(() => _isPosting = true);

    // Un seul post avec toutes les images.
    final story = await context.read<StoryProvider>().createStory(
      imageFiles: List.of(_files),
      caption: _captionController.text.trim(),
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
                    Row(
                      children: [
                        Text(
                          'PHOTOS · ${_files.length}/$_maxPhotos',
                          style: context.text.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: context.colors.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        if (_files.isNotEmpty && !_isPosting)
                          GestureDetector(
                            onTap: _confirmDeleteAll,
                            child: Text(
                              'Tout supprimer',
                              style: context.text.labelMedium?.copyWith(
                                color: context.colors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    AppGap.h12,
                    if (_files.isEmpty)
                      _EmptyPhotoZone(onTap: _isPosting ? null : _pickImages)
                    else
                      _PhotoStrip(
                        files: _files,
                        enabled: !_isPosting,
                        canAdd: _files.length < _maxPhotos,
                        onAdd: _pickImages,
                        onRemove: _removeImage,
                        onView: _viewPhoto,
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
        height: 120,
        decoration: BoxDecoration(
          color: context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 24,
              color: context.colors.textSecondary,
            ),
            AppGap.h8,
            Text(
              'Ajouter des photos',
              style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            AppGap.h4,
            Text(
              "Caméra ou galerie, jusqu'à 10 images",
              style: context.text.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Aperçu + vignettes ───────────────────────────────────────────────────────

class _PhotoStrip extends StatelessWidget {
  final List<File> files;
  final bool enabled;
  final bool canAdd;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final void Function(int index) onView;

  const _PhotoStrip({
    required this.files,
    required this.enabled,
    required this.canAdd,
    required this.onAdd,
    required this.onRemove,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Aperçu principal — même cadrage 4:3 que le fil
        GestureDetector(
          onTap: () => onView(0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.file(files.first, fit: BoxFit.cover),
            ),
          ),
        ),
        AppGap.h10,
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: files.length + (canAdd ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0 && canAdd) {
                return GestureDetector(
                  onTap: enabled ? onAdd : null,
                  child: SizedBox(
                    width: 88,
                    height: 96,
                    child: AppSurfaceCard(
                      margin: const EdgeInsets.only(right: 10),
                      color: context.colors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.colors.border),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 22,
                            color: context.colors.textSecondary,
                          ),
                          AppGap.h6,
                          Text(
                            'Ajouter',
                            style: context.text.labelSmall?.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final photoIndex = canAdd ? index - 1 : index;
              return _PhotoThumbnail(
                file: files[photoIndex],
                index: photoIndex,
                enabled: enabled,
                onTap: () => onView(photoIndex),
                onRemove: () => onRemove(photoIndex),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  final File file;
  final int index;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PhotoThumbnail({
    required this.file,
    required this.index,
    required this.enabled,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 88,
        height: 96,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(file, fit: BoxFit.cover),
              // Dégradé bas pour la lisibilité du badge d'index
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ),
              // Badge d'index
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: AppInsets.h8v4,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: context.text.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Bouton suppression directe
              if (enabled)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: AppInsets.a6,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
