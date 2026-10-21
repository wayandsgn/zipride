import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/driver_store.dart';
import 'driver/driver_app.dart';

/// Entry point of the driver app on a phone.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(DriverApp(store: DriverStore()));
}
