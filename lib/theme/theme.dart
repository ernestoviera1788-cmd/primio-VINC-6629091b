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

  static const Color gradientStart = Color(0xFFA855F7);
  static const Color gradientEnd = Color(0xFFEC4899);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Noir: premium dark theme (always on).
  static final ThemeData darkTheme = _buildTheme(
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFEC4899),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF4A1E3D),
      onPrimaryContainer: Color(0xFFF8C9E2),
      secondary: Color(0xFFA855F7),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFF35205C),
      onSecondaryContainer: Color(0xFFDDC2FF),
      tertiary: Color(0xFFFBBF24),
      onTertiary: Color(0xFF221100),
      tertiaryContainer: Color(0xFF4A3200),
      onTertiaryContainer: Color(0xFFFFE3A8),
      error: Color(0xFFFF8A80),
      onError: Color(0xFF2A0A0A),
      errorContainer: Color(0xFF5C1A1A),
      onErrorContainer: Color(0xFFFFDAD4),
      surface: Color(0xFF14121E),
      onSurface: Color(0xFFF2EFFA),
      surfaceDim: Color(0xFF0E0C16),
      surfaceBright: Color(0xFF353252),
      surfaceContainerLowest: Color(0xFF0E0C16),
      surfaceContainerLow: Color(0xFF221F33),
      surfaceContainer: Color(0xFF2C2942),
      surfaceContainerHigh: Color(0xFF353252),
      surfaceContainerHighest: Color(0xFF3F3B60),
      onSurfaceVariant: Color(0xFFA7A3C0),
      outline: Color(0xFF4A4662),
      outlineVariant: Color(0xFF2E2B45),
      shadow: Color(0xFF000000),
      scrim: Color(0x99000000),
      inverseSurface: Color(0xFFF2EFFA),
      onInverseSurface: Color(0xFF14121E),
      inversePrimary: Color(0xFFA855F7),
      surfaceTint: Color(0xFFEC4899),
    ),
    appColors: const AppColorsExtension(
      like: Color(0xFF34D399),
      pass: Color(0xFF8E8A9E),
      spark: Color(0xFFFBBF24),
      verified: Color(0xFF60A5FA),
      subtleText: Color(0xFFA7A3C0),
      photoScrim: Color(0xE60B0912),
      onPhoto: Color(0xFFFFFFFF),
      glowA: Color(0x14A855F7),
      glowB: Color(0x0FEC4899),
    ),
  );

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required AppColorsExtension appColors,
  }) {
    final textTheme = _buildTextTheme(colorScheme);
    final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill));
    final isDark = colorScheme.brightness == Brightness.dark;
    final navSelected = isDark ? const Color(0xFFEC4899) : colorScheme.primary;
    final navUnselected = isDark ? const Color(0xFFA7A3C0) : colorScheme.onSurfaceVariant;
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
        backgroundColor: isDark ? const Color(0xFF1B1928) : colorScheme.surfaceContainerLow,
        indicatorColor: isDark ? Colors.transparent : colorScheme.primaryContainer,
        elevation: isDark ? 8 : 0,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? navSelected : navUnselected, size: selected ? 26 : 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? navSelected : navUnselected,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      badgeTheme: const BadgeThemeData(
        backgroundColor: Color(0xFFEC4899),
        textColor: Colors.white,
        smallSize: 8,
        largeSize: 18,
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
