import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

import 'fixtures.dart';
import 'geo.dart';

class Place {
  const Place(this.id, this.name, this.address, this.icon, this.lat, this.lon);

  final String id;
  final String name;
  final String address;
  final IconData icon;
  final double lat;
  final double lon;

  LatLng get point => LatLng(lat, lon);

  /// Road distance from the fixed pickup point, estimated from the straight line.
  double get distanceKm => Geo.roadDistanceKm(Fixtures.pickup, point);
}

enum VehicleKind { car, moto }

class RideType {
  const RideType({
    required this.id,
    required this.name,
    required this.tagline,
    required this.seats,
    required this.etaMinutes,
    required this.basePrice,
    required this.perKm,
    required this.kind,
    required this.color,
  });

  final String id;
  final String name;
  final String tagline;
  final int seats;
  final int etaMinutes;
  final double basePrice;
  final double perKm;
  final VehicleKind kind;
  final Color color;

  /// In-town trips (up to 3 km) cost the base price; longer trips add a per-km rate.
  /// The admin panel can change both and add surge pricing (see [Pricing]).
  double priceFor(double km) {
    final p = Pricing.instance;
    final extra = (km - 3).clamp(0, double.infinity) * p.perKm(this);
    return ((p.base(this) + extra) * p.surge * 10).round() / 10;
  }
}

/// Live price table edited in the admin panel. Starts from the values in Fixtures.
class Pricing extends ChangeNotifier {
  static final instance = Pricing();

  final Map<String, (double, double)> _overrides = {};
  double surge = 1;

  double base(RideType r) => _overrides[r.id]?.$1 ?? r.basePrice;
  double perKm(RideType r) => _overrides[r.id]?.$2 ?? r.perKm;

  void set(RideType r, {required double base, required double perKm}) {
    _overrides[r.id] = (base, perKm);
    notifyListeners();
  }

  void setSurge(double value) {
    surge = value;
    notifyListeners();
  }

  void reset() {
    _overrides.clear();
    surge = 1;
    notifyListeners();
  }
}

enum PaymentMethod {
  pix('Pix', 'Pagamento na hora, sem taxa'),
  visa('Visa •••• 4242', 'Crédito · vence 08/29'),
  cash('Dinheiro', 'Pague direto ao motorista');

  const PaymentMethod(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

class Driver {
  const Driver(this.name, this.rating, this.trips, this.car, this.plate, this.photoUrl);
  final String name;
  final double rating;
  final int trips;
  final String car;
  final String plate;
  final String photoUrl;
}

class ChatMessage {
  const ChatMessage(this.text, {required this.fromDriver, required this.time});
  final String text;
  final bool fromDriver;
  final DateTime time;
}

class Trip {
  const Trip({
    required this.id,
    required this.date,
    required this.pickupName,
    required this.destination,
    required this.rideName,
    required this.driverName,
    required this.payment,
    required this.fare,
    required this.tip,
    required this.rating,
    required this.distanceKm,
    required this.durationMinutes,
  });

  final String id;
  final DateTime date;
  final String pickupName;
  final Place destination;
  final String rideName;
  final String driverName;
  final PaymentMethod payment;
  final double fare;
  final double tip;
  final int rating;
  final double distanceKm;
  final int durationMinutes;

  double get total => fare + tip;
}

class ServiceTile {
  const ServiceTile(this.id, this.title, this.subtitle, this.icon, this.rideTypeId);
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String? rideTypeId;
}

class AmbientVehicle {
  const AmbientVehicle(this.kind, this.loop, this.speed, this.offset);
  final VehicleKind kind;
  final List<LatLng> loop;
  final double speed;
  final double offset;
}
