import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// --- COLOR CONSTANTS --- ///

// Green Pastel Theme (Light)
const Color kPrimaryGreen = Color(0xFF219150); // Deep green
const Color kAccentGreen = Color(0xFF43e97b); // Vivid green
const Color kPastelGreen1 = Color(0xFFe8f5e9); // Light mint
const Color kPastelGreen2 = Color(0xFFb2f7cc); // Pastel green
const Color kPastelGreen3 = Color(0xFFd0f8ce); // Lighter green
const Color kCardLight = Color(0xFFFFFFFF); // Pure white
const Color kTextPrimaryLight = Color(0xFF212121); // Dark gray
const Color kTextSecondaryLight = Color(0xFF757575); // Medium gray
const Color kDividerLight = Color(0xFFE0E0E0); // Light gray
const Color kErrorColor = Color(0xFFF44336);
const Color kSuccessColor = Color(0xFF4CAF50);

// Dark Theme
const Color kDarkBackground = Color(0xFF121212);
const Color kDarkCard = Color(0xFF1E1E1E);
const Color kDarkPrimary = Color(0xFF00E676);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFB0B0B0);

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
        scaffoldBackgroundColor: kPastelGreen1,
        primaryColor: kPrimaryGreen,
        cardColor: kCardLight,
        dividerColor: kDividerLight,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: kPrimaryGreen,
          onPrimary: Colors.white,
          secondary: kAccentGreen,
          onSecondary: Colors.white,
          error: kErrorColor,
          onError: Colors.white,
          background: kPastelGreen1,
          onBackground: kTextPrimaryLight,
          surface: kCardLight,
          onSurface: kTextPrimaryLight,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryGreen,
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
            borderSide: BorderSide(color: kDividerLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: kDividerLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: kPrimaryGreen, width: 2),
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
            backgroundColor: MaterialStateProperty.all<Color>(kPrimaryGreen),
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
            backgroundColor: MaterialStateProperty.all<Color>(kCardLight),
            foregroundColor: MaterialStateProperty.all<Color>(kPrimaryGreen),
            side: MaterialStateProperty.all<BorderSide>(
              const BorderSide(color: kPrimaryGreen),
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
          backgroundColor: kPrimaryGreen,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: kPrimaryGreen),
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
          secondary: kAccentGreen,
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
          fillColor: kDarkCard,
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