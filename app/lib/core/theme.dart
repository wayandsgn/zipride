import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Zipride palette: "verde-jangada" accent on a clean light UI with black primary actions.
class ZTheme {
  static const accent = Color(0xFF009E87);
  static const accentSoft = Color(0x1F009E87);
  static const sun = Color(0xFFFFB533);
  static const youBlue = Color(0xFF2978FF);
  static const ink = Color(0xFF000000);
  static const surface = Color(0xFFFFFFFF);
  static const fill = Color(0xFFF2F2F7);
  static const fill2 = Color(0xFFE9E9EE);
  static const secondary = Color(0xFF6C6C70);
  static const tertiary = Color(0xFFC7C7CC);
  static const hairline = Color(0x14000000);
  static const danger = Color(0xFFE5372C);

  static const sheetRadius = 28.0;
  static const cardRadius = 18.0;

  static const font = 'Inter';

  /// Every app speaks Brazilian Portuguese, including system strings (back, copy, paste).
  static const locale = Locale('pt', 'BR');
  static const locales = [locale];
  static const delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static ThemeData data() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: font,
      colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.light, surface: surface),
      scaffoldBackgroundColor: surface,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      // iOS-style page transitions on Android too.
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink, fontFamily: font),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: ink,
        centerTitle: true,
        titleTextStyle: TextStyle(fontFamily: font, fontSize: 17, fontWeight: FontWeight.w600, color: ink),
      ),
      dividerTheme: const DividerThemeData(color: hairline, thickness: 1, space: 1),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? accent : fill2),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }
}

/// Text styles used across the app (SF-like hierarchy set in Inter).
class ZText {
  static const largeTitle = TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.8, color: ZTheme.ink);
  static const title = TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: ZTheme.ink);
  static const headline = TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: ZTheme.ink);
  static const body = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: ZTheme.ink);
  static const bodyStrong = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ZTheme.ink);
  static const sub = TextStyle(fontSize: 14, color: ZTheme.secondary);
  static const foot = TextStyle(fontSize: 13, color: ZTheme.secondary);
  static const caption = TextStyle(fontSize: 12, color: ZTheme.secondary);
  static const section = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.7, color: ZTheme.secondary);
  static const tabular = [FontFeature.tabularFigures()];
}
