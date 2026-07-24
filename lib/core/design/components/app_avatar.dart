import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../theme/app_theme.dart';

/// Avatar circulaire unifié — remplace tous les Image.network + CircleAvatar inline.
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? fallbackName; // affiche initiales si pas d'image
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final bool isVerified; // badge vérifié en bas à droite
  final VoidCallback? onTap;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.radius = 24,
    this.fallbackName,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.isVerified = false,
    this.onTap,
  });

  String get _initials {
    if (fallbackName == null || fallbackName!.trim().isEmpty) return '?';
    final parts = fallbackName!.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? context.colors.surfaceAlt;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      onBackgroundImageError: hasImage ? (_, __) {} : null,
      child: hasImage
          ? null
          : Text(
              _initials,
              style: TextStyle(
                fontSize: radius * 0.55,
                fontWeight: FontWeight.w600,
                color: context.colors.textSecondary,
                height: 1,
              ),
            ),
    );

    if (borderWidth > 0 && borderColor != null) {
      avatar = Container(
        width: (radius + borderWidth) * 2,
        height: (radius + borderWidth) * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor!, width: borderWidth),
        ),
        child: ClipOval(child: avatar),
      );
    }

    if (isVerified) {
      final badgeSize = (radius * 0.55).clamp(10.0, 18.0);
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            bottom: -1,
            right: -1,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 1.5),
              ),
              child: Icon(
                Icons.check_rounded,
                size: badgeSize * 0.6,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }
}
