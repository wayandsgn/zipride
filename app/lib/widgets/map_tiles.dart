import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../core/ride_store.dart';

/// Public OpenStreetMap tiles for this low-traffic demo. Hidden in widget tests.
class MapTiles extends StatelessWidget {
  const MapTiles({super.key});

  @override
  Widget build(BuildContext context) {
    if (!StoreScope.read(context).showMapTiles) return const SizedBox.shrink();
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'app.zipride.zipride',
      maxZoom: 19,
    );
  }
}

const mapBackground = Color(0xFFF2F1ED);
