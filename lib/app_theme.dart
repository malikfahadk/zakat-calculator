import 'package:flutter/material.dart';

class AppColors {
  static const emerald = Color(0xFF123C3C);
  static const emeraldBright = Color(0xFF105F50);
  static const ivory = Color(0xFFF8F7F1);
  static const gold = Color(0xFFB08A3E);
  static const text = Color(0xFF173333);
  static const border = Color(0xFFD2D9D4);
  static const surface = Colors.white;
  static const error = Color(0xFFB3261E);
  static const helper = Color(0xFF647572);
}

class AppSpace {
  static const gap = 16.0;
  static const smallGap = 8.0;
  static const radius = 14.0;
  static const maxWidth = 760.0;
}

class AppIcons {
  static const nisab = Icons.balance_outlined;
  static const assets = Icons.account_balance_wallet_outlined;
  static const review = Icons.fact_check_outlined;
  static const date = Icons.event_outlined;
  static const source = Icons.link_outlined;
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.emerald,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.ivory,
  );

  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.emeraldBright,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
      fontFamily: 'sans',
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.emerald,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpace.radius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpace.radius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpace.radius),
        borderSide: const BorderSide(color: AppColors.emeraldBright, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpace.radius),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.emeraldBright,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpace.radius),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.emerald,
        side: const BorderSide(color: AppColors.emeraldBright),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpace.radius),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpace.radius),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
  );
}
