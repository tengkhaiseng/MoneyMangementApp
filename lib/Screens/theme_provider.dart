import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// --- COLOR CONSTANTS --- ///

// Professional Blue-Green Theme (Light)
const Color kPrimaryBlue = Color(0xFF1565C0); // Deep blue
const Color kSuccessGreen = Color(0xFF2E7D32); // Success
const Color kExpenseRed = Color(0xFFD32F2F); // Expense/negative
const Color kAccentCyan = Color(0xFF00BCD4); // Cyan accent
const Color kBackgroundLight = Color(0xFFF8FAFB); // Light gray-blue
const Color kCardLight = Color(0xFFFFFFFF); // Pure white
const Color kTextPrimaryLight = Color(0xFF212121); // Dark gray
const Color kTextSecondaryLight = Color(0xFF757575); // Medium gray
const Color kDividerLight = Color(0xFFE0E0E0); // Light gray

// Login/Register Pages Theme
const Color kLoginBackground = Color(0xFFFAFAFA); // Very light gray
const Color kInputBorder = Color(0xFFE1E5E9);
const Color kInputFocus = Color(0xFF1976D2);
const Color kPrimaryButton = Color(0xFF1976D2);
const Color kPrimaryButtonHover = Color(0xFF1565C0);
const Color kSecondaryButton = Color(0xFFF5F5F5);
const Color kErrorColor = Color(0xFFF44336);
const Color kSuccessColor = Color(0xFF4CAF50);
const Color kLinkColor = Color(0xFF1976D2);

// Dark Theme
const Color kDarkBackground = Color(0xFF121212);
const Color kDarkCard = Color(0xFF1E1E1E);
const Color kDarkPrimary = Color(0xFF00E676);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFB0B0B0);
const Color kLoginDarkBackground = Color(0xFF0F0F0F);
const Color kLoginDarkForm = Color(0xFF1C1C1C);
const Color kLoginDarkInput = Color(0xFF2C2C2C);

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDark);
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  ThemeData get themeData => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: kBackgroundLight,
        primaryColor: kPrimaryBlue,
        cardColor: kCardLight,
        dividerColor: kDividerLight,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: kPrimaryBlue,
          onPrimary: Colors.white,
          secondary: kAccentCyan,
          onSecondary: Colors.white,
          error: kErrorColor,
          onError: Colors.white,
          background: kBackgroundLight,
          onBackground: kTextPrimaryLight,
          surface: kCardLight,
          onSurface: kTextPrimaryLight,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(color: kTextPrimaryLight, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: kTextPrimaryLight, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: kTextPrimaryLight),
          bodyMedium: TextStyle(color: kTextSecondaryLight),
          bodySmall: TextStyle(color: kTextSecondaryLight),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kCardLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: kInputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: kInputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: kInputFocus, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: kErrorColor),
          ),
          labelStyle: const TextStyle(color: kTextSecondaryLight),
          hintStyle: const TextStyle(color: kTextSecondaryLight),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (states) => states.contains(MaterialState.hovered)
                  ? kPrimaryButtonHover
                  : kPrimaryButton,
            ),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(kSecondaryButton),
            foregroundColor: MaterialStateProperty.all<Color>(kPrimaryBlue),
            side: MaterialStateProperty.all<BorderSide>(
              const BorderSide(color: kPrimaryBlue),
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: kPrimaryBlue,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: kPrimaryBlue),
        dividerTheme: const DividerThemeData(color: kDividerLight),
      );

  ThemeData get darkThemeData => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kDarkBackground,
        primaryColor: kDarkPrimary,
        cardColor: kDarkCard,
        dividerColor: Colors.grey[800],
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: kDarkPrimary,
          onPrimary: Colors.black,
          secondary: kAccentCyan,
          onSecondary: Colors.black,
          error: kErrorColor,
          onError: Colors.white,
          background: kDarkBackground,
          onBackground: kDarkTextPrimary,
          surface: kDarkCard,
          onSurface: kDarkTextPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kDarkCard,
          foregroundColor: kDarkTextPrimary,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(color: kDarkTextPrimary, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: kDarkTextPrimary, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: kDarkTextPrimary),
          bodyMedium: TextStyle(color: kDarkTextSecondary),
          bodySmall: TextStyle(color: kDarkTextSecondary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kLoginDarkInput,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: kDarkPrimary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: kErrorColor),
          ),
          labelStyle: const TextStyle(color: kDarkTextSecondary),
          hintStyle: const TextStyle(color: kDarkTextSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(kDarkPrimary),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(kDarkCard),
            foregroundColor: MaterialStateProperty.all<Color>(kDarkPrimary),
            side: MaterialStateProperty.all<BorderSide>(
              BorderSide(color: kDarkPrimary),
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: kDarkPrimary,
          contentTextStyle: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: kDarkPrimary),
        dividerTheme: DividerThemeData(color: Colors.grey[800]),
      );
}