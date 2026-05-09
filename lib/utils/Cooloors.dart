import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Global Theme Notifier for easy toggling anywhere in the app
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

// Reusable Theme Toggle Widget
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        final isDark = mode == ThemeMode.dark;
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2B2B36) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(2, 2)),
            ],
          ),
          child: IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.yellow : Colors.black,
              size: 20,
            ),
            onPressed: () {
              themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        );
      },
    );
  }
}

class Cooloors {
  // ── Original Legacy Colors (kept for compatibility) ───────────────
  static const Color background = Color(0xFF0A0E21);
  static const Color surface = Color(0xFF1A1F36);
  static const Color surfaceLight = Color(0xFF252B48);
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primaryGradientEnd = Color(0xFFA855F7);
  static const Color secondary = Color(0xFF00D9FF);
  static const Color danger = Color(0xFFF43F5E);
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF475569);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> glowShadow = [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static const double radiusLg = 16.0;
  static const double radiusMd = 12.0;
  static const double radiusSm = 8.0;

  // Non-static legacy properties instantiated in the app
  Color lightAppBarColor = background;
  Color darkAppBarColor = background;

  Color lightBackgroundColor = background;
  Color darkBackgroundColor = background;

  Color lightTileColor = const Color(0xfff3d2c1);
  Color darkTileColor = surface;
  Color inactiveColor = textMuted;

  Color buttonColor = primary;

  Color lightTextColor = textPrimary;
  Color darkTextColor = textPrimary;
  Color darkSubTextColor = textSecondary;

  Color darkParaColor = textSecondary;

  // ── Neo-Brutalist Light Theme ─────────────────────────────────────
  static final ThemeData neoLightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF4F4F0), // Light beige
    textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFA594F9),
      secondary: Color(0xFFFFB4A2),
      surface: Colors.white,
      error: Color(0xFFFF4D4D),
      onPrimary: Colors.black,
      onSurface: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF4F4F0),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.w900,
      ),
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFA594F9),
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black, width: 3),
        ),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ).copyWith(
        elevation: WidgetStateProperty.all(0),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 4),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black, width: 3),
      ),
    ),
  );

  // ── Neo-Brutalist Dark Theme ──────────────────────────────────────
  static final ThemeData neoDarkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1E1E24), // Dark grey
    textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFA594F9),
      secondary: Color(0xFFFFB4A2),
      surface: Color(0xFF2B2B36),
      error: Color(0xFFFF4D4D),
      onPrimary: Colors.black,
      onSurface: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E24),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w900,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFA594F9),
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black, width: 3),
        ),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2B2B36),
      hintStyle: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 4),
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2B2B36),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black, width: 3),
      ),
    ),
  );

  // ── Helper method for Neo-Brutalist BoxShadow ──────────────────────
  static List<BoxShadow> get neoShadow => const [
    BoxShadow(
      color: Colors.black,
      offset: Offset(4, 4),
    ),
  ];
}
