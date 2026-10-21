import 'package:flutter/material.dart';

import 'admin/admin_app.dart';
import 'admin/admin_store.dart';

/// Entry point of the admin panel on its own.
void main() => runApp(AdminApp(store: AdminStore()));
