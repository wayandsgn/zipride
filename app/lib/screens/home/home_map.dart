import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/fixtures.dart';
import '../../core/geo.dart';
import '../../core/ride_store.dart';
import '../../widgets/map_tiles.dart';
import '../../widgets/markers.dart';

/// The muted map behind every Home state: traffic, you-are-here dot, route and driver.
class HomeMap extends StatefulWidget {
  const HomeMap({super.key});

  @override
  State<HomeMap> createState() => _HomeMapState();
}

class _HomeMapState extends State<HomeMap> with TickerProviderStateMixin {
  final _map = MapController();
  late final Ticker _ticker = createTicker(_tick);
  late final AnimationController _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  Animation<double>? _flyCurve;
  LatLng _fromCenter = RideStore.homeCamera.center!;
  LatLng _toCenter = RideStore.homeCamera.center!;
  double _fromZoom = RideStore.homeCamera.zoom!;
  double _toZoom = RideStore.homeCamera.zoom!;
  bool _ready = false;
  int _seenCamera = -1;
  double _clock = 0;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _flyCurve = CurvedAnimation(parent: _fly, curve: Curves.easeInOutCubic);
    _fly.addListener(() {
      final t = _flyCurve!.value;
      _map.move(Geo.interpolate(_fromCenter, _toCenter, t), _fromZoom + (_toZoom - _fromZoom) * t);
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _fly.dispose();
    _map.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    final store = StoreScope.read(context);
    if (store.phase == RidePhase.idle && store.tab == AppTab.home) {
      setState(() => _clock += dt.clamp(0, 0.1));
    }
  }

  void _followCamera(RideStore store) {
    if (!_ready || store.cameraVersion == _seenCamera) return;
    _seenCamera = store.cameraVersion;
    final target = store.camera;
    final size = MediaQuery.sizeOf(context);
    final MapCamera goal;
    if (target.center != null) {
      goal = _map.camera.withPosition(center: target.center, zoom: target.zoom);
    } else {
      final fit = CameraFit.coordinates(
        coordinates: target.points,
        padding: EdgeInsets.fromLTRB(56, 130, 56, size.height * target.bottomShare + 40),
        maxZoom: 16.5,
      );
      goal = fit.fit(_map.camera);
    }
    _fromCenter = _map.camera.center;
    _fromZoom = _map.camera.zoom;
    _toCenter = goal.center;
    _toZoom = goal.zoom;
    _fly.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _followCamera(store);
    });
    return FlutterMap(
      mapController: _map,
      options: MapOptions(
        initialCenter: RideStore.homeCamera.center!,
        initialZoom: RideStore.homeCamera.zoom!,
        backgroundColor: mapBackground,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom),
        onMapReady: () {
          _ready = true;
          _seenCamera = store.cameraVersion;
        },
      ),
      children: [
        const MapTiles(),
        if (store.visibleRoute.length > 1)
          PolylineLayer(polylines: [
            Polyline(points: store.visibleRoute, color: Colors.black, strokeWidth: 5, strokeCap: StrokeCap.round, strokeJoin: StrokeJoin.round),
          ]),
        MarkerLayer(markers: _markers(store)),
        const Align(
          alignment: Alignment(1, -0.62),
          child: Padding(
            padding: EdgeInsets.only(right: 6),
            child: Text('© OpenStreetMap', style: TextStyle(fontSize: 9, color: Color(0x99000000))),
          ),
        ),
      ],
    );
  }

  List<Marker> _markers(RideStore store) {
    final markers = <Marker>[];
    if (store.phase == RidePhase.idle) {
      for (final v in Fixtures.ambientVehicles) {
        final raw = v.offset + _clock * v.speed;
        final f = raw - raw.floorToDouble();
        markers.add(Marker(
          point: Geo.pointOn(v.loop, f),
          width: 30,
          height: 30,
          child: VehicleMarker(kind: v.kind, heading: Geo.headingOn(v.loop, f)),
        ));
      }
      markers.add(const Marker(point: Fixtures.pickup, width: 64, height: 64, child: PulsingDot()));
      return markers;
    }
    markers.add(Marker(
      point: Fixtures.pickup,
      width: 200,
      height: 200,
      child: Stack(alignment: Alignment.center, children: [
        if (store.phase == RidePhase.matching) const RadarPulse(),
        const PickupPin(),
      ]),
    ));
    final dest = store.destination;
    if (dest != null) {
      markers.add(Marker(
        point: dest.point,
        width: 200,
        height: 60,
        alignment: Alignment.topCenter,
        child: Align(alignment: Alignment.bottomCenter, child: DestinationPin(title: dest.name)),
      ));
    }
    final driver = store.driverPosition;
    if (driver != null) {
      markers.add(Marker(
        point: driver,
        width: 40,
        height: 40,
        child: VehicleMarker(kind: store.selectedRide.kind, heading: store.driverHeading, highlighted: true),
      ));
    }
    return markers;
  }
}
