import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/mission.dart';
import 'mission_detail_primitives.dart';

const kDetailHeroHeight = 220.0;

class MissionDetailHero extends StatefulWidget {
  final Mission mission;
  final VoidCallback onBack;

  /// Bouton menu injecté par la page parente (⋯ client ou ⋯ freelancer)
  /// null = pas de bouton menu
  final Widget? menuButton;

  const MissionDetailHero({
    super.key,
    required this.mission,
    required this.onBack,
    this.menuButton,
  });

  @override
  State<MissionDetailHero> createState() => _MissionDetailHeroState();
}

class _MissionDetailHeroState extends State<MissionDetailHero> {
  int _index = 0;
  final _ctrl = PageController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final hasImages = widget.mission.images.isNotEmpty;

    return SizedBox(
      height: kDetailHeroHeight,
      child: Stack(
        children: [
          // ── Image / placeholder ──────────────────────────────────────────
          Positioned.fill(
            child: hasImages
                ? PageView.builder(
                    controller: _ctrl,
                    itemCount: widget.mission.images.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) {
                      final src = widget.mission.images[i];
                      Widget fallback(_, __, ___) =>
                          DetailGradientPlaceholder(mission: widget.mission);
                      final image = src.startsWith('http')
                          ? Image.network(
                              src,
                              fit: BoxFit.cover,
                              errorBuilder: fallback,
                            )
                          : Image.file(
                              File(src),
                              fit: BoxFit.cover,
                              errorBuilder: fallback,
                            );
                      return GestureDetector(
                        onTap: () => _openImageViewer(i),
                        child: image,
                      );
                    },
                  )
                : DetailGradientPlaceholder(mission: widget.mission),
          ),

          // ── Gradient top (assombrit pour lisibilité boutons) ─────────────
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.78),
                      Colors.black.withValues(alpha: 0.32),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.28, 0.62],
                  ),
                ),
              ),
            ),
          ),

          // ── AppBar overlay (back + menu) ─────────────────────────────────
          Positioned(
            top: topPad + 4,
            left: 8,
            right: 8,
            child: Row(
              children: [
                DetailHeroBtn(
                  icon: Icons.arrow_back_rounded,
                  onTap: widget.onBack,
                ),
                const Spacer(),
                if (widget.menuButton != null) widget.menuButton!,
              ],
            ),
          ),

          // ── Pagination dots (le titre vit sous l'image, dans le header) ──
          if (hasImages && widget.mission.images.length > 1)
            Positioned(
              left: 20,
              bottom: 16,
              child: IgnorePointer(
                child: Row(
                  children: List.generate(
                    widget.mission.images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 6),
                      width: _index == i ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _index == i ? Colors.white : Colors.white38,
                        borderRadius: BorderRadius.circular(AppRadius.micro),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openImageViewer(int initialIndex) {
    if (widget.mission.images.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _MissionImageViewerPage(
          images: widget.mission.images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _MissionImageViewerPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _MissionImageViewerPage({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_MissionImageViewerPage> createState() =>
      _MissionImageViewerPageState();
}

class _MissionImageViewerPageState extends State<_MissionImageViewerPage> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (_, i) {
                final src = widget.images[i];
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: src.startsWith('http')
                        ? Image.network(
                            src,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white54,
                              size: 52,
                            ),
                          )
                        : Image.file(
                            File(src),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white54,
                              size: 52,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: topPad + 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                DetailHeroBtn(
                  icon: Icons.close_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.38),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '${_index + 1} / ${widget.images.length}',
                    style: context.missionSubtleCaptionStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
