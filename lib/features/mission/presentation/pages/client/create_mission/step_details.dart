import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../core/design/app_design_system.dart';
import 'mission_step_ui.dart';

/// ─────────────────────────────────────────────────────────────
/// 📝 Step 4: Details (Description + Photos) - With Camera
/// ─────────────────────────────────────────────────────────────
class StepDetails extends StatefulWidget {
  final String description;
  final List<String> photos;
  final Function(String) onDescriptionChanged;
  final Function(List<String>) onPhotosChanged;

  const StepDetails({
    super.key,
    required this.description,
    required this.photos,
    required this.onDescriptionChanged,
    required this.onPhotosChanged,
  });

  @override
  State<StepDetails> createState() => _StepDetailsState();
}

class _StepDetailsState extends State<StepDetails> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.description;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /// Prendre une photo avec la caméra
  Future<void> _takePhoto() async {
    try {
      setState(() => _isLoading = true);

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        final newPhotos = List<String>.from(widget.photos);
        newPhotos.add(image.path);
        widget.onPhotosChanged(newPhotos);
      }
    } catch (e) {
      // error handled silently
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Choisir des photos depuis la galerie (sélection multiple,
  /// dans la limite des 10 photos au total).
  Future<void> _pickFromGallery() async {
    try {
      setState(() => _isLoading = true);

      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final remaining = 10 - widget.photos.length;
        final newPhotos = List<String>.from(widget.photos)
          ..addAll(images.take(remaining).map((image) => image.path));
        widget.onPhotosChanged(newPhotos);
      }
    } catch (e) {
      // error handled silently
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removePhoto(int index) {
    final newPhotos = List<String>.from(widget.photos)..removeAt(index);
    widget.onPhotosChanged(newPhotos);
  }

  void _viewPhoto(String photoPath, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewerPage(
          photos: widget.photos,
          initialIndex: index,
          onDelete: (idx) {
            final newPhotos = List<String>.from(widget.photos);
            newPhotos.removeAt(idx);
            widget.onPhotosChanged(newPhotos);
          },
        ),
      ),
    );
  }

  void _showAddPhotoOptions() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      builder: (sheetCtx) => AppActionSheet(
        title: 'Choisir une photo',
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MissionStepHeader(
                  title: 'Décrivez votre besoin',
                  subtitle:
                      'Quelques détails bien choisis aideront les prestataires à vous répondre plus précisément.',
                ),
                const SizedBox(height: 28),
                _buildDescriptionSection(),
                const SizedBox(height: 28),
                _buildPhotosSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MissionSectionLabel(label: 'Description'),
        AppGap.h12,
        TextField(
          controller: _descriptionController,
          onChanged: widget.onDescriptionChanged,
          maxLines: 6,
          maxLength: 500,
          style: context.missionStepFieldStyle,
          decoration:
              AppInputDecorations.profileField(
                context,
                hintText:
                    "Ex: Je recherche quelqu'un pour un ménage complet de mon appartement. Merci de prévoir les zones difficiles d'accès et les surfaces fragiles.",
                radius: 18,
                prefixIcon: Icon(
                  Icons.notes_rounded,
                  size: 16,
                  color: context.colors.textHint,
                ),
              ).copyWith(
                labelText: 'Description de la mission',
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                counterStyle: context.text.labelSmall?.copyWith(
                  color: context.colors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
        ),
        AppGap.h12,
        const MissionStepHelper(
          text:
              'Plus votre description est précise, plus les propositions seront adaptées.',
        ),
      ],
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
                  widget.onPhotosChanged([]);
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
              '${widget.photos.length} photo${widget.photos.length > 1 ? 's' : ''} seront supprimées.',
              style: ctx.text.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MissionSectionLabel(label: 'Photos ${widget.photos.length}/10'),
            AppGap.w10,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_border_rounded,
                    size: 14,
                    color: context.colors.textSecondary,
                  ),
                  AppGap.w4,
                  Text(
                    'Conseillé',
                    style: context.missionSubtleCaptionStyle.copyWith(
                      fontSize: AppFontSize.xs,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (widget.photos.isNotEmpty)
              GestureDetector(
                onTap: _confirmDeleteAll,
                child: Text(
                  'Tout supprimer',
                  style: context.missionSubtleCaptionStyle.copyWith(
                    color: context.colors.error,
                  ),
                ),
              ),
          ],
        ),
        AppGap.h12,
        if (_isLoading)
          _buildLoadingState()
        else if (widget.photos.isEmpty)
          _buildEmptyPhotoState()
        else
          _buildPhotoGrid(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: context.colors.border),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildEmptyPhotoState() {
    return GestureDetector(
      onTap: widget.photos.length < 10 ? _showAddPhotoOptions : null,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppDesign.radius12),
          border: Border.all(color: context.colors.border),
        ),
        child: Center(
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
                style: context.missionButtonStyle.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              AppGap.h4,
              const MissionStepHelper(
                text: "Camera ou galerie, jusqu'a 10 images",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return Column(
      children: [
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount:
                widget.photos.length + (widget.photos.length < 10 ? 1 : 0),
            itemBuilder: (context, index) {
              // Add button
              if (index == 0 && widget.photos.length < 10) {
                return _buildAddPhotoButton();
              }

              final photoIndex = widget.photos.length < 10 ? index - 1 : index;
              return _buildPhotoThumbnail(photoIndex);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _showAddPhotoOptions,
      child: SizedBox(
        width: 88,
        height: 96,
        child: AppSurfaceCard(
          margin: const EdgeInsets.only(right: 10),
          color: context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppDesign.radius12),
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
                style: context.missionSubtleCaptionStyle.copyWith(
                  fontSize: AppFontSize.smHalf,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(int index) {
    final photo = widget.photos[index];
    final isLocalFile = !photo.startsWith('http');

    return GestureDetector(
      onTap: () => _viewPhoto(photo, index),
      child: Container(
        width: 88,
        height: 96,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(color: context.colors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              isLocalFile
                  ? Image.file(
                      File(photo),
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, error, stackTrace) {
                        return Container(
                          color: ctx.colors.divider,
                          child: Icon(
                            Icons.broken_image,
                            color: ctx.colors.textHint,
                          ),
                        );
                      },
                    )
                  : Image.network(
                      photo,
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: ctx.colors.divider,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (ctx, error, stackTrace) {
                        return Container(
                          color: ctx.colors.divider,
                          child: Icon(
                            Icons.broken_image,
                            color: ctx.colors.textHint,
                          ),
                        );
                      },
                    ),

              // Gradient overlay
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

              // Index badge
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

              // Delete button
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => _removePhoto(index),
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

/// ─────────────────────────────────────────────────────────────
/// 🖼️ Photo Viewer Page (Fullscreen)
/// ─────────────────────────────────────────────────────────────
class PhotoViewerPage extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  final Function(int)? onDelete;

  const PhotoViewerPage({
    super.key,
    required this.photos,
    required this.initialIndex,
    this.onDelete,
  });

  @override
  State<PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppPageAppBar(
        backgroundColor: Colors.black,
        title: '${_currentIndex + 1} / ${widget.photos.length}',
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: AppColors.error),
              onPressed: () {
                showAppDialog(
                  context: context,
                  title: const Text('Supprimer cette photo ?'),
                  content: const SizedBox.shrink(),
                  cancelLabel: 'Annuler',
                  confirmLabel: 'Supprimer',
                  confirmVariant: ButtonVariant.destructive,
                  onConfirm: () {
                    Navigator.pop(context);
                    widget.onDelete!(_currentIndex);
                    if (widget.photos.length == 1) {
                      Navigator.pop(context);
                    } else if (_currentIndex >= widget.photos.length - 1) {
                      setState(() {
                        _currentIndex = widget.photos.length - 2;
                      });
                    }
                  },
                );
              },
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          final photo = widget.photos[index];
          final isLocalFile = !photo.startsWith('http');

          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: isLocalFile
                  ? Image.file(
                      File(photo),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 64,
                              color: context.colors.textSecondary,
                            ),
                            AppGap.h16,
                            Text(
                              'Impossible de charger l\'image',
                              style: context.text.bodyMedium?.copyWith(
                                color: context.colors.textHint,
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : Image.network(
                      photo,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 64,
                              color: context.colors.textSecondary,
                            ),
                            AppGap.h16,
                            Text(
                              'Impossible de charger l\'image',
                              style: context.text.bodyMedium?.copyWith(
                                color: context.colors.textHint,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          );
        },
      ),
      bottomNavigationBar: widget.photos.length > 1
          ? Container(
              color: Colors.black,
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              child: SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.photos.length,
                  itemBuilder: (context, index) {
                    final photo = widget.photos[index];
                    final isLocalFile = !photo.startsWith('http');
                    final isSelected = index == _currentIndex;

                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.small),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.tag),
                          child: Opacity(
                            opacity: isSelected ? 1.0 : 0.5,
                            child: isLocalFile
                                ? Image.file(File(photo), fit: BoxFit.cover)
                                : Image.network(photo, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          : null,
    );
  }
}
