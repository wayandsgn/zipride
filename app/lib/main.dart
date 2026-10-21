import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/ride_store.dart';
import 'core/theme.dart';
import 'screens/root.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(ZiprideApp(store: RideStore()));
}

class ZiprideApp extends StatelessWidget {
  const ZiprideApp({super.key, required this.store});

  final RideStore store;

  @override
  Widget build(BuildContext context) {
    return StoreScope(
      store: store,
      child: MaterialApp(
        title: 'Zipride',
        debugShowCheckedModeBanner: false,
        theme: ZTheme.data(),
        locale: const Locale('pt', 'BR'),
        home: const AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: RootScreen(),
        ),
      ),
    );
  }
}
