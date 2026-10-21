import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/driver_store.dart';
import '../../core/fixtures.dart';
import '../../core/geo.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../../widgets/map_tiles.dart';
import '../../widgets/markers.dart';
import '../admin_data.dart';
import '../admin_store.dart';
import '../admin_widgets.dart';

/// Mapa ao vivo: every driver in town, coloured by status. Marcos follows the driver app.
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  final _map = MapController();
  late final Ticker _ticker = createTicker((e) => setState(() => _clock = e.inMilliseconds / 1000));
  double _clock = 0;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _map.dispose();
    super.dispose();
  }

  /// A block-shaped loop for each fixture driver around the centre.
  List<LatLng> _loop(int i) {
    final lat = Fixtures.pickup.latitude + ((i * 37) % 11 - 5) * 0.0011;
    final lon = Fixtures.pickup.longitude + ((i * 53) % 13 - 6) * 0.0012;
    const w = 0.0034, h = 0.0026;
    return [LatLng(lat, lon), LatLng(lat, lon + w), LatLng(lat + h, lon + w), LatLng(lat + h, lon), LatLng(lat, lon)];
  }

  LatLng _positionOf(AdminStore store, AdminDriver d, int i) {
    if (d.id == 'm1' && store.driver != null) return store.driver!.position;
    final status = store.statusOf(d);
    final speed = status == DriverStatus.offline ? 0.0 : 0.012 + (i % 4) * 0.004;
    final f = (i * 0.137 + _clock * speed) % 1;
    return Geo.pointOn(_loop(i), f);
  }

  @override
  Widget build(BuildContext context) {
    final store = AdminScope.of(context);
    final visible = [
      for (final (i, d) in store.drivers.indexed)
        if (store.statusOf(d) != DriverStatus.review && store.statusOf(d) != DriverStatus.blocked) (i, d),
    ];
    final mapView = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        mapController: _map,
        options: const MapOptions(initialCenter: LatLng(-3.4950, -39.5780), initialZoom: 14.6, backgroundColor: mapBackground),
        children: [
          const MapTiles(),
          if (store.driver?.request != null && (store.driver!.phase == DriverPhase.onTrip || store.driver!.phase == DriverPhase.toPickup))
            PolylineLayer(polylines: [
              Polyline(
                points: store.driver!.phase == DriverPhase.onTrip ? store.driver!.tripRoute : store.driver!.approach,
                color: ZTheme.youBlue,
                strokeWidth: 4,
              ),
            ]),
          MarkerLayer(markers: [
            for (final (i, d) in visible)
              Marker(
                point: _positionOf(store, d, i),
                width: _selected == d.id ? 46 : 34,
                height: _selected == d.id ? 46 : 34,
                child: Tooltip(
                  message: '${d.name} · ${store.statusOf(d).label}',
                  child: GestureDetector(
                    onTap: () => setState(() => _selected = d.id),
                    child: Opacity(
                      opacity: store.statusOf(d) == DriverStatus.offline ? 0.45 : 1,
                      child: VehicleMarker(
                        kind: d.car.contains('Honda CG') || d.car.contains('Biz') || d.car.contains('Factor') ? VehicleKind.moto : VehicleKind.car,
                        heading: 90,
                        highlighted: store.statusOf(d) == DriverStatus.onTrip || _selected == d.id,
                      ),
                    ),
                  ),
                ),
              ),
          ]),
          const Align(alignment: Alignment.bottomRight, child: Padding(padding: EdgeInsets.all(6), child: Text('© OpenStreetMap', style: TextStyle(fontSize: 10)))),
        ],
      ),
    );
    final list = AdminCard(
      title: 'Frota agora',
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(children: [
        for (final (i, d) in visible)
          ListTile(
            key: ValueKey('fleet_${d.id}'),
            dense: true,
            selected: _selected == d.id,
            selectedTileColor: ZTheme.accentSoft,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${d.car} · ${d.plate}', maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: StatusPill(store.statusOf(d).label, driverColor(store.statusOf(d))),
            onTap: () {
              setState(() => _selected = d.id);
              _map.move(_positionOf(store, d, i), 16);
            },
          ),
      ]),
    );
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth > 1000;
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const PageHeader('Mapa ao vivo', subtitle: 'Posição dos motoristas atualizada em tempo real'),
          Expanded(
            child: wide
                ? Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Expanded(child: mapView),
                    const SizedBox(width: 14),
                    SizedBox(width: 340, child: SingleChildScrollView(child: list)),
                  ])
                : ListView(children: [SizedBox(height: 420, child: mapView), const SizedBox(height: 14), list]),
          ),
        ]),
      );
    });
  }
}
