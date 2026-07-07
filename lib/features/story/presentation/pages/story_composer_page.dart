import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../features/mission/data/models/service_category.dart';
import '../../story_provider.dart';

class StoryComposerPage extends StatefulWidget {
  final File mediaFile;
  const StoryComposerPage({super.key, required this.mediaFile});

  @override
  State<StoryComposerPage> createState() => _StoryComposerPageState();
}

class _StoryComposerPageState extends State<StoryComposerPage> {
  final _captionController = TextEditingController();
  late final PageController _mediaPageController;
  final _thumbScrollController = ScrollController();
  late List<File> _mediaFiles;
  int _currentMediaIndex = 0;
  bool _isPosting = false;
  bool _showCaption = false;
  String? _selectedCategoryId;
  bool _didAutoOpenCategorySheet = false;

  static const double _thumbW = 56;
  static const double _thumbH = 76;
  static const double _thumbSpacing = 6;

  @override
  void initState() {
    super.initState();
    _mediaFiles = [widget.mediaFile];
    _mediaPageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _didAutoOpenCategorySheet) return;
      _didAutoOpenCategorySheet = true;
      await Future<void>.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;
      await _openCategoryPicker();
    });
  }

  @override
  void dispose() {
    _mediaPageController.dispose();
    _thumbScrollController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    if (_isPosting || _selectedCategoryId == null || _mediaFiles.isEmpty) {
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _isPosting = true);

    final provider = context.read<StoryProvider>();
    var successCount = 0;
    for (final file in _mediaFiles) {
      final story = await provider.createStory(
        imageFile: file,
        caption: _captionController.text.trim(),
        serviceCategory: _selectedCategoryId ?? '',
      );
      if (story != null) successCount++;
    }

    if (!mounted) return;
    if (successCount == _mediaFiles.length) {
      Navigator.pop(context);
    } else {
      setState(() => _isPosting = false);
      showAppSnackBar(context, 'Erreur lors de la publication');
    }
  }

  Future<void> _openCategoryPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryPickerSheet(selected: _selectedCategoryId),
    );
    if (!mounted) return;
    if (selected == null) {
      Navigator.pop(context);
      return;
    }
    setState(() => _selectedCategoryId = selected);
  }

  Future<void> _addMoreMedia() async {
    if (_isPosting) return;
    final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (!mounted || picked.isEmpty) return;
    setState(() {
      _mediaFiles.addAll(picked.map((f) => File(f.path)));
      _currentMediaIndex = _mediaFiles.length - 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mediaPageController.animateToPage(
        _currentMediaIndex,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
      _scrollThumbToIndex(_currentMediaIndex);
    });
  }

  void _removeMedia(int index) {
    if (_mediaFiles.length <= 1) return;
    setState(() {
      _mediaFiles.removeAt(index);
      if (_currentMediaIndex >= _mediaFiles.length) {
        _currentMediaIndex = _mediaFiles.length - 1;
      }
    });
    _mediaPageController.jumpToPage(_currentMediaIndex);
    _scrollThumbToIndex(_currentMediaIndex);
  }

  void _scrollThumbToIndex(int index) {
    final offset = index * (_thumbW + _thumbSpacing);
    if (_thumbScrollController.hasClients) {
      _thumbScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final selectedCat = _selectedCategoryId != null
        ? ServiceCategory.findById(_selectedCategoryId!)
        : null;
    const shadows = [
      Shadow(
        color: Color.fromRGBO(0, 0, 0, 0.34),
        blurRadius: 12,
        offset: Offset(0, 2),
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Media ────────────────────────────────────────────
            PageView.builder(
              controller: _mediaPageController,
              itemCount: _mediaFiles.length,
              onPageChanged: (i) {
                setState(() => _currentMediaIndex = i);
                _scrollThumbToIndex(i);
              },
              itemBuilder: (_, i) =>
                  Image.file(_mediaFiles[i], fit: BoxFit.cover),
            ),
            // ── Gradients ────────────────────────────────────────
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withValues(
                      alpha: AppStoryMetrics.viewerTopGradientAlpha,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: AppStoryMetrics.composerBottomGradientHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(
                        alpha: AppStoryMetrics.viewerBottomGradientAlpha,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // ── Controls ─────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: bottom),
                child: Column(
                  children: [
                    // ── Ligne 1 : Annuler | Publier ───────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: _isPosting
                                ? null
                                : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: AppColors.snow,
                            ),
                            child: Text(
                              'Annuler',
                              style: context.storyComposerActionStyle.copyWith(
                                shadows: shadows,
                              ),
                            ),
                          ),
                          const Spacer(),
                          _isPosting
                              ? SizedBox(
                                  width: AppStoryMetrics.composerLoaderSize,
                                  height: AppStoryMetrics.composerLoaderSize,
                                  child: Center(
                                    child: SizedBox(
                                      width: AppStoryMetrics
                                          .composerLoaderInnerSize,
                                      height: AppStoryMetrics
                                          .composerLoaderInnerSize,
                                      child: const CircularProgressIndicator(
                                        color: AppColors.snow,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                )
                              : TextButton(
                                  onPressed: _selectedCategoryId != null
                                      ? _share
                                      : null,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 8,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    foregroundColor: AppColors.snow,
                                  ),
                                  child: Text(
                                    'Publier',
                                    style: context.storyComposerActionStyle
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.snow.withValues(
                                            alpha: _selectedCategoryId != null
                                                ? 0.96
                                                : 0.42,
                                          ),
                                          shadows: shadows,
                                        ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // ── Bottom : catégorie + thumbnails + caption ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selectedCat != null) ...[
                            GestureDetector(
                              onTap: _isPosting ? null : _openCategoryPicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedCat.color,
                                  borderRadius: BorderRadius.circular(
                                    AppDesign.radiusFull,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      selectedCat.icon,
                                      size: 15,
                                      color: AppColors.snow,
                                    ),
                                    AppGap.w6,
                                    Text(
                                      selectedCat.name,
                                      style: context.storyCategoryPillStyle
                                          .copyWith(
                                            color: AppColors.snow.withValues(
                                              alpha: 0.96,
                                            ),
                                            shadows: shadows,
                                          ),
                                    ),
                                    AppGap.w4,
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 15,
                                      color: AppColors.snow.withValues(
                                        alpha: 0.72,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AppGap.h10,
                          ],
                          _buildThumbnailStrip(shadows),
                          AppGap.h12,
                          _buildCaption(shadows),
                        ],
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

  Widget _buildThumbnailStrip(List<Shadow> shadows) {
    return SizedBox(
      height: _thumbH,
      child: ListView.separated(
        controller: _thumbScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _mediaFiles.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: _thumbSpacing),
        itemBuilder: (_, i) {
          if (i == _mediaFiles.length) {
            return GestureDetector(
              onTap: _isPosting ? null : _addMoreMedia,
              child: Container(
                width: _thumbW,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  color: AppColors.snow.withValues(alpha: 0.80),
                  size: 22,
                ),
              ),
            );
          }
          final isActive = i == _currentMediaIndex;
          return GestureDetector(
            onTap: () {
              setState(() => _currentMediaIndex = i);
              _mediaPageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: _thumbW,
                  height: _thumbH,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? AppColors.snow
                          : Colors.white.withValues(alpha: 0.18),
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.file(_mediaFiles[i], fit: BoxFit.cover),
                  ),
                ),
                if (_mediaFiles.length > 1)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: GestureDetector(
                      onTap: () => _removeMedia(i),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.72),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.snow,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaption(List<Shadow> shadows) {
    final border = Border(
      bottom: BorderSide(
        color: AppColors.snow.withValues(alpha: 0.84),
        width: 1,
      ),
    );
    if (_showCaption) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(border: border),
        child: TextField(
          controller: _captionController,
          autofocus: true,
          maxLines: 3,
          minLines: 1,
          maxLength: 200,
          style: context.storyCaptionInputStyle.copyWith(shadows: shadows),
          decoration:
              AppInputDecorations.formField(
                context,
                hintText: 'Ajouter un commentaire...',
                hintStyle: context.storyCaptionHintStyle.copyWith(
                  shadows: shadows,
                ),
                contentPadding: EdgeInsets.zero,
                noBorder: true,
                fillColor: Colors.transparent,
              ).copyWith(
                isDense: true,
                counterStyle: context.text.labelSmall!.copyWith(
                  color: AppColors.snow.withValues(alpha: 0.68),
                  shadows: shadows,
                ),
              ),
        ),
      );
    }
    return GestureDetector(
      onTap: () => setState(() => _showCaption = true),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(border: border),
        child: Text(
          'Ajouter un commentaire...',
          style: context.storyCaptionHintStyle.copyWith(shadows: shadows),
        ),
      ),
    );
  }
}

// ── Category picker bottom sheet ──────────────────────────────
class _CategoryPickerSheet extends StatelessWidget {
  final String? selected;
  const _CategoryPickerSheet({this.selected});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxSheetHeight = math.min(mediaQuery.size.height * 0.78, 560.0);
    final bottomPadding = math.max(mediaQuery.padding.bottom, 12.0);

    return SafeArea(
      top: false,
      child: AppDarkSheet(
        child: SizedBox(
          height: maxSheetHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppBottomSheetHandle(),
              AppGap.h12,
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text(
                  "Quel talent montrez-vous aujourd'hui ?",
                  style: context.text.headlineSmall!.copyWith(
                    color: AppColors.snow,
                  ),
                ),
              ),
              AppGap.h8,
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 16 + bottomPadding),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: ServiceCategory.all.length,
                  itemBuilder: (_, i) {
                    final cat = ServiceCategory.all[i];
                    final isSelected = selected == cat.id;
                    return GestureDetector(
                      onTap: () => Navigator.pop(context, cat.id),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: isSelected ? 1.0 : 0.55,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(
                                milliseconds:
                                    AppStoryMetrics.editChipAnimationMs,
                              ),
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? cat.color.withValues(alpha: 0.20)
                                    : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? cat.color.withValues(alpha: 0.55)
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                cat.icon,
                                size: 24,
                                color: isSelected ? cat.color : AppColors.snow,
                              ),
                            ),
                            AppGap.h6,
                            Text(
                              cat.name,
                              style: context.text.labelSmall!.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: AppColors.snow,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
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
        ),
      ),
    );
  }
}
