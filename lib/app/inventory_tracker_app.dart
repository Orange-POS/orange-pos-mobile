import 'package:flutter/material.dart';

import '../screens/splash_screen.dart';

class InventoryTrackerApp extends StatelessWidget {
  const InventoryTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const black = Colors.black;

    return MaterialApp(
      title: 'Inventory Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: black, primary: black),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: black,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: black,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: black,
          ),
          titleMedium: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: black,
          ),
          bodyLarge: TextStyle(fontSize: 17, color: black),
          bodyMedium: TextStyle(fontSize: 15, color: black),
          labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: black,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.black38,
            disabledForegroundColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            foregroundColor: black,
            side: const BorderSide(color: black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black26),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: black, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          labelStyle: const TextStyle(fontSize: 15),
          hintStyle: const TextStyle(color: Colors.black45),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: black,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
