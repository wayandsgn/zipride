import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/ride_store.dart';
import 'core/theme.dart';
import 'screens/root.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(ItaxApp(store: RideStore()));
}

class ItaxApp extends StatelessWidget {
  const ItaxApp({super.key, required this.store});

  final RideStore store;

  @override
  Widget build(BuildContext context) {
    return StoreScope(
      store: store,
      child: MaterialApp(
        title: 'ITAX',
        debugShowCheckedModeBanner: false,
        theme: ZTheme.data(),
        locale: ZTheme.locale,
        supportedLocales: ZTheme.locales,
        localizationsDelegates: ZTheme.delegates,
        home: const AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.black,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: RootScreen(),
        ),
      ),
    );
  }
}
