import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Primary palette - Rich Indigo
  static const primary = Color(0xFF5B5BD6);
  static const primaryLight = Color(0xFF8B8BF5);
  static const primaryDark = Color(0xFF3E3E9E);
  static const primaryContainer = Color(0xFFE8E8FF);
  static const onPrimaryContainer = Color(0xFF1A1A5E);

  // Secondary palette - Warm Coral
  static const secondary = Color(0xFFFF6B6B);
  static const secondaryLight = Color(0xFFFF9B9B);
  static const secondaryDark = Color(0xFFCC4545);
  static const secondaryContainer = Color(0xFFFFE8E8);

  // Accent - Golden Yellow
  static const accent = Color(0xFFFFBE0B);
  static const accentLight = Color(0xFFFFD54F);
  static const accentDark = Color(0xFFE6A800);

  // Success - Emerald Green
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFFD1FAE5);
  static const successDark = Color(0xFF059669);

  // Warning - Amber
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const warningDark = Color(0xFFD97706);

  // Error - Rose Red
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEE2E2);
  static const errorDark = Color(0xFFDC2626);

  // Neutral palette
  static const neutral50 = Color(0xFFFAFAFA);
  static const neutral100 = Color(0xFFF5F5F5);
  static const neutral200 = Color(0xFFE5E5E5);
  static const neutral300 = Color(0xFFD4D4D4);
  static const neutral400 = Color(0xFFA3A3A3);
  static const neutral500 = Color(0xFF737373);
  static const neutral600 = Color(0xFF525252);
  static const neutral700 = Color(0xFF404040);
  static const neutral800 = Color(0xFF262626);
  static const neutral900 = Color(0xFF171717);

  // Background colors
  static const backgroundLight = Color(0xFFF8FAFC);
  static const surfaceLight = Colors.white;
  static const backgroundDark = Color(0xFF0F172A);
  static const surfaceDark = Color(0xFF1E293B);

  // Gradient colors
  static const gradientStart = Color(0xFF667EEA);
  static const gradientEnd = Color(0xFF764BA2);
  
  // Special colors for cards
  static const cardBlue = Color(0xFFEEF2FF);
  static const cardGreen = Color(0xFFECFDF5);
  static const cardOrange = Color(0xFFFFF7ED);
  static const cardPurple = Color(0xFFFAF5FF);
  static const cardPink = Color(0xFFFDF2F8);
  static const cardCyan = Color(0xFFECFEFF);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.secondaryDark,
        tertiary: AppColors.accent,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorLight,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.neutral900,
        surfaceContainerHighest: AppColors.neutral100,
        outline: AppColors.neutral300,
        outlineVariant: AppColors.neutral200,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: const TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral900,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.neutral700,
          size: 24,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.neutral200.withOpacity(0.5)),
        ),
        color: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: const TextStyle(
          color: AppColors.neutral500,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: AppColors.neutral400,
          fontWeight: FontWeight.w400,
        ),
        prefixIconColor: AppColors.neutral400,
        suffixIconColor: AppColors.neutral400,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.neutral200,
          disabledForegroundColor: AppColors.neutral400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.neutral200,
          disabledForegroundColor: AppColors.neutral400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 4,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 70,
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              size: 24,
              color: AppColors.primary,
            );
          }
          return const IconThemeData(
            size: 24,
            color: AppColors.neutral400,
          );
        }),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral900,
          letterSpacing: -0.3,
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.neutral800,
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral100,
        selectedColor: AppColors.primaryContainer,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.neutral700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      // Dropdown Menu Theme
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.neutral50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.neutral200),
          ),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral200,
        thickness: 1,
        space: 1,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        tileColor: Colors.transparent,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.neutral200,
        circularTrackColor: AppColors.neutral200,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
          color: AppColors.neutral900,
        ),
        displayMedium: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
          color: AppColors.neutral900,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: AppColors.neutral900,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: AppColors.neutral900,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: AppColors.neutral900,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          color: AppColors.neutral900,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: AppColors.neutral900,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: AppColors.neutral900,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: AppColors.neutral900,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          color: AppColors.neutral700,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          color: AppColors.neutral700,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3,
          color: AppColors.neutral500,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.neutral700,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.neutral600,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.neutral500,
        ),
      ),
    );
  }
}

// Extension for easy access to custom colors
extension ThemeExtensions on BuildContext {
  AppColors get colors => AppColors();
  
  Color get primaryColor => AppColors.primary;
  Color get successColor => AppColors.success;
  Color get warningColor => AppColors.warning;
  Color get errorColor => AppColors.error;
}

// Custom decoration helpers
class AppDecorations {
  static BoxDecoration get gradientBackground => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.gradientStart, AppColors.gradientEnd],
    ),
  );

  static BoxDecoration cardDecoration({Color? color, double radius = 16}) => BoxDecoration(
    color: color ?? AppColors.surfaceLight,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: AppColors.neutral900.withOpacity(0.04),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration elevatedCardDecoration({double radius = 16}) => BoxDecoration(
    color: AppColors.surfaceLight,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: AppColors.neutral900.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration softGlow({required Color color, double radius = 16}) => BoxDecoration(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: color.withOpacity(0.2)),
  );
}

// Spacing constants
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}