import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../core/design/app_design_system.dart';
import '../../services/image_picker_service.dart';

class PhotoPicker extends StatelessWidget {
  final File? photo;
  final double size;
  final bool isCircle;
  final Function(File?) onPhotoChanged;
  final String? placeholder;

  const PhotoPicker({
    super.key,
    this.photo,
    this.size = 160,
    this.isCircle = true,
    required this.onPhotoChanged,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickPhoto(context),
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt,
              shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isCircle
                  ? null
                  : BorderRadius.circular(AppDesign.radius14),
              border: Border.all(
                color: photo != null
                    ? AppColors.primary
                    : context.colors.border,
                width: 2.5,
              ),
              image: photo != null
                  ? DecorationImage(image: FileImage(photo!), fit: BoxFit.cover)
                  : null,
            ),
            child: photo == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isCircle
                            ? Icons.person_rounded
                            : Icons.add_photo_alternate_rounded,
                        size: size * 0.38,
                        color: context.colors.textHint,
                      ),
                      if (placeholder != null) ...[
                        AppGap.h8,
                        Text(
                          placeholder!,
                          style: context.text.bodySmall?.copyWith(
                            fontSize: AppFontSize.md,
                            color: context.colors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  )
                : null,
          ),

          // ─── Badge caméra ───
          Positioned(
            bottom: 2,
            right: 2,
            child: AppIconCircle(
              icon: photo != null
                  ? Icons.edit_rounded
                  : Icons.camera_alt_rounded,
              size: size * 0.22,
              iconSize: size * 0.11,
              backgroundColor: AppColors.primary,
              iconColor: Colors.white,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto(BuildContext context) async {
    final file = await ImagePickerService.showPicker(context);
    if (file != null) {
      onPhotoChanged(file);
    }
  }
}

/// Widget compact pour afficher la photo avec option de suppression
class PhotoPreview extends StatelessWidget {
  final File photo;
  final VoidCallback onRemove;
  final VoidCallback onEdit;
  final double size;

  const PhotoPreview({
    super.key,
    required this.photo,
    required this.onRemove,
    required this.onEdit,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onEdit,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDesign.radius14),
              border: Border.all(color: AppColors.primary, width: 2),
              image: DecorationImage(
                image: FileImage(photo),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: onRemove,
            child: AppIconCircle(
              icon: Icons.close_rounded,
              size: 24,
              iconSize: 16,
              backgroundColor: AppColors.error,
              iconColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
