import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/driver_store.dart';
import '../core/geo.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../widgets/map_tiles.dart';
import '../widgets/markers.dart';

/// Map behind the driver app: the car, the way to the passenger and the trip.
class DriverMap extends StatefulWidget {
  const DriverMap({super.key});

  @override
  State<DriverMap> createState() => _DriverMapState();
}

class _DriverMapState extends State<DriverMap> with SingleTickerProviderStateMixin {
  final _map = MapController();
  late final AnimationController _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  late final Animation<double> _curve = CurvedAnimation(parent: _fly, curve: Curves.easeInOutCubic);
  LatLng _fromCenter = const LatLng(-3.4930, -39.5760);
  LatLng _toCenter = const LatLng(-3.4930, -39.5760);
  double _fromZoom = 15.4;
  double _toZoom = 15.4;
  bool _ready = false;
  int _seen = -1;

  @override
  void initState() {
    super.initState();
    _fly.addListener(() {
      final t = _curve.value;
      _map.move(Geo.interpolate(_fromCenter, _toCenter, t), _fromZoom + (_toZoom - _fromZoom) * t);
    });
  }

  @override
  void dispose() {
    _fly.dispose();
    _map.dispose();
    super.dispose();
  }

  void _follow(DriverStore store) {
    if (!_ready || store.cameraVersion == _seen) return;
    _seen = store.cameraVersion;
    final target = store.camera;
    final size = MediaQuery.sizeOf(context);
    final goal = target.center != null
        ? _map.camera.withPosition(center: target.center, zoom: target.zoom)
        : CameraFit.coordinates(
            coordinates: target.points,
            padding: EdgeInsets.fromLTRB(56, 130, 56, size.height * target.bottomShare + 40),
            maxZoom: 16.5,
          ).fit(_map.camera);
    _fromCenter = _map.camera.center;
    _fromZoom = _map.camera.zoom;
    _toCenter = goal.center;
    _toZoom = goal.zoom;
    _fly.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final store = DriverScope.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _follow(store);
    });
    final r = store.request;
    final phase = store.phase;
    final showApproach = r != null && (phase == DriverPhase.request || phase == DriverPhase.toPickup);
    final showTrip = r != null && (phase == DriverPhase.request || phase == DriverPhase.onTrip || phase == DriverPhase.atPickup);
    return FlutterMap(
      mapController: _map,
      options: MapOptions(
        initialCenter: _fromCenter,
        initialZoom: _fromZoom,
        backgroundColor: mapBackground,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom),
        onMapReady: () => _ready = true,
      ),
      children: [
        const MapTiles(),
        PolylineLayer(polylines: [
          if (showApproach)
            Polyline(
              points: phase == DriverPhase.toPickup ? Geo.prefix(store.approach.reversed.toList(), 1 - store.progress).reversed.toList() : store.approach,
              color: ZTheme.youBlue,
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
              strokeJoin: StrokeJoin.round,
            ),
          if (showTrip) Polyline(points: store.tripRoute, color: routeColor, strokeWidth: 5, strokeCap: StrokeCap.round, strokeJoin: StrokeJoin.round),
        ]),
        MarkerLayer(markers: [
          if (r != null && phase != DriverPhase.onTrip && phase != DriverPhase.finished)
            Marker(point: r.pickup.point, width: 60, height: 60, child: const PickupPin()),
          if (r != null && phase != DriverPhase.toPickup)
            Marker(
              point: r.destination.point,
              width: 200,
              height: 60,
              alignment: Alignment.topCenter,
              child: Align(alignment: Alignment.bottomCenter, child: DestinationPin(title: r.destination.name)),
            ),
          Marker(
            point: store.position,
            width: phase == DriverPhase.searching ? 200 : 40,
            height: phase == DriverPhase.searching ? 200 : 40,
            child: phase == DriverPhase.searching
                ? const Stack(alignment: Alignment.center, children: [RadarPulse(), VehicleMarker(kind: VehicleKind.car, highlighted: true)])
                : VehicleMarker(kind: VehicleKind.car, heading: store.heading, highlighted: phase != DriverPhase.offline),
          ),
        ]),
        const Align(
          alignment: Alignment(1, -0.62),
          child: Padding(
            padding: EdgeInsets.only(right: 6),
            child: Text('© OpenStreetMap', style: TextStyle(fontSize: 9, color: Color(0x99FFFFFF))),
          ),
        ),
      ],
    );
  }
}
