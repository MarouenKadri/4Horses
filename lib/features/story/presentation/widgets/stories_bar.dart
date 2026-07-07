import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/design/app_design_system.dart';
import '../pages/post_composer_page.dart';

/// Reusable media picker sheet for posts.
class StoryMediaPickerSheet extends StatelessWidget {
  const StoryMediaPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return AppActionSheet(
      title: 'Ajouter une photo',
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
          subtitle: 'Sélectionner des photos',
          onTap: () => Navigator.pop(context, ImageSource.gallery),
        ),
      ],
    );
  }
}

/// Ouvre le composer de post (la sélection des photos se fait dedans).
Future<void> pickAndOpenComposer(BuildContext context) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const PostComposerPage()),
  );
}
