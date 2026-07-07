import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/design/app_design_system.dart';
import '../pages/story_composer_page.dart';

/// Reusable media picker sheet for stories.
class StoryMediaPickerSheet extends StatelessWidget {
  const StoryMediaPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return AppActionSheet(
      title: 'Ajouter une story',
      children: <Widget>[
        AppActionSheetItem(
          icon: Icons.photo_camera_outlined,
          title: 'Prendre une photo',
          subtitle: 'Utiliser la caméra',
          onTap: () => Navigator.pop(context, ImageSource.camera),
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
          onTap: () => Navigator.pop(context, ImageSource.gallery),
        ),
      ],
    );
  }
}

/// Helper function to pick media then open the story composer.
Future<void> pickAndOpenComposer(BuildContext context) async {
  final source = await showAppBottomSheet<ImageSource>(
    context: context,
    wrapWithSurface: false,
    child: const StoryMediaPickerSheet(),
  );
  if (source == null || !context.mounted) return;

  final picked = await ImagePicker().pickImage(
    source: source,
    imageQuality: 85,
  );
  if (picked == null || !context.mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StoryComposerPage(mediaFile: File(picked.path)),
    ),
  );
}
