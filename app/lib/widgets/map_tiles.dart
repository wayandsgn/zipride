import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// OpenStreetMap basemap, inverted to a dark grey night map behind the black UI.
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
      userAgentPackageName: 'app.itax.itax',
      maxZoom: 19,
      tileBuilder: (context, tile, _) => ColorFiltered(colorFilter: _muted, child: tile),
    );
  }
}

/// Grayscale, inverted and compressed to dark greys: streets stay legible but quiet.
const _muted = ColorFilter.matrix([
  -0.17, -0.57, -0.06, 0, 225,
  -0.17, -0.57, -0.06, 0, 228,
  -0.17, -0.57, -0.06, 0, 234,
  0, 0, 0, 1, 0,
]);

const mapBackground = Color(0xFF1A1B1E);

/// Route lines drawn over the dark map.
const routeColor = Color(0xFFFFFFFF);
