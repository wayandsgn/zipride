import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../core/ride_store.dart';

/// Muted CARTO light basemap shared by every map. Hidden when the store turns tiles off (tests).
class MapTiles extends StatelessWidget {
  const MapTiles({super.key});

  @override
  Widget build(BuildContext context) {
    if (!StoreScope.read(context).showMapTiles) return const SizedBox.shrink();
    return TileLayer(
      urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
      subdomains: const ['a', 'b', 'c', 'd'],
      retinaMode: RetinaMode.isHighDensity(context),
      userAgentPackageName: 'app.zipride.zipride',
      maxZoom: 19,
    );
  }
}

const mapBackground = Color(0xFFF2F1ED);
