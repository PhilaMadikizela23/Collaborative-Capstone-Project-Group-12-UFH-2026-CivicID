import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // CIVICID BRAND COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color secondaryColor = Color(0xFF2E8B57);

  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF8FBF9);
  static const Color lightGreen = Color(0xFFEAF7EF);

  static const Color darkText = Color(0xFF14251C);
  static const Color greyText = Color(0xFF52635B);
  static const Color borderColor = Color(0xFFDDE7E1);

  // ============================================================
  // STANDARD CIVICID TEXT SIZES
  // ============================================================

  static const TextTheme civicTextTheme = TextTheme(
    // Large page headings
    displaySmall: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w900,
      color: darkText,
      height: 1.2,
    ),

    headlineLarge: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w900,
      color: darkText,
      height: 1.25,
    ),

    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w900,
      color: darkText,
      height: 1.3,
    ),

    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: darkText,
      height: 1.3,
    ),

    // Section / card headings
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: darkText,
      height: 1.3,
    ),

    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: darkText,
      height: 1.35,
    ),

    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: darkText,
      height: 1.35,
    ),

    // Normal readable text
    bodyLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: darkText,
      height: 1.5,
    ),

    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: darkText,
      height: 1.5,
    ),

    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: greyText,
      height: 1.45,
    ),

    // Buttons, navigation and badges
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: darkText,
      height: 1.3,
    ),

    labelMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: darkText,
      height: 1.3,
    ),

    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: greyText,
      height: 1.3,
    ),
  );

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
        onSurface: darkText,
        brightness: Brightness.light,
      ),

      scaffoldBackgroundColor: surfaceColor,

      textTheme: civicTextTheme,

      // ========================================================
      // APP BAR
      // ========================================================

      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
        foregroundColor: primaryColor,
        toolbarHeight: 68,

        iconTheme: IconThemeData(
          color: primaryColor,
          size: 25,
        ),

        actionsIconTheme: IconThemeData(
          color: primaryColor,
          size: 25,
        ),

        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 20,
          color: darkGreen,
        ),
      ),

      // ========================================================
      // CARDS
      // ========================================================

      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        margin: EdgeInsets.zero,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
      ),

      // ========================================================
      // TEXT FIELDS
      // ========================================================

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,

        hintStyle: const TextStyle(
          color: Color(0xFF7A8780),
          fontSize: 14,
        ),

        labelStyle: const TextStyle(
          color: greyText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),

        floatingLabelStyle: const TextStyle(
          color: primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),

        helperStyle: const TextStyle(
          color: greyText,
          fontSize: 12,
        ),

        errorStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),

        prefixIconColor: primaryColor,
        suffixIconColor: primaryColor,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
      ),

      // ========================================================
      // FILLED BUTTONS
      // ========================================================

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,

          minimumSize: const Size(48, 48),

          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 24,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),

      // ========================================================
      // ELEVATED BUTTONS
      // ========================================================

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,

          elevation: 0,

          minimumSize: const Size(48, 48),

          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 24,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),

      // ========================================================
      // OUTLINED BUTTONS
      // ========================================================

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkGreen,

          minimumSize: const Size(48, 48),

          side: const BorderSide(
            color: primaryColor,
          ),

          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 22,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),

      // ========================================================
      // TEXT BUTTONS
      // ========================================================

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),

      // ========================================================
      // ICON BUTTONS
      // ========================================================

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: primaryColor,
          iconSize: 24,
        ),
      ),

      // ========================================================
      // LIST TILES
      // ========================================================

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        iconColor: primaryColor,
        textColor: darkText,
        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        subtitleTextStyle: TextStyle(
          color: greyText,
          fontSize: 13,
          height: 1.4,
        ),
      ),

      // ========================================================
      // NAVIGATION BAR
      // ========================================================

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: lightGreen,
        elevation: 0,
        height: 82,

        iconTheme: WidgetStateProperty.resolveWith(
              (states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: primaryColor,
                size: 25,
              );
            }

            return const IconThemeData(
              color: greyText,
              size: 23,
            );
          },
        ),

        labelTextStyle: WidgetStateProperty.resolveWith(
              (states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: darkGreen,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              );
            }

            return const TextStyle(
              color: greyText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            );
          },
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION BAR
      // ========================================================

      bottomNavigationBarTheme:
      const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: greyText,
        selectedLabelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        selectedIconTheme: IconThemeData(
          size: 25,
        ),
        unselectedIconTheme: IconThemeData(
          size: 23,
        ),
        type: BottomNavigationBarType.fixed,
      ),

      // ========================================================
      // TABS
      // ========================================================

      tabBarTheme: const TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: greyText,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        indicatorColor: primaryColor,
      ),

      // ========================================================
      // CHIPS
      // ========================================================

      chipTheme: ChipThemeData(
        backgroundColor: lightGreen,
        selectedColor: primaryColor,
        side: const BorderSide(
          color: borderColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: const TextStyle(
          color: darkGreen,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
      ),

      // ========================================================
      // FLOATING ACTION BUTTON
      // ========================================================

      floatingActionButtonTheme:
      const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      // ========================================================
      // PROGRESS INDICATORS
      // ========================================================

      progressIndicatorTheme:
      const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: lightGreen,
      ),

      // ========================================================
      // CHECKBOX
      // ========================================================

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
              (states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }

            return Colors.transparent;
          },
        ),
      ),

      // ========================================================
      // RADIO
      // ========================================================

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
              (states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }

            return greyText;
          },
        ),
      ),

      // ========================================================
      // SWITCHES
      // ========================================================

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
              (states) => Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
              (states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }

            return const Color(0xFFD4D8D6);
          },
        ),
      ),

      // ========================================================
      // DIVIDERS
      // ========================================================

      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
      ),

      // ========================================================
      // SNACKBAR
      // ========================================================

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: darkGreen,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ========================================================
      // DIALOG
      // ========================================================

      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,

        titleTextStyle: const TextStyle(
          color: darkGreen,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),

        contentTextStyle: const TextStyle(
          color: darkText,
          fontSize: 14,
          height: 1.5,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // ========================================================
      // DATE PICKER / TIME PICKER
      // ========================================================

      datePickerTheme: const DatePickerThemeData(
        headerHeadlineStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
        headerHelpStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),

      // ========================================================
      // TOOLTIP
      // ========================================================

      tooltipTheme: TooltipThemeData(
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        decoration: BoxDecoration(
          color: darkGreen,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ============================================================
  // DARK THEME
  // ============================================================

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        brightness: Brightness.dark,
      ),

      textTheme: civicTextTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),

      scaffoldBackgroundColor:
      const Color(0xFF101713),

      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFF101713),
        foregroundColor: Colors.white,
        toolbarHeight: 68,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF18231D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF18231D),

        hintStyle: const TextStyle(
          color: Color(0xFFB2B9B5),
          fontSize: 14,
        ),

        labelStyle: const TextStyle(
          color: Color(0xFFD1D7D3),
          fontSize: 14,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
        ),
      ),

      navigationBarTheme:
      const NavigationBarThemeData(
        backgroundColor: Color(0xFF18231D),
        indicatorColor: Color(0xFF244D31),
        height: 82,
      ),

      floatingActionButtonTheme:
      const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );

    return base.copyWith(
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      elevatedButtonTheme:
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      outlinedButtonTheme:
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF72D49A),
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
