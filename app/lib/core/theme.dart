import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// ITAX palette: all-black UI, white text and primary actions, "verde-jangada" accent.
class ZTheme {
  static const accent = Color(0xFF00C2A0);
  static const accentSoft = Color(0x2600C2A0);
  static const sun = Color(0xFFFFB533);
  static const youBlue = Color(0xFF3D8BFF);

  /// Text and primary actions (white on black).
  static const ink = Color(0xFFFFFFFF);

  /// Text and icons placed on an [ink] background.
  static const onInk = Color(0xFF000000);

  /// Black text on light fills (white, accent), white text on dark or saturated ones.
  static Color textOn(Color background) => background.computeLuminance() > 0.3 ? onInk : Colors.white;

  /// Page background.
  static const surface = Color(0xFF000000);

  /// Raised surfaces: cards, sheets, floating buttons over the map.
  static const card = Color(0xFF161618);
  static const fill = Color(0xFF1F1F22);
  static const fill2 = Color(0xFF2C2C2F);
  static const secondary = Color(0xFF9A9AA1);
  static const tertiary = Color(0xFF4A4A4F);
  static const hairline = Color(0x24FFFFFF);
  static const danger = Color(0xFFFF453A);

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
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.dark, surface: surface, primary: accent),
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
      dialogTheme: const DialogThemeData(backgroundColor: card, surfaceTintColor: Colors.transparent),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: card, surfaceTintColor: Colors.transparent),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: accent),
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
