import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Small geometry helpers on lat/lon paths.
class Geo {
  static const _distance = Distance();

  static double meters(LatLng a, LatLng b) => _distance.as(LengthUnit.Meter, a, b);

  /// Road distance estimated from the straight line (×1.3), at least 0.4 km.
  static double roadDistanceKm(LatLng a, LatLng b) => math.max(0.4, meters(a, b) * 1.3 / 1000);

  static double length(List<LatLng> path) {
    var total = 0.0;
    for (var i = 1; i < path.length; i++) {
      total += meters(path[i - 1], path[i]);
    }
    return total;
  }

  static LatLng pointOn(List<LatLng> path, double fraction) {
    if (path.isEmpty) return const LatLng(0, 0);
    if (path.length == 1) return path.first;
    final f = fraction.clamp(0.0, 1.0);
    var target = length(path) * f;
    for (var i = 1; i < path.length; i++) {
      final segment = meters(path[i - 1], path[i]);
      if (target <= segment || i == path.length - 1) {
        final t = segment == 0 ? 0.0 : (target / segment).clamp(0.0, 1.0);
        return interpolate(path[i - 1], path[i], t);
      }
      target -= segment;
    }
    return path.last;
  }

  static List<LatLng> prefix(List<LatLng> path, double fraction) {
    if (path.length < 2 || fraction <= 0) return const [];
    if (fraction >= 1) return path;
    final count = math.max(1, (path.length * fraction).floor());
    return [...path.take(count), pointOn(path, fraction)];
  }

  /// Heading in degrees, clockwise from north, at a point along the path.
  static double headingOn(List<LatLng> path, double fraction) {
    if (path.length < 2) return 0;
    final a = pointOn(path, math.max(0, fraction - 0.01));
    final b = pointOn(path, math.min(1, fraction + 0.01));
    return bearing(a, b);
  }

  static double bearing(LatLng a, LatLng b) {
    final lat1 = a.latitudeInRad, lat2 = b.latitudeInRad;
    final dLon = (b.longitude - a.longitude) * math.pi / 180;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  static LatLng interpolate(LatLng a, LatLng b, double t) =>
      LatLng(a.latitude + (b.latitude - a.latitude) * t, a.longitude + (b.longitude - a.longitude) * t);

  /// A gently curved route between two points (49 points along a quadratic Bézier).
  static List<LatLng> curvedRoute(LatLng a, LatLng b) {
    final midLat = (a.latitude + b.latitude) / 2;
    final midLon = (a.longitude + b.longitude) / 2;
    final dLat = b.latitude - a.latitude;
    final dLon = b.longitude - a.longitude;
    final c = LatLng(midLat - dLon * 0.18, midLon + dLat * 0.18);
    return [
      for (var s = 0; s <= 48; s++)
        () {
          final t = s / 48, u = 1 - t;
          return LatLng(
            u * u * a.latitude + 2 * u * t * c.latitude + t * t * b.latitude,
            u * u * a.longitude + 2 * u * t * c.longitude + t * t * b.longitude,
          );
        }(),
    ];
  }
}
