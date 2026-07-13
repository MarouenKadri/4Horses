import 'package:flutter/material.dart';

// ─── 2. ESPACEMENTS ──────────────────────────────────────────────────────────

abstract class AppDesign {
  // ── Spacing scale ─────────────────────────────────────────────────────────
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space6 = 6;
  static const double space8 = 8;
  static const double space10 = 10;
  static const double space12 = 12;
  static const double space14 = 14;
  static const double space16 = 16;
  static const double space18 = 18;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space28 = 28;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;

  // ── Radius scale ─────────────────────────────────────────────────────────
  static const double radius4 = 4;
  static const double radius8 = 8;
  static const double radius10 = 10;
  static const double radius12 = 12;
  static const double radius14 = 14;
  static const double radius16 = 16;
  static const double radius20 = 20;
  static const double radius24 = 24;
  static const double radius28 = 28;
  static const double radius99 = 99;
  static const double radiusFull = 999;

  // ── Alias sémantiques ────────────────────────────────────────────────────
  static const double radiusXS = radius4;
  static const double radiusS = radius8;
  static const double radiusBadge = radius10;
  static const double radiusInput = radius14;
  static const double radiusButton = radius14;
  static const double radiusCard = radius14;
  static const double radius14Lg = radius14;
  static const double radiusCardLg = radius20;
  static const double radiusSheet = radius20;
  static const double radiusChip = radius20;

  // ── Padding prédéfinis ───────────────────────────────────────────────────
  static const EdgeInsets paddingPage = EdgeInsets.all(space16);
  static const EdgeInsets paddingCard = EdgeInsets.all(space16);
  static const EdgeInsets paddingCardLg = EdgeInsets.all(space20);
  static const EdgeInsets paddingInput = EdgeInsets.symmetric(
    horizontal: space16,
    vertical: 14,
  );
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(
    horizontal: space24,
    vertical: 14,
  );
  static const EdgeInsets paddingChip = EdgeInsets.symmetric(
    horizontal: space10,
    vertical: space6,
  );
  static const EdgeInsets paddingSheet = EdgeInsets.fromLTRB(
    space20,
    space16,
    space20,
    space24,
  );
}

class AppInsets {
  static const EdgeInsets a2 = EdgeInsets.all(2);
  static const EdgeInsets a3 = EdgeInsets.all(3);
  static const EdgeInsets a4 = EdgeInsets.all(4);
  static const EdgeInsets a6 = EdgeInsets.all(6);
  static const EdgeInsets a8 = EdgeInsets.all(8);
  static const EdgeInsets a10 = EdgeInsets.all(10);
  static const EdgeInsets a12 = EdgeInsets.all(12);
  static const EdgeInsets a14 = EdgeInsets.all(14);
  static const EdgeInsets a16 = EdgeInsets.all(16);
  static const EdgeInsets a18 = EdgeInsets.all(18);
  static const EdgeInsets a20 = EdgeInsets.all(20);
  static const EdgeInsets a24 = EdgeInsets.all(24);
  static const EdgeInsets a32 = EdgeInsets.all(32);
  static const EdgeInsets h8 = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets h10 = EdgeInsets.symmetric(horizontal: 10);
  static const EdgeInsets h12 = EdgeInsets.symmetric(horizontal: 12);
  static const EdgeInsets h14 = EdgeInsets.symmetric(horizontal: 14);
  static const EdgeInsets h16 = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets h20 = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets h24 = EdgeInsets.symmetric(horizontal: 24);
  static const EdgeInsets v4 = EdgeInsets.symmetric(vertical: 4);
  static const EdgeInsets v6 = EdgeInsets.symmetric(vertical: 6);
  static const EdgeInsets v8 = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets v10 = EdgeInsets.symmetric(vertical: 10);
  static const EdgeInsets v12 = EdgeInsets.symmetric(vertical: 12);
  static const EdgeInsets v13 = EdgeInsets.symmetric(vertical: 13);
  static const EdgeInsets v14 = EdgeInsets.symmetric(vertical: 14);
  static const EdgeInsets v16 = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets v17 = EdgeInsets.symmetric(vertical: 17);
  static const EdgeInsets h16v4 = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 4,
  );
  static const EdgeInsets h16v6 = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 6,
  );
  static const EdgeInsets h16v8 = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );
  static const EdgeInsets h16v10 = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 10,
  );
  static const EdgeInsets h16v12 = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
  static const EdgeInsets h16v14 = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  );
  static const EdgeInsets h16v16 = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 16,
  );
  static const EdgeInsets h16v18 = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 18,
  );
  static const EdgeInsets h20v12 = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 12,
  );
  static const EdgeInsets h20v14 = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 14,
  );
  static const EdgeInsets h20v16 = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );
  static const EdgeInsets h24v12 = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 12,
  );
  static const EdgeInsets h24v14 = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 14,
  );
  static const EdgeInsets h14v6 = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 6,
  );
  static const EdgeInsets h14v8 = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 8,
  );
  static const EdgeInsets h14v10 = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );
  static const EdgeInsets h14v12 = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );
  static const EdgeInsets h12v6 = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );
  static const EdgeInsets h12v8 = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );
  static const EdgeInsets h12v10 = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );
  static const EdgeInsets h10v4 = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  );
  static const EdgeInsets h10v5 = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 5,
  );
  static const EdgeInsets h10v6 = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  );
  static const EdgeInsets h10v8 = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 8,
  );
  static const EdgeInsets h8v2 = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 2,
  );
  static const EdgeInsets h8v4 = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  );
  static const EdgeInsets h7v2 = EdgeInsets.symmetric(
    horizontal: 7,
    vertical: 2,
  );
  static const EdgeInsets h6v3 = EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 3,
  );
  static const EdgeInsets h4v1 = EdgeInsets.symmetric(
    horizontal: 4,
    vertical: 1,
  );
}

class AppGap {
  static const SizedBox h2 = SizedBox(height: 2);
  static const SizedBox h3 = SizedBox(height: 3);
  static const SizedBox h4 = SizedBox(height: 4);
  static const SizedBox h5 = SizedBox(height: 5);
  static const SizedBox h6 = SizedBox(height: 6);
  static const SizedBox h8 = SizedBox(height: 8);
  static const SizedBox h10 = SizedBox(height: 10);
  static const SizedBox h12 = SizedBox(height: 12);
  static const SizedBox h14 = SizedBox(height: 14);
  static const SizedBox h16 = SizedBox(height: 16);
  static const SizedBox h18 = SizedBox(height: 18);
  static const SizedBox h20 = SizedBox(height: 20);
  static const SizedBox h22 = SizedBox(height: 22);
  static const SizedBox h24 = SizedBox(height: 24);
  static const SizedBox h28 = SizedBox(height: 28);
  static const SizedBox h32 = SizedBox(height: 32);
  static const SizedBox h36 = SizedBox(height: 36);
  static const SizedBox h40 = SizedBox(height: 40);
  static const SizedBox h48 = SizedBox(height: 48);
  static const SizedBox w2 = SizedBox(width: 2);
  static const SizedBox w3 = SizedBox(width: 3);
  static const SizedBox w4 = SizedBox(width: 4);
  static const SizedBox w5 = SizedBox(width: 5);
  static const SizedBox w6 = SizedBox(width: 6);
  static const SizedBox w8 = SizedBox(width: 8);
  static const SizedBox w10 = SizedBox(width: 10);
  static const SizedBox w12 = SizedBox(width: 12);
  static const SizedBox w14 = SizedBox(width: 14);
  static const SizedBox w16 = SizedBox(width: 16);
  static const SizedBox w20 = SizedBox(width: 20);
  static const SizedBox w28 = SizedBox(width: 28);
  static const SizedBox w32 = SizedBox(width: 32);
}

class AppSpacing {
  static const EdgeInsets screenPadding = AppDesign.paddingPage;
  static const SizedBox sectionGap = SizedBox(height: 24);
  static const SizedBox smallGap = SizedBox(height: 8);
}

class AppPadding {
  static const EdgeInsets card = AppDesign.paddingCard;
  static const EdgeInsets cardLarge = AppDesign.paddingCardLg;
  static const EdgeInsets page = AppDesign.paddingPage;
  static const EdgeInsets chip = AppDesign.paddingChip;
  static const EdgeInsets chipCompact = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  );
  static const EdgeInsets button = AppDesign.paddingButton;
}

class AppBarMetrics {
  static const double toolbarHeight = 68;
  static const double actionSize = 38;
  static const double actionIconSize = 22;
  static const double sectionBellIconSize = 26;
  static const double mapBackButtonSize = 40;
  static const double mapBackButtonIconSize = 18;
  static const double avatarSize = 38;
  static const double sheetAvatarSize = 48;
  static const double sheetAvatarFontSize = 20; // AppFontSize.h3
  static const double optionLeadingSize = 42;
  static const double optionLeadingIconSize = 20;
  static const double locationMaxWidth = 170;
  static const double mapPinMarkerSize = 48;
  static const double mapPinIconSize = 32;
  static const double mapPinInnerIconSize = 20;
  static const double mapTopInset = 12;
  static const double mapSideInset = 16;
  static const double loadingIndicatorSize = 14;
  static const double trailingIndicatorSize = 22;
  static const double emptyStateIconSize = 40;
  static const int bellAnimationMs = 350;
  static const double actionActiveAlpha = 0.10;
  static const double mapPinGlowAlpha = 0.4;
  static const double mapBackShadowAlpha = 0.4;
}

class AppNavMetrics {
  static const double barHeight = 56;
  static const double tabBarHeight = 46;
  static const double tabHeight = 44;
  static const double tabIndicatorWeight = 2.5;
  static const double selectedItemIconSize = 22;
  static const double fabHeight = 52;
  static const double fabIconSize = 22;
  static const double fabShadowAlpha = 0.35;
  static const double badgeTopOffset = -2;
  static const double badgeRightOffset = 6;
  static const int tapAnimationMs = 120;
  static const int tapReverseAnimationMs = 200;
  static const int itemAnimationMs = 250;
  static const int fabAnimationMs = 280;
  static const double tapScaleEnd = 0.82;
}

class AppStoryMetrics {
  static const double barHeight = 123;
  static const double circleSize = 87;
  static const double labelWidth = 96;
  static const double addIconSize = 42;
  static const double categoryIconSize = 39;
  static const double ringWidth = 4;
  static const double categoryAlpha = 0.12;
  static const double ringGradientEndAlpha = 0.55;
  static const double fallbackAlpha = 0.12;
  static const double composerBottomGradientHeight = 220;
  static const double composerTopButtonSize = 34;
  static const double composerLoaderSize = 36;
  static const double composerLoaderInnerSize = 22;
  static const double composerOverlayAlpha = 0.45;
  static const double composerCaptionAlpha = 0.55;
  static const double composerPlaceholderAlpha = 0.35;
  static const double composerPlaceholderBorderAlpha = 0.25;
  static const double composerPlaceholderContentAlpha = 0.7;
  static const double categorySelectedAlpha = 0.85;
  static const double storySheetIconSize = 52;
  static const double viewerTopGradientAlpha = 0.55;
  static const double viewerBottomGradientAlpha = 0.75;
  static const double viewerProgressBackgroundAlpha = 0.35;
  static const double viewerHeaderButtonAlpha = 0.3;
  static const double viewerCategoryBadgeAlpha = 0.25;
  static const double viewerMetaAlpha = 0.6;
  static const double ownerActionIconSize = 36;
  static const double editSheetChipHeight = 40;
  static const int editChipAnimationMs = 170;
}

class AppReviewMetrics {
  static const double distributionLabelWidth = 100;
  static const double distributionCountWidth = 22;
  static const double progressHeight = 7;
  static const double summaryIconSize = 32;
  static const double reviewAvatarRadius = 22;
  static const double satisfactionIconSize = 15;
  static const double missionIconSize = 13;
}

class AppProfileMetrics {
  static const double flatTileVerticalPadding = 11;
  static const double flatTileIconSize = 18;
  static const double flatTileTrailingIconSize = 18;
  static const double sectionBadgePadding = 7;
  static const double verificationIconSize = 22;
  static const double sheetFieldRadius = 22;
  static const double sheetFieldIconSize = 18;
  static const double sheetPrimaryActionHeight = 56;
}

class AppPaymentMetrics {
  static const double shadowBlurRadius = 12;
  static const double shadowOffsetY = 3;
  static const double addButtonHeight = 52;
  static const double commonIconSize = 18;
  static const double infoIconSize = 16;
  static const double deleteSheetIconWrapSize = 52;
  static const double deleteSheetIconSize = 26;
  static const double txLeadingBoxSize = 40;
  static const double txLeadingRadius = 11;
  static const double filterPillHeight = 34;
  static const int filterAnimationMs = 180;
  static const double pipelineDotSize = 12;
  static const double pipelineConnectorHeight = 2;
  static const double pipelineConnectorMargin = 5;
}

class AppRadius {
  static const double micro = 2;
  static const double xs = AppDesign.radiusXS;
  static const double tag = 6;
  static const double small = AppDesign.radiusS;
  static const double badge = AppDesign.radiusBadge;
  static const double input = AppDesign.radiusInput;
  static const double button = AppDesign.radiusButton;
  static const double card = AppDesign.radiusCard;
  static const double lg = AppDesign.radius16;
  static const double cardLg = AppDesign.radiusCardLg;
  static const double chip = AppDesign.radiusChip;
  static const double xl = AppDesign.radius24;
  static const double full = AppDesign.radiusFull;
}
