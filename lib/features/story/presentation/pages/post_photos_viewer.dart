import 'package:flutter/material.dart';

import '../../../../core/design/app_design_system.dart';

/// Visionneuse plein écran des photos d'UN post : swipe entre les photos,
/// pinch-to-zoom, compteur, légende optionnelle — remplace le déroulé de
/// stories partout où un post est ouvert.
class PostPhotosViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String caption;

  const PostPhotosViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.caption = '',
  });

  @override
  State<PostPhotosViewer> createState() => _PostPhotosViewerState();
}

class _PostPhotosViewerState extends State<PostPhotosViewer> {
  late final PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) => InteractiveViewer(
              maxScale: 4,
              child: Center(
                child: Image.network(
                  widget.images[i],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_rounded,
                    size: 48,
                    color: Colors.white38,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      Icons.close_rounded,
                      size: 26,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (widget.images.length > 1)
                    Text(
                      '${_current + 1}/${widget.images.length}',
                      style: context.text.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (widget.caption.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppColors.blackAlpha80],
                  ),
                ),
                child: Text(
                  widget.caption,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: Colors.white,
                    height: 1.45,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
