import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Brand colors
  static const Color primary = Color(0xFF75639E);
  static const Color primaryDark = Color(0xFF554576);
  static const Color primaryLight = Color(0xFFE9E1F5);

  static const Color secondary = Color(0xFF78A892);
  static const Color secondaryLight = Color(0xFFDDEEE6);

  static const Color accent = Color(0xFFE5A07F);
  static const Color accentLight = Color(0xFFF8E3D8);

  // Status colors
  static const Color success = Color(0xFF6E9F83);
  static const Color warning = Color(0xFFD9A55B);
  static const Color error = Color(0xFFC96B70);

  // Light theme
  static const Color lightBackground = Color(0xFFFAF8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF342E3D);
  static const Color lightTextSecondary = Color(0xFF756F7C);
  static const Color lightBorder = Color(0xFFE9E2ED);

  // Dark theme
  static const Color darkBackground = Color(0xFF201C25);
  static const Color darkSurface = Color(0xFF2C2632);
  static const Color darkTextPrimary = Color(0xFFF8F3FA);
  static const Color darkTextSecondary = Color(0xFFCBC1CF);
  static const Color darkBorder = Color(0xFF443A4B);
}

class AppTextStyles {
  AppTextStyles._();

  static TextTheme createTextTheme({
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 1.2,
        color: primaryTextColor,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.25,
        color: primaryTextColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: primaryTextColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: primaryTextColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: primaryTextColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: primaryTextColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: primaryTextColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: primaryTextColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: secondaryTextColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: secondaryTextColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: primaryTextColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: secondaryTextColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: secondaryTextColor,
      ),
    );
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,

      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryLight,
      onSecondaryContainer: Color(0xFF385C4D),

      tertiary: AppColors.accent,
      onTertiary: Color(0xFF4D2B1D),
      tertiaryContainer: AppColors.accentLight,
      onTertiaryContainer: Color(0xFF6B3E2A),

      error: AppColors.error,
      onError: Colors.white,

      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,

      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorder,
    );
    return _buildTheme(
      colorScheme: colorScheme,
      backgroundColor: AppColors.lightBackground,
      textTheme: AppTextStyles.createTextTheme(
        primaryTextColor: AppColors.lightTextPrimary,
        secondaryTextColor: AppColors.lightTextSecondary,
      ),
    );
  }

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFFC4B2E2),
      onPrimary: Color(0xFF302343),
      primaryContainer: Color(0xFF4D3E65),
      onPrimaryContainer: Color(0xFFE9E1F5),

      secondary: Color(0xFFA8D5C1),
      onSecondary: Color(0xFF213C31),
      secondaryContainer: Color(0xFF36594A),
      onSecondaryContainer: Color(0xFFDDEEE6),

      tertiary: Color(0xFFF2BEA5),
      onTertiary: Color(0xFF512D20),
      tertiaryContainer: Color(0xFF684537),
      onTertiaryContainer: Color(0xFFF8E3D8),

      error: Color(0xFFF0A0A4),
      onError: Color(0xFF58191E),

      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,

      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorder,
    );
    return _buildTheme(
      colorScheme: colorScheme,
      backgroundColor: AppColors.darkBackground,
      textTheme: AppTextStyles.createTextTheme(
        primaryTextColor: AppColors.darkTextPrimary,
        secondaryTextColor: AppColors.darkTextSecondary,
      ),
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color backgroundColor,
    required TextTheme textTheme,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: backgroundColor,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        hintStyle: textTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(120, 52),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(120, 52),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.primaryContainer,
        selectedColor: colorScheme.primary,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onPrimaryContainer,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.onSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.surface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
      ),
    );
  }
}