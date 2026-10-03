import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic colours that ColorScheme does not provide.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color like;
  final Color pass;
  final Color spark;
  final Color verified;
  final Color subtleText;
  final Color photoScrim;
  final Color onPhoto;
  final Color glowA;
  final Color glowB;

  const AppColorsExtension({
    required this.like,
    required this.pass,
    required this.spark,
    required this.verified,
    required this.subtleText,
    required this.photoScrim,
    required this.onPhoto,
    required this.glowA,
    required this.glowB,
  });

  @override
  AppColorsExtension copyWith({
    Color? like,
    Color? pass,
    Color? spark,
    Color? verified,
    Color? subtleText,
    Color? photoScrim,
    Color? onPhoto,
    Color? glowA,
    Color? glowB,
  }) {
    return AppColorsExtension(
      like: like ?? this.like,
      pass: pass ?? this.pass,
      spark: spark ?? this.spark,
      verified: verified ?? this.verified,
      subtleText: subtleText ?? this.subtleText,
      photoScrim: photoScrim ?? this.photoScrim,
      onPhoto: onPhoto ?? this.onPhoto,
      glowA: glowA ?? this.glowA,
      glowB: glowB ?? this.glowB,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      like: Color.lerp(like, other.like, t)!,
      pass: Color.lerp(pass, other.pass, t)!,
      spark: Color.lerp(spark, other.spark, t)!,
      verified: Color.lerp(verified, other.verified, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      photoScrim: Color.lerp(photoScrim, other.photoScrim, t)!,
      onPhoto: Color.lerp(onPhoto, other.onPhoto, t)!,
      glowA: Color.lerp(glowA, other.glowA, t)!,
      glowB: Color.lerp(glowB, other.glowB, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  static const double spacingXxs = 2.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 20.0;
  static const double radiusCard = 24.0;
  static const double radiusSheet = 28.0;
  static const double radiusPill = 100.0;

  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 30.0;
  static const double iconXl = 48.0;

  static const double buttonHeight = 52.0;
  static const double actionSmall = 52.0;
  static const double actionLarge = 64.0;
  static const double actionHero = 76.0;
  static const double thumbnailSize = 48.0;
  static const double matchAvatar = 84.0;
  static const double matchCellWidth = 120.0;
  static const double matchCellHeight = 168.0;
  static const double avatarLg = 112.0;
  static const double illustrationSize = 180.0;
  static const double unreadDot = 14.0;
  static const double sparkDot = 8.0;
  static const double skeletonLine = 12.0;
  static const double logoRing = 18.0;
  static const double indicatorHeight = 3.0;
  static const double maxCardWidth = 480.0;
  static const double galleryHeightFactor = 0.58;

  static const double shadowBlur = 28.0;
  static const double shadowOffset = 12.0;
  static const double elevationAction = 4.0;

  static const double opacityNone = 0.0;
  static const double opacitySubtle = 0.12;
  static const double opacityShadow = 0.16;
  static const double opacityChipOnPhoto = 0.2;
  static const double opacityBorderSoft = 0.35;
  static const double opacityDisabled = 0.38;
  static const double opacityScrimMid = 0.55;
  static const double opacityHint = 0.65;
  static const double opacityGlass = 0.9;

  static const double borderDefault = 1.0;
  static const double borderThick = 2.0;
  static const double borderStamp = 3.0;

  static final ThemeData lightTheme = _buildTheme(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFA8432A),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFFA8432A),
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFFFBDDD2),
      onPrimaryContainer: const Color(0xFF3D1003),
      secondary: const Color(0xFF2E6A57),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFFD3EADF),
      onSecondaryContainer: const Color(0xFF0B2A1F),
      tertiary: const Color(0xFF8A5F0E),
      onTertiary: const Color(0xFFFFFFFF),
      tertiaryContainer: const Color(0xFFF6E2B8),
      onTertiaryContainer: const Color(0xFF2C1C00),
      surface: const Color(0xFFFBF7F2),
      onSurface: const Color(0xFF1F1A17),
    ),
    appColors: const AppColorsExtension(
      like: Color(0xFF2E6A57),
      pass: Color(0xFF6B625E),
      spark: Color(0xFF8A5F0E),
      verified: Color(0xFF2F6FD6),
      subtleText: Color(0xFF6A5F59),
      photoScrim: Color(0xE6120C0A),
      onPhoto: Color(0xFFFFFFFF),
      glowA: Color(0x29E07A55),
      glowB: Color(0x1F2E6A57),
    ),
  );

  static final ThemeData darkTheme = _buildTheme(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFA8432A),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFF2A68E),
      onPrimary: const Color(0xFF4F1606),
      primaryContainer: const Color(0xFF6E2A17),
      onPrimaryContainer: const Color(0xFFFFDBCF),
      secondary: const Color(0xFF8FD3B6),
      onSecondary: const Color(0xFF00382A),
      secondaryContainer: const Color(0xFF1F4F40),
      onSecondaryContainer: const Color(0xFFC9F0DF),
      tertiary: const Color(0xFFE9C26E),
      onTertiary: const Color(0xFF3F2C00),
      tertiaryContainer: const Color(0xFF5C4300),
      onTertiaryContainer: const Color(0xFFFFE3A8),
      surface: const Color(0xFF15110F),
      onSurface: const Color(0xFFF3EBE6),
    ),
    appColors: const AppColorsExtension(
      like: Color(0xFF8FD3B6),
      pass: Color(0xFFC9BDB7),
      spark: Color(0xFFE9C26E),
      verified: Color(0xFF8DB4FF),
      subtleText: Color(0xFFB8ABA4),
      photoScrim: Color(0xE6120C0A),
      onPhoto: Color(0xFFFFFFFF),
      glowA: Color(0x2EF2A68E),
      glowB: Color(0x1F8FD3B6),
    ),
  );

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required AppColorsExtension appColors,
  }) {
    final textTheme = _buildTextTheme(colorScheme);
    final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill));
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarThemeData(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: colorScheme.brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusCard)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: spacingLg),
          shape: pill,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: spacingLg),
          shape: pill,
          side: BorderSide(color: colorScheme.outline),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: pill, textStyle: textTheme.labelLarge),
      ),
      chipTheme: ChipThemeData(
        shape: pill,
        labelStyle: textTheme.labelLarge,
        side: BorderSide(color: colorScheme.outlineVariant),
        selectedColor: colorScheme.primaryContainer,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colorScheme.primary, width: borderThick),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingMd),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.primaryContainer,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusSheet)),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSheet)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
      ),
      extensions: [appColors],
    );
  }

  /// Sora (geometric) gives headlines a modern voice; DM Sans keeps body text calm and legible.
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    final base = GoogleFonts.dmSansTextTheme(
      ThemeData(colorScheme: colorScheme, useMaterial3: true).textTheme,
    );
    TextStyle geo(TextStyle? style, FontWeight weight) =>
        GoogleFonts.sora(textStyle: style, fontWeight: weight, letterSpacing: -0.4);
    return base.copyWith(
      displayLarge: geo(base.displayLarge, FontWeight.w700),
      displayMedium: geo(base.displayMedium, FontWeight.w700),
      displaySmall: geo(base.displaySmall, FontWeight.w700),
      headlineLarge: geo(base.headlineLarge, FontWeight.w700),
      headlineMedium: geo(base.headlineMedium, FontWeight.w700),
      headlineSmall: geo(base.headlineSmall, FontWeight.w600),
      titleLarge: geo(base.titleLarge, FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
