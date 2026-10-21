import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../core/ride_store.dart';

/// OpenStreetMap basemap, desaturated and lifted so it reads like a muted Apple map.
/// Shared by every map. Hidden when the store turns tiles off (tests).
class MapTiles extends StatelessWidget {
  const MapTiles({super.key});

  @override
  Widget build(BuildContext context) {
    if (!StoreScope.read(context).showMapTiles) return const SizedBox.shrink();
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'app.zipride.zipride',
      maxZoom: 19,
      tileBuilder: (context, tile, _) => ColorFiltered(colorFilter: _muted, child: tile),
    );
  }
}

/// 70% desaturated, slightly brighter: keeps streets legible but quiet behind the UI.
const _muted = ColorFilter.matrix([
  0.52, 0.48, 0.07, 0, 14,
  0.17, 0.83, 0.07, 0, 14,
  0.17, 0.48, 0.42, 0, 14,
  0, 0, 0, 1, 0,
]);

const mapBackground = Color(0xFFF2F1ED);
