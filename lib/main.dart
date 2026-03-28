import 'package:flutter/material.dart';

import 'constants.dart';
import 'pages/splash_page.dart';
import 'services/notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MoonlightNotifications.instance.initialize();
  runApp(const MoonlightMemoApp());
}

class MoonlightMemoApp extends StatelessWidget {
  const MoonlightMemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '????',
      debugShowCheckedModeBanner: false,
      locale: const Locale('zh', 'CN'),
      theme: _buildTheme(),
      home: const SplashScreen(),
    );
  }
}

ThemeData _buildTheme() {
  final base = ThemeData(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: kHotPink,
      brightness: Brightness.light,
      primary: kHotPink,
      secondary: kPurple,
      tertiary: kGold,
      surface: const Color(0xFFFFFBFF),
    ),
    scaffoldBackgroundColor: Colors.transparent,
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white.withAlpha(245),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: Color(0xFF7A2E73),
      ),
      contentTextStyle: const TextStyle(
        fontSize: 15,
        height: 1.65,
        fontWeight: FontWeight.w700,
        color: Color(0xFF8B5C95),
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: const Color(0xFF6B2E63),
      displayColor: const Color(0xFF6B2E63),
      fontFamily: 'Microsoft YaHei',
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Color(0xFF6B2E63),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      color: Colors.white.withAlpha(214),
      shadowColor: kPurple.withAlpha(46),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: kPurple,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kHotPink,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withAlpha(230),
      hintStyle: TextStyle(color: const Color(0xFF9A6C9C).withAlpha(184)),
      labelStyle: const TextStyle(color: Color(0xFF9A4D86)),
      prefixIconColor: kHotPink,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: kHotPink.withAlpha(31)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: kHotPink, width: 1.5),
      ),
    ),
  );
}
