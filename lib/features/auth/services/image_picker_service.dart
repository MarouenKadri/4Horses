import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/design/app_design_system.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Ouvre la caméra et retourne le fichier image
  static Future<File?> pickFromCamera({int imageQuality = 80}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        preferredCameraDevice: CameraDevice.front,
      );
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      debugPrint('Erreur caméra: $e');
    }
    return null;
  }

  /// Ouvre la galerie et retourne le fichier image
  static Future<File?> pickFromGallery({int imageQuality = 80}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
      );
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      debugPrint('Erreur galerie: $e');
    }
    return null;
  }

  /// Affiche un bottom sheet pour choisir la source
  static Future<File?> showPicker(BuildContext context) async {
    ImageSource? source = await showAppBottomSheet<ImageSource>(
      context: context,
      wrapWithSurface: false,
      builder: (ctx) => _ImagePickerSheet(
        onCameraTap: () => Navigator.pop(ctx, ImageSource.camera),
        onGalleryTap: () => Navigator.pop(ctx, ImageSource.gallery),
      ),
    );

    if (source == null) return null;

    if (source == ImageSource.camera) {
      return await pickFromCamera();
    } else {
      return await pickFromGallery();
    }
  }
}

class _ImagePickerSheet extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  const _ImagePickerSheet({
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppActionSheet(
      title: 'Choisir une photo',
      children: [
        AppActionSheetItem(
          icon: Icons.photo_camera_outlined,
          title: 'Prendre une photo',
          subtitle: 'Utiliser la caméra',
          onTap: onCameraTap,
        ),
        const Divider(
          height: 1,
          indent: 20,
          endIndent: 20,
          color: AppColors.whiteAlpha12,
        ),
        AppActionSheetItem(
          icon: Icons.photo_library_outlined,
          title: 'Choisir depuis la galerie',
          subtitle: 'Sélectionner une photo',
          onTap: onGalleryTap,
        ),
      ],
    );
  }
}
