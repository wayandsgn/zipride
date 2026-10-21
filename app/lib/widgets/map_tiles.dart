import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// OpenStreetMap basemap, desaturated and lifted so it reads like a muted Apple map.
/// Shared by every map in the customer, driver and admin apps.
class MapTiles extends StatelessWidget {
  const MapTiles({super.key});

  /// Tests turn tiles off so they never touch the network.
  static bool enabled = true;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
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
