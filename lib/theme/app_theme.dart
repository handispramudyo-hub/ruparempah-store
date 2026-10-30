import 'package:flutter/material.dart';

class AppColors {
  static const sageGreen = Color(0xFF8FAF8B);
  static const darkGreen = Color(0xFF355B3B);
  static const deepGreen = Color(0xFF24402A);
  static const olive = Color(0xFF667C45);
  static const cream = Color(0xFFF7F5EC);
  static const white = Color(0xFFFFFFFF);
  static const charcoal = Color(0xFF252A24);
  static const softGold = Color(0xFFD4AF37);
  static const terracotta = Color(0xFFB85C38);
  static const muted = Color(0xFF7A6A5A);
  static const line = Color(0xFFE2DDCF);
}

class AppGradients {
  static const primary = LinearGradient(
    colors: [AppColors.darkGreen, AppColors.deepGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const green = LinearGradient(
    colors: [Color(0xFF8FAF8B), Color(0xFF355B3B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gold = LinearGradient(
    colors: [Color(0xFFE6C567), Color(0xFFD4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const terracotta = LinearGradient(
    colors: [Color(0xFFD9805A), Color(0xFFB85C38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static const heading = 'Montserrat';
  static const body = 'NunitoSans';

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.sageGreen,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.darkGreen,
      onPrimary: AppColors.white,
      secondary: AppColors.olive,
      onSecondary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.charcoal,
      surfaceContainerHighest: AppColors.cream,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: body,
    );

    return base.copyWith(
      textTheme: base.textTheme
          .apply(
            fontFamily: body,
            bodyColor: AppColors.charcoal,
            displayColor: AppColors.charcoal,
          )
          .copyWith(
            headlineSmall: const TextStyle(
              fontFamily: heading,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
            titleLarge: const TextStyle(
              fontFamily: heading,
              fontWeight: FontWeight.w700,
              fontSize: 19,
              color: AppColors.charcoal,
            ),
            titleMedium: const TextStyle(
              fontFamily: heading,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: heading,
          color: AppColors.charcoal,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: const TextStyle(color: Color(0xFFAAA395)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkGreen, width: 1.6),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkGreen,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          textStyle: const TextStyle(
            fontFamily: heading,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkGreen,
          side: const BorderSide(color: AppColors.darkGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.darkGreen),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.sageGreen.withValues(alpha: 0.28),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: heading,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGreen,
            );
          }
          return const TextStyle(
            fontFamily: body,
            fontSize: 12,
            color: AppColors.charcoal,
          );
        }),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.charcoal,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    );
  }
}
