// This file defines the global theme for the Financial Buddy app, including colors and styles.
// Design by Natasha Urbanowicz :: Design Implemented by Emily Catt

import 'package:flutter/material.dart';

// COLOR SYSTEM (Design Tokens)

// These match our design document.
// We store them here so we NEVER hardcode colors in pages.
class AppColors {
  static const Color primaryPink = Color(0xFFFF2E88); // main brand color
  static const Color accentBlue = Color(0xFF00CFFF); // secondary accent
  static const Color highlightAqua = Color(0xFF00FFFF); // highlight color
  static const Color secondaryPurple = Color(0xFF5D3FD3); // supporting color
  static const Color neonGreen = Color(0xFF39FF14); // CTA / success
  static const Color backgroundBlack = Color(0xFF000000); // app background
  static const Color accentBackgroundB = Color(0xFF1A1A1A); // alternate background for contrast
  static const Color textWhite = Color(0xFFFFFFFF); // main text

  // Extra helper colors for dark UI surfaces
  static const Color darkSurface = Color(0xFF111111); // cards, drawers
  static const Color darkCard = Color(0xFF1A1A1A); // slightly lighter surface
  static const Color mutedText = Color(0xFFBDBDBD); // less important text
  static const Color danger = Color(0xFFFF5252); // delete / error
}

// GLOBAL APP THEME
// This is applied in main.dart and controls the ENTIRE app.
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      // Use modern Material 3 styling
      useMaterial3: true,

      // Tell Flutter we are building a dark-themed app
      brightness: Brightness.dark,

      // Default background for ALL screens (Scaffold)
      scaffoldBackgroundColor: AppColors.backgroundBlack,

      // COLOR SCHEME (core system)
      // This feeds colors into many Flutter widgets automatically rather than Flutter using defaults.
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryPink, // main buttons, FAB, highlights
        secondary: AppColors.accentBlue, // secondary accents
        tertiary: AppColors.highlightAqua, // extra highlight usage
        surface: AppColors.darkSurface, // cards, dialogs, surfaces

        onPrimary: AppColors.textWhite, // text on primary color
        onSecondary: AppColors.textWhite,
        onTertiary: AppColors.backgroundBlack,
        onSurface: AppColors.textWhite,
      ),

      // APP BAR (top bar)
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundBlack,
        foregroundColor: AppColors.textWhite,
        centerTitle: true,
        elevation: 0,
      ),

      // DRAWER (side menu)
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.darkSurface,
      ),

      // CARDS (your transactions)
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),

      // FLOATING ACTION BUTTON
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryPink,
        foregroundColor: AppColors.textWhite,
      ),
      
      // PRIMARY BUTTONS
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPink,
          foregroundColor: AppColors.textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // TEXT BUTTONS (Edit/Delete)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryPink,
        ),
      ),

      // INPUT FIELDS (forms)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,

        labelStyle: const TextStyle(color: AppColors.textWhite),
        hintStyle: const TextStyle(color: AppColors.mutedText),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.secondaryPurple,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.accentBlue,
            width: 2,
          ),
        ),
      ),

      // DIALOGS (popups)
        dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // DIVIDERS
      dividerTheme: const DividerThemeData(
        color: AppColors.mutedText,
        thickness: 1,
      ),

      // ICON DEFAULT COLOR
      iconTheme: const IconThemeData(
        color: AppColors.textWhite,
      ),


      // TEXT STYLES
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.textWhite,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textWhite,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.mutedText,
          fontSize: 14,
        ),
        labelLarge: TextStyle(
          color: AppColors.textWhite,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// GRADIENT SYSTEM FOR BUBBLE BOXES AND BUTTONS
// These define reusable gradient styles for buttons, cards, etc.
// This prevents us from hardcoding gradients all over the app.
class AppGradients {
  // Main neon gradient (used for buttons / highlights)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      AppColors.accentBlue,
      AppColors.primaryPink,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card background gradient (subtle dark variation)
  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      AppColors.darkSurface,
      AppColors.accentBackgroundB,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // a second neon gradient for variety (used for special highlights)
  static const LinearGradient neonGradient = LinearGradient(
    colors: [
      AppColors.highlightAqua,
      AppColors.primaryPink,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

