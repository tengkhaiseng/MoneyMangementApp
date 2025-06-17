import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Screens/theme_provider.dart';
import 'Screens/login_page.dart'; // Change to your actual home page if needed

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money Manager',
      theme: themeProvider.themeData,
      darkTheme: themeProvider.darkThemeData,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: LoginPage(), // Change to your actual home page if needed
    );
  }
}