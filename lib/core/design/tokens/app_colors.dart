import 'package:flutter/material.dart';

// Source unique des couleurs de l'application.
abstract class AppColors {
  // Brand
  static const primary = Color.fromARGB(255, 87, 115, 129);
  static const primaryDark = Color.fromARGB(255, 16, 36, 46);
  static const secondary = Color(0xFFE0F2FE);

  // Surfaces
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF5F5F7);
  static const sheetBg = Color(0xFFFFFFFF);
  static const inputFill = Color(0xFFF5F5F7);

  // Borders
  static const border = Color(0xFFE8EDF3);
  static const divider = Color(0xFFE8EDF3);
  static const borderLight = Color(0xFFECECEC);

  // Text
  static const textPrimary = Color(0xFF1A1A1E);
  static const textSecondary = Color(0xFF505258);
  static const textTertiary = Color(0xFF94A3B8);
  static const textHint = Color(0xFFCBD5E1);

  // Status
  static const error = Color(0xFFBF5555);
  static const warning = Color(0xFFF59E0B);
  static const success = Color.fromARGB(255, 139, 175, 163);
  static const info = Color.fromARGB(255, 144, 167, 179);
  static const rating = Color(0xFFFFCC00);

  // Light semantic states
  static const errorLight = Color(0xFFFEE2E2);
  static const warningLight = Color(0xFFFEF3C7);
  static const successLight = Color(0xFFD1FAE5);
  static const infoLight = Color(0xFFE0F2FE);
  static const purpleLight = Color(0xFFF3E5F5);

  // Alpha / overlays
  static const whiteAlpha12 = Color(0x1FFFFFFF);
  static const blackAlpha03 = Color(0x08000000);
  static const blackAlpha04 = Color(0x0A000000);
  static const blackAlpha07 = Color(0x12000000);
  static const blackAlpha09 = Color(0x18000000);
  static const blackAlpha15 = Color(0x26000000);
  static const blackAlpha55 = Color(0x8C000000);
  static const blackAlpha80 = Color(0xCC000000);

  // Messaging
  static const messageReadBg = Color(0xFFB8FFCF);

  // Map
  static const mapSurface = Color(0xFFF0EDE8);

  // Neutrals / utility
  static const charcoal = Color(0xFF222222);
  static const ink = Color(0xFF111111);
  static const inkDark = Color(0xFF101418);
  static const snow = Color(0xFFFAFAFA);
  static const gray50 = Color(0xFFF0F1F3);
  static const gray100 = Color(0xFFEDEEF0);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF808080);
  static const gray600 = Color(0xFF8E959D);
  static const gray700 = Color(0xFF2C3137);
  static const grayD1 = Color(0xFFD1D5DB);
  static const grayStory = Color(0xFFCDD3DA);

  // Business / accent colors
  static const amber = Color(0xFFFFB800);
  static const amberBg = Color(0xFFFFF8E1);
  static const amberDark = Color(0xFFF59E0B);
  static const amberLight = Color(0xFF2A1F00);
  static const amberText = Color(0xFFB45309);
  static const blueAction = Color(0xFF2563EB);
  static const blueBg = Color(0xFFEFF6FF);
  static const blueBorder = Color(0xFFBFDBFE);
  static const blueDark = Color(0xFF1D4ED8);
  static const blueLight = Color(0xFF3B82F6);
  static const blueNavy = Color(0xFF1E40AF);
  static const deepNavy = Color(0xFF0F172A);
  static const draftAmber = Color(0xFFAA7700);
  static const errorStrong = Color(0xFFEF4444);
  static const greenActiveLight = Color(0xFF1A3A2A);
  static const greenEmerald = Color(0xFF10B981);
  static const greenForest = Color(0xFF2E7D32);
  static const greenMint = Color(0xFF66BB6A);
  static const greenNatural = Color(0xFF22C55E);
  static const indigo = Color(0xFF5856D6);
  static const indigoTW = Color(0xFF6366F1);
  static const lightBlue = Color(0xFF0A2A4A);
  static const mapGradientEnd = Color(0xFF253659);
  static const mapGradientStart = Color(0xFF1A2744);
  static const mapPin = Color(0xFF173B78);
  static const miniMapRoad = Color(0xFFE4E7EB);
  static const miniMapMinorRoad = Color(0xFFEEF0F3);
  static const miniMapWater = Color(0xFFD9E9F7);
  static const mastercardOrange = Color(0xFFEA580C);
  static const pinkRed = Color(0xFFFF3B5C);
  static const purple = Color(0xFFAF52DE);
  static const successBorder = Color(0xFF6EE7B7);
  static const successDark = Color(0xFF059669);
  static const successDarker = Color(0xFF047857);
  static const successDeep = Color(0xFF065F46);
  static const violet = Color(0xFF8B5CF6);

  // Cards / specialized text
  static const cardTitle = Color(0xFF1A1A1A);
  static const cardSubtitle = Color(0xFF6F7782);
  static const cardMeta = Color(0xFF9AA3AE);
  static const cardCaption = Color(0xFF24313D);

  // Service categories
  static const categoryMenage = Color(0xFF4CAF50);
  static const categoryJardinage = Color(0xFF8BC34A);
  static const categoryBricolage = Color(0xFFFF9800);
  static const categoryPlomberie = Color(0xFF2196F3);
  static const categoryElectricite = Color(0xFFFFC107);
  static const categoryDemenagement = Color(0xFF9C27B0);
  static const categoryPetsitting = Color(0xFFE91E63);
  static const categoryCours = Color(0xFF3F51B5);
  static const categoryMaconnerie = Color(0xFF795548);
  static const categoryMecanique = Color(0xFF546E7A);
  static const categoryGardeEnfant = Color(0xFFFF7043);
  static const categoryAidePersonnesAgees = Color(0xFF26A69A);
  static const categoryAutre = Color(0xFF78909C);

  // External brands
  static const googleBlue = Color(0xFF4285F4);
  static const googleGreen = Color(0xFF34A853);
  static const googleYellow = Color(0xFFFBBC05);
  static const googleRed = Color(0xFFEA4335);
}

/// Variantes dark mode — utilisées automatiquement par AppColorTokens
abstract class AppColorsDark {
  static const background = Color(0xFF0D1117);
  static const surface = Color(0xFF161B22);
  static const surfaceAlt = Color(0xFF1C2128);
  static const sheetBg = Color(0xFF1C2128);
  static const inputFill = Color(0xFF21262D);

  static const border = Color(0xFF30363D);
  static const divider = Color(0xFF21262D);

  static const textPrimary = Color(0xFFE6EDF3);
  static const textSecondary = Color(0xFF8B949E);
  static const textTertiary = Color(0xFF484F58);
  static const textHint = Color(0xFF30363D);
}

const appColorScheme = ColorScheme.light(
  primary: AppColors.primary,
  secondary: AppColors.secondary,
  surface: AppColors.surface,
  error: AppColors.error,
  onPrimary: Colors.white,
  onSecondary: Colors.white,
  onSurface: AppColors.textPrimary,
  onError: Colors.white,
  outline: AppColors.border,
  outlineVariant: AppColors.divider,
  surfaceContainerHighest: AppColors.surfaceAlt,
);

class AppColorTokens {
  final bool _isDark;

  AppColorTokens(BuildContext context)
      : _isDark = Theme.of(context).brightness == Brightness.dark;

  Color get primary => AppColors.primary;         // même en dark
  Color get primaryDark => AppColors.primaryDark; // même en dark

  Color get background  => _isDark ? AppColorsDark.background  : AppColors.background;
  Color get surface     => _isDark ? AppColorsDark.surface     : AppColors.surface;
  Color get surfaceAlt  => _isDark ? AppColorsDark.surfaceAlt  : AppColors.surfaceAlt;
  Color get sheetBg     => _isDark ? AppColorsDark.sheetBg     : AppColors.sheetBg;
  Color get inputFill   => _isDark ? AppColorsDark.inputFill   : AppColors.inputFill;

  Color get border      => _isDark ? AppColorsDark.border      : AppColors.border;
  Color get divider     => _isDark ? AppColorsDark.divider     : AppColors.divider;

  Color get textPrimary   => _isDark ? AppColorsDark.textPrimary   : AppColors.textPrimary;
  Color get textSecondary => _isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;
  Color get textTertiary  => _isDark ? AppColorsDark.textTertiary  : AppColors.textTertiary;
  Color get textHint      => _isDark ? AppColorsDark.textHint      : AppColors.textHint;

  Color get error        => AppColors.error;
  Color get warning      => AppColors.warning;
  Color get success      => AppColors.success;
  Color get info         => AppColors.info;
  Color get rating       => AppColors.rating;

  Color get errorLight   => AppColors.errorLight;
  Color get warningLight => AppColors.warningLight;
  Color get successLight => AppColors.successLight;
  Color get infoLight    => AppColors.infoLight;

  Color get secondary    => AppColors.secondary;
}
