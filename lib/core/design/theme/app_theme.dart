import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import '../components/app_text_field.dart';

// ─── 5. THEMES ───────────────────────────────────────────────────────────────

class AppThemeData {
  AppThemeData._();

  static const _themeError = AppColors.error;

  static ThemeData get theme => _build();

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColorsDark.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColorsDark.textPrimary,
      onError: Colors.white,
      outline: AppColorsDark.border,
      outlineVariant: AppColorsDark.divider,
      surfaceContainerHighest: AppColorsDark.surfaceAlt,
    ),
    textTheme: theme.textTheme,
  );

  static ThemeData _build() {
    final textTheme = AppType.buildTextTheme(
      primary: AppColors.textPrimary,
      secondary: AppColors.textSecondary,
      tertiary: AppColors.textTertiary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: appColorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,

      // ── Typo ────────────────────────────────────────────────────────────
      textTheme: textTheme,

      // ── AppBar ───────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: (textTheme.titleLarge ?? const TextStyle()).copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
      ),

      // ── Bottom Nav ───────────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // ── Nav Bar M3 ────────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textTertiary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((s) {
          final sel = s.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
            color: sel ? AppColors.primary : AppColors.textTertiary,
          );
        }),
      ),

      // ── Tab Bar ──────────────────────────────────────────────────────────
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textTertiary,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: AppColors.divider,
      ),

      // ── Boutons ───────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesign.radiusButton),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesign.radiusButton),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Input ────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: AppDesign.paddingInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusInput),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusInput),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusInput),
          borderSide: const BorderSide(
            color: AppInputTokens.focusColor,
            width: AppInputTokens.focusBorderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusInput),
          borderSide: const BorderSide(color: _themeError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusInput),
          borderSide: const BorderSide(color: _themeError, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textHint),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIconColor: AppColors.textTertiary,
        suffixIconColor: AppColors.textTertiary,
        errorStyle: const TextStyle(fontSize: 11, color: _themeError),
      ),

      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDesign.radiusCard)),
          side: BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Divider ──────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusChip),
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        padding: AppDesign.paddingChip,
      ),

      // ── Bottom Sheet ─────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.sheetBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDesign.radiusSheet),
          ),
        ),
      ),

      // ── Dialog ───────────────────────────────────────────────────────────
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDesign.radius16)),
        ),
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),

      // ── SnackBar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(fontSize: 14, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusCard),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Switch ───────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.white
              : AppColors.textTertiary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.border,
        ),
      ),

      // ── List Tile ────────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: AppColors.textTertiary,
        textColor: AppColors.textPrimary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // ── Icon ─────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 22),
      primaryIconTheme: const IconThemeData(color: AppColors.primary),
    );
  }
}

class AppShadows {
  static List<BoxShadow> get storyCircle => [
    BoxShadow(
      // Story circles need a very subtle lift on light surfaces.
      color: AppColors.inkDark.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.07),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.13),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get primaryButton => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get button => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];
}

class AppDecorations {
  static BoxDecoration card(BuildContext context) => BoxDecoration(
    color: context.colors.surface,
    borderRadius: BorderRadius.circular(AppRadius.card),
    border: Border.all(color: context.colors.border),
  );

  static BoxDecoration cardElevated(BuildContext context) => BoxDecoration(
    color: context.colors.surface,
    borderRadius: BorderRadius.circular(AppRadius.card),
    boxShadow: AppShadows.elevated,
  );

  static BoxDecoration primaryBadge({bool outlined = false}) => BoxDecoration(
    color: outlined
        ? Colors.transparent
        : AppColors.primary.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(AppRadius.badge),
    border: outlined ? Border.all(color: AppColors.primary, width: 1.5) : null,
  );
}

// ─── 6. BUILD CONTEXT EXTENSIONS ─────────────────────────────────────────────
// Usage : context.colors.primary  /  context.text.bodyM  /  context.isDark

extension AppDesignContext on BuildContext {
  /// Couleurs adaptées au thème courant
  AppColorTokens get colors => AppColorTokens(this);

  /// Styles de texte adaptés au thème courant
  TextTheme get text => Theme.of(this).textTheme;

  /// true si le thème courant est dark
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// ColorScheme du thème courant
  ColorScheme get scheme => Theme.of(this).colorScheme;

  bool get isAppTheme =>
      !isDark && scheme.surfaceContainerHighest == AppColors.surfaceAlt;
}

extension AppAccountTextStyles on BuildContext {
  TextStyle get accountProfileNameStyle => text.titleLarge!.copyWith(
    fontSize: AppFontSize.h2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: colors.textPrimary,
  );

  TextStyle get accountProfileMetaStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    color: colors.textSecondary,
  );

  TextStyle get accountSectionStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w600,
    color: colors.textTertiary,
    letterSpacing: 0.8,
  );

  TextStyle get accountMenuTitleStyle => text.bodyLarge!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w400,
    color: colors.textPrimary,
  );

  TextStyle get accountMenuSubtitleStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w400,
    color: colors.textTertiary,
  );

  TextStyle get accountStoryLabelStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w500,
  );

  TextStyle get accountDialogTitleStyle => text.titleLarge!.copyWith(
    fontSize: AppFontSize.title,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );
}

extension AppMissionDetailTextStyles on BuildContext {
  TextStyle get missionHeroTitleStyle => text.displayMedium!.copyWith(
    fontSize: AppFontSize.h1,
    height: 1.08,
    fontWeight: FontWeight.w700,
    color: AppColors.snow,
    letterSpacing: -0.9,
  );

  TextStyle get missionCategoryStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w600,
    color: colors.textTertiary,
    letterSpacing: 2.1,
  );

  TextStyle get missionMetaStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w500,
    color: colors.textSecondary,
  );

  TextStyle get missionPillStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w500,
    color: colors.textPrimary,
  );

  // Titre de section compact : même taille que le corps (14), la
  // hiérarchie vient du poids et du noir — corps allégé en w400.
  TextStyle get missionSectionTitleStyle => text.titleSmall!.copyWith(
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get missionSectionLabelStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w700,
    color: colors.textTertiary,
    letterSpacing: 1.2,
  );

  TextStyle get missionBodyStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    height: 1.65,
    fontWeight: FontWeight.w400,
    color: colors.textSecondary,
  );

  TextStyle get missionEmphasisBodyStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    height: 1.45,
    fontWeight: FontWeight.w500,
    color: colors.textSecondary,
  );

  TextStyle get missionPrimaryValueStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.body,
    height: 1.45,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );

  TextStyle get missionEntityNameStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.lg,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get missionEntityMetaStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w500,
    color: colors.textSecondary,
  );

  TextStyle get missionEntityRatingStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );

  TextStyle get missionDarkOverlineStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.tiny,
    fontWeight: FontWeight.w600,
    color: AppColors.snow.withValues(alpha: 0.72),
    height: 1,
  );

  TextStyle get missionDarkValueStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w800,
    color: AppColors.snow,
    letterSpacing: -0.4,
    height: 1,
  );

  TextStyle get missionButtonStyle => text.titleSmall!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w600,
  );

  TextStyle get missionSubtleCaptionStyle => text.labelMedium!.copyWith(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w500,
    color: colors.textTertiary,
  );
}

extension AppMissionStepTextStyles on BuildContext {
  TextStyle get missionStepTitleStyle => text.headlineMedium!.copyWith(
    fontSize: AppFontSize.h2,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get missionStepSubtitleStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    color: colors.textSecondary,
    height: 1.45,
  );

  TextStyle get missionStepHelperStyle => missionStepSubtitleStyle;

  TextStyle get missionStepSectionLabelStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    color: colors.textTertiary,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );

  TextStyle get missionStepFieldStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: colors.textPrimary,
  );

  TextStyle get missionStepValueStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.baseHalf,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
    height: 1.45,
  );

  TextStyle get missionStepMutedStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w500,
    color: colors.textSecondary,
  );

  TextStyle get missionStepHeadlineValueStyle => text.displayMedium!.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: colors.textPrimary,
    letterSpacing: -1,
  );

  TextStyle get missionStepCurrencyStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w500,
    color: colors.textSecondary,
    letterSpacing: 0.4,
  );

  TextStyle get missionStepChipStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.mdHalf,
    fontWeight: FontWeight.w600,
  );
}

extension AppChatTextStyles on BuildContext {
  TextStyle get chatTitleStyle => text.titleSmall!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
    letterSpacing: -0.2,
  );

  TextStyle get chatMetaStyle => text.labelMedium!.copyWith(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w400,
    color: colors.textHint,
  );

  TextStyle get chatBannerStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w500,
    color: colors.textSecondary,
  );

  TextStyle get chatPrimaryActionStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w600,
    color: AppColors.snow,
    letterSpacing: 0.1,
  );

  TextStyle get chatWarningStyle => text.labelMedium!.copyWith(
    fontSize: AppFontSize.sm,
    color: colors.error,
    height: 1.4,
  );

  TextStyle get chatEmptyStateStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w300,
    color: colors.textHint,
    letterSpacing: 0.1,
  );

  TextStyle get chatInputStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w400,
    color: colors.textPrimary,
    height: 1.45,
  );

  TextStyle get chatInputHintStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w400,
    color: colors.textHint,
  );

  TextStyle get chatSystemStyle => text.labelMedium!.copyWith(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w500,
    color: colors.textTertiary,
  );

  TextStyle get chatBubbleTextStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w400,
    color: colors.textPrimary,
    height: 1.45,
  );

  TextStyle get chatBubbleTextOnDarkStyle =>
      chatBubbleTextStyle.copyWith(color: AppColors.snow);

  TextStyle get chatTimestampStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.tiny,
    color: colors.textHint,
  );

  TextStyle get chatLocationLabelStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );
}

extension AppSheetTextStyles on BuildContext {
  TextStyle get sheetFormTitleStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.title,
    fontWeight: FontWeight.w300,
    color: colors.textPrimary,
    letterSpacing: 0.1,
  );

  TextStyle get sheetPickerTitleStyle => text.headlineSmall!.copyWith(
    fontSize: AppFontSize.xl,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );

  TextStyle get sheetPickerTitleDarkStyle =>
      sheetPickerTitleStyle.copyWith(color: AppColors.snow);

  TextStyle get sheetActionTitleStyle => text.titleSmall!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w500,
    color: colors.textPrimary,
  );

  TextStyle get sheetActionSubtitleStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w400,
    color: colors.textSecondary,
  );
}

extension AppCommonTextStyles on BuildContext {
  TextStyle get progressStepLabelStyle => text.labelMedium!.copyWith(
    fontSize: AppFontSize.smHalf,
    fontWeight: FontWeight.w600,
    color: colors.primary,
    letterSpacing: 0.2,
  );
}

extension AppBarTextStyles on BuildContext {
  TextStyle get appBarTitleStyle =>
      (Theme.of(this).appBarTheme.titleTextStyle ??
              text.titleLarge ??
              const TextStyle())
          .copyWith(color: colors.textPrimary);

  TextStyle get appBarSubtitleStyle => text.labelMedium!.copyWith(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w500,
    color: colors.primary,
  );

  TextStyle get appBarPillStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.lg,
    fontWeight: FontWeight.w800,
    color: colors.primary,
    letterSpacing: -0.3,
  );

  TextStyle get appBarAccentTitleStyle => text.headlineLarge!.copyWith(
    fontSize: AppFontSize.h2Lg,
    fontWeight: FontWeight.w800,
    color: colors.textPrimary,
    letterSpacing: -0.3,
  );

  TextStyle get appBarLocationLabelStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );

  TextStyle get appBarAvatarLabelStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w800,
    color: colors.textPrimary,
  );

  TextStyle get appBarBadgeStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.tiny,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  TextStyle get appBarPanelTitleStyle => text.titleLarge!.copyWith(
    fontSize: AppFontSize.xl,
    fontWeight: FontWeight.w800,
    color: colors.textPrimary,
  );

  TextStyle get appBarSectionLabelStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w700,
    color: colors.textTertiary,
    letterSpacing: 0.8,
  );

  TextStyle get appBarSheetAccountTitleStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.lg,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get appBarSheetAccountSubtitleStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.sm,
    color: colors.textTertiary,
  );

  TextStyle get appBarSheetItemTitleStyle => text.titleSmall!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );

  TextStyle get appBarSheetItemSubtitleStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    color: colors.textSecondary,
  );

  TextStyle get appBarMutedMetaStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    color: colors.textTertiary,
  );

  TextStyle get appBarEmptyStateStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    color: colors.textTertiary,
  );

  TextStyle get appBarSheetActionStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w500,
    color: colors.textTertiary,
  );

  TextStyle get appBarDangerActionStyle => text.titleSmall!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w600,
    color: AppColors.error,
  );

  TextStyle get appBarSearchHintStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    color: colors.textHint,
  );
}

extension AppNavTextStyles on BuildContext {
  TextStyle get navLabelStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w400,
    color: colors.textTertiary,
  );

  TextStyle get navLabelSelectedStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  TextStyle get navFabLabelStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  TextStyle get navTabLabelStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  TextStyle get navTabUnselectedLabelStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w500,
    color: colors.textSecondary,
  );
}

extension AppStoryTextStyles on BuildContext {
  TextStyle get storyLabelStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w500,
    color: colors.textPrimary,
  );

  TextStyle get storyViewedLabelStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w500,
    color: colors.textTertiary,
  );

  TextStyle get storyFallbackStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.lg,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );

  TextStyle get storySheetTitleStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.lg,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get storyCategoryPillStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  TextStyle get storyCaptionInputStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.body,
    height: 1.4,
    color: Colors.white,
  );

  TextStyle get storyCaptionHintStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.body,
    color: Colors.white.withValues(alpha: 0.5),
  );

  TextStyle get storyOverlayCaptionStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    height: 1.5,
    color: Colors.white,
  );

  TextStyle get storyComposerActionStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.lg,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    color: AppColors.snow.withValues(alpha: 0.96),
  );

  TextStyle get storyAuthorNameStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  TextStyle get storyMetaStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    color: Colors.white.withValues(alpha: 0.7),
  );

  TextStyle get storyActionStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  TextStyle get storySheetBodyStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.md,
    color: colors.textSecondary,
  );

  TextStyle get storyDangerActionStyle => text.titleSmall!.copyWith(
    fontSize: AppFontSize.title,
    fontWeight: FontWeight.w600,
    color: AppColors.error,
  );

  TextStyle get storySheetPrimaryTitleStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.lg,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get storyEditFieldStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    height: 1.45,
    color: colors.textPrimary,
  );

  TextStyle get storyEditHintStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    color: colors.textHint,
  );

  TextStyle get storyEditCounterStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.tiny,
    color: colors.textHint,
  );

  TextStyle get storySectionFieldLabelStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w600,
    color: colors.textSecondary,
  );

  TextStyle get storySecondaryActionStyle => text.labelMedium!.copyWith(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  TextStyle get storyChipLabelStyle => text.labelMedium!.copyWith(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w600,
  );

  TextStyle get storyOwnerSheetActionStyle => text.bodyMedium!.copyWith(
    fontWeight: FontWeight.w500,
    color: colors.textPrimary,
  );

  TextStyle get storyOwnerSheetDangerActionStyle => text.bodyMedium!.copyWith(
    fontWeight: FontWeight.w500,
    color: AppColors.error,
  );
}

extension AppReviewTextStyles on BuildContext {
  TextStyle get reviewPageTitleStyle => text.titleLarge!.copyWith(
    fontSize: AppFontSize.xl,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get reviewSummaryScoreStyle => text.displaySmall!.copyWith(
    fontSize: AppFontSize.d4,
    fontWeight: FontWeight.w800,
    color: colors.textPrimary,
  );

  TextStyle get reviewSummaryMetaStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    color: colors.textSecondary,
  );

  TextStyle get reviewDistributionLabelStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    color: colors.textSecondary,
  );

  TextStyle get reviewDistributionCountStyle => text.labelMedium!.copyWith(
    fontSize: AppFontSize.sm,
    color: colors.textTertiary,
  );

  TextStyle get reviewEmptyStateStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    color: colors.textSecondary,
  );

  TextStyle get reviewAuthorStyle => text.titleSmall!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get reviewMissionStyle => text.labelMedium!.copyWith(
    fontSize: AppFontSize.sm,
    color: colors.textTertiary,
  );

  TextStyle get reviewDateStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    color: colors.textTertiary,
  );

  TextStyle get reviewBadgeStyle => text.labelMedium!.copyWith(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  TextStyle get reviewCommentStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    color: colors.textSecondary,
    height: 1.5,
  );
}

extension AppProfileTextStyles on BuildContext {
  TextStyle get profilePageTitleStyle => text.titleLarge!.copyWith(
    fontSize: AppFontSize.xl,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get profileSectionTitleStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.title,
    fontWeight: FontWeight.w700,
    color: colors.textPrimary,
  );

  TextStyle get profilePrimaryLabelStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );

  TextStyle get profileSecondaryLabelStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    color: colors.textSecondary,
  );

  TextStyle get profileMetaStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.sm,
    color: colors.textSecondary,
  );

  TextStyle get profileTertiaryStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w500,
    color: colors.textTertiary,
  );

  TextStyle get profileTagStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  TextStyle get profileValueStyle => text.bodyMedium!.copyWith(
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );

  TextStyle get profileSheetTitleStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.title,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: colors.textPrimary,
  );

  TextStyle get profileSheetFieldLabelStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w400,
    color: colors.textTertiary,
  );

  TextStyle get profileSheetFieldValueStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w500,
    color: colors.textPrimary,
  );

  TextStyle get profileSheetPlaceholderStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w500,
    color: colors.textHint,
  );

  TextStyle get profileSheetSectionStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: colors.textTertiary,
  );

  TextStyle get profileSheetCounterStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.xs,
    color: colors.textTertiary,
  );

  TextStyle get profileSheetActionStyle => text.bodyMedium!.copyWith(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.w500,
    color: colors.textSecondary,
    decoration: TextDecoration.underline,
    decorationColor: colors.textSecondary,
  );

  TextStyle get profileErrorStyle => text.bodySmall!.copyWith(
    fontSize: AppFontSize.xs,
    color: AppColors.error,
  );

  TextStyle get profileSliderValueStyle => text.labelSmall!.copyWith(
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  // Basé sur titleMedium (sans height) : les TextField ne doivent pas hériter
  // du height 1.65 de bodyLarge.
  TextStyle get profileInputStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w400,
    color: colors.textPrimary,
  );
}

// Styles du visuel « carte bancaire » (aperçu live + badge de marque).
extension AppPaymentCardTextStyles on BuildContext {
  TextStyle get paymentBrandBadgeStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.tiny,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  TextStyle get paymentCardBrandStyle => text.labelSmall!.copyWith(
    fontSize: AppFontSize.tiny,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    color: Colors.white.withValues(alpha: 0.55),
  );

  TextStyle get paymentCardNumberStyle => text.titleMedium!.copyWith(
    fontSize: AppFontSize.body,
    fontWeight: FontWeight.w500,
    letterSpacing: 3,
    color: Colors.white,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  TextStyle get paymentCardMicroLabelStyle => text.labelSmall!.copyWith(
    fontSize: 8,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.5,
    color: Colors.white.withValues(alpha: 0.35),
  );

  TextStyle get paymentCardExpiryStyle => text.labelLarge!.copyWith(
    fontSize: AppFontSize.md,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    color: Colors.white,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  TextStyle get paymentCardNameStyle => text.labelSmall!.copyWith(
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    color: Colors.white.withValues(alpha: 0.75),
  );
}
