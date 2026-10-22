import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../core/fixtures.dart';
import '../../core/geo.dart';
import '../../core/models.dart';
import '../../widgets/map_tiles.dart';

/// Static, non-interactive map of the route from the pickup to a destination.
class TripMiniMap extends StatelessWidget {
  const TripMiniMap({super.key, required this.destination});

  final Place destination;

  @override
  Widget build(BuildContext context) {
    final route = Geo.curvedRoute(Fixtures.pickup, destination.point);
    return IgnorePointer(
      child: FlutterMap(
        options: MapOptions(
          initialCameraFit: CameraFit.coordinates(coordinates: route, padding: const EdgeInsets.all(28)),
          backgroundColor: mapBackground,
          interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
        ),
        children: [
          const MapTiles(),
          PolylineLayer(polylines: [
            Polyline(points: route, color: Colors.black, strokeWidth: 4, strokeCap: StrokeCap.round, strokeJoin: StrokeJoin.round),
          ]),
          MarkerLayer(markers: [
            Marker(point: Fixtures.pickup, width: 12, height: 12, child: _end(circle: true)),
            Marker(point: destination.point, width: 12, height: 12, child: _end(circle: false)),
          ]),
          const Align(
            alignment: Alignment.bottomRight,
            child: ColoredBox(
              color: Color(0xE6FFFFFF),
              child: Text('© OpenStreetMap contributors', style: TextStyle(fontSize: 9, color: Color(0xFF404040))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _end({required bool circle}) {
    final radius = BorderRadius.circular(circle ? 6 : 2);
    return Container(
      decoration: BoxDecoration(color: Colors.black, borderRadius: radius),
      alignment: Alignment.center,
      child: Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(circle ? 2 : 1))),
    );
  }
}
