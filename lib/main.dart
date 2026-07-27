import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_nav_screen.dart';

void main() {
  runApp(const GarageApp());
}

class GarageApp extends StatelessWidget {
  const GarageApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garage Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E2C),
        primaryColor: const Color(0xFF3B82F6),
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF2A2D3E),
        ),
      ),
      home: const HomeNavScreen(),
    );
  }
}
