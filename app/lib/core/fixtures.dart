import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';

import 'formatters.dart';
import 'models.dart';
import 'theme.dart';

/// Every piece of demo data lives here. Nothing is persisted: each launch starts from these values.
class Fixtures {
  // MARK: User and pickup (Praça da Matriz, Centro de Itapipoca)

  static const pickup = LatLng(-3.4944, -39.5786);
  static const pickupName = 'Local atual';
  static const pickupAddress = 'Praça da Matriz, Centro · Itapipoca';
  static const cityName = 'Itapipoca, CE';

  static const userName = 'Davi Filipe';
  static const userFirstName = 'Davi';
  static const userRating = 4.89;
  static const userTrips = 128;
  static const userPhone = '(88) 99812-4417';
  static const userEmail = 'davi.filipe@itax.app';
  static final userPhotoUrl = image('photo-1507003211169-0a1dd7228f2d');

  static final driver = Driver('Marcos', 4.92, 2341, 'Chevrolet Onix · Prata', 'PNX4E21', image('photo-1500648767791-00dcc994a43e'));

  static const quickReplies = ['Estou a caminho', 'Já estou no ponto de embarque'];
  static const driverReplies = [
    'Beleza, já tô chegando, visse! 👍',
    'Show! Tô pertinho da Praça da Matriz, um minutinho.',
    'Tranquilo, te espero aqui na frente.',
  ];

  // MARK: Places

  static const home = Place('casa', 'Casa', 'Rua Anastácio Braga, 1458 – Centro', CupertinoIcons.house_fill, -3.4921, -39.5753);
  static const work = Place('trabalho', 'Trabalho', 'IFCE Campus Itapipoca – Ladeira', CupertinoIcons.briefcase_fill, -3.4797, -39.5703);

  static const places = [
    Place('matriz', 'Igreja Matriz de N. Sra. das Mercês', 'Praça da Matriz – Centro', CupertinoIcons.building_2_fill, -3.4951, -39.5795),
    Place('praca', 'Praça da Matriz', 'Centro – Itapipoca', CupertinoIcons.tree, -3.4957, -39.5776),
    Place('mercado', 'Mercado Público', 'Rua Coronel Raimundo Matos – Centro', CupertinoIcons.cart_fill, -3.4926, -39.5809),
    Place('rodoviaria', 'Rodoviária de Itapipoca', 'Av. Perimetral – Fazendinha', CupertinoIcons.bus, -3.5034, -39.5840),
    Place('ifce', 'IFCE Campus Itapipoca', 'Ladeira – Itapipoca', CupertinoIcons.book_fill, -3.4797, -39.5703),
    Place('facedi', 'FACEDI / UECE', 'Av. Monsenhor Tabosa – Boa Vista', CupertinoIcons.book, -3.5012, -39.5917),
    Place('estacao', 'Estação Ferroviária', 'Rua da Estação – Centro', CupertinoIcons.tram_fill, -3.4987, -39.5752),
    Place('acude', 'Açude Poço Verde', 'Estrada do Poço Verde – Zona rural', CupertinoIcons.drop_fill, -3.4602, -39.6125),
    Place('baleia', 'Praia da Baleia', 'Distrito da Baleia – Litoral', CupertinoIcons.sun_max_fill, -3.2391, -39.6742),
    Place('pedrinhas', 'Praia de Pedrinhas', 'Litoral de Itapipoca', CupertinoIcons.wind, -3.2655, -39.6198),
    Place('arapari', 'Distrito de Arapari', 'Arapari – Itapipoca', CupertinoIcons.house, -3.3786, -39.6301),
    Place('aeroporto', 'Aeroporto de Fortaleza', 'Av. Senador Carlos Jereissati – Fortaleza', CupertinoIcons.airplane, -3.7763, -38.5326),
  ];

  static Place place(String id) {
    if (id == home.id) return home;
    if (id == work.id) return work;
    return places.firstWhere((p) => p.id == id, orElse: () => places.first);
  }

  static List<Place> get recents => ['mercado', 'rodoviaria', 'baleia'].map(place).toList();
  static List<Place> get suggestions => ['matriz', 'praca', 'estacao', 'facedi', 'acude', 'pedrinhas'].map(place).toList();

  // MARK: Rides

  static const rideTypes = [
    RideType(id: 'x', name: 'ITAX Go', tagline: 'Viagens do dia a dia', seats: 4, etaMinutes: 3, basePrice: 9.90, perKm: 1.45, kind: VehicleKind.car, color: Color(0xFFEBEBEB)),
    RideType(id: 'moto', name: 'Moto', tagline: 'Chega mais rápido', seats: 1, etaMinutes: 2, basePrice: 5.90, perKm: 0.85, kind: VehicleKind.moto, color: ZTheme.accent),
    RideType(id: 'comfort', name: 'Comfort', tagline: 'Carros novos e mais espaço', seats: 4, etaMinutes: 4, basePrice: 13.50, perKm: 1.95, kind: VehicleKind.car, color: Color(0xFF8C9EB3)),
    RideType(id: 'xl', name: 'XL', tagline: 'Para até 6 pessoas', seats: 6, etaMinutes: 6, basePrice: 17.80, perKm: 2.50, kind: VehicleKind.car, color: Color(0xFF59667A)),
    RideType(id: 'black', name: 'Black', tagline: 'Motoristas mais bem avaliados', seats: 4, etaMinutes: 7, basePrice: 22.40, perKm: 3.10, kind: VehicleKind.car, color: Color(0xFF1F1F1F)),
  ];

  static RideType rideType(String id) => rideTypes.firstWhere((r) => r.id == id, orElse: () => rideTypes.first);

  // MARK: Services

  static const services = [
    ServiceTile('viagem', 'Viagem', 'Vá para qualquer lugar', CupertinoIcons.car_fill, 'x'),
    ServiceTile('moto', 'Moto', 'Rápido e barato', CupertinoIcons.speedometer, 'moto'),
    ServiceTile('agendar', 'Agendar', 'Reserve com antecedência', CupertinoIcons.calendar, null),
    ServiceTile('entrega', 'Entrega', 'Envie pacotes na cidade', CupertinoIcons.cube_box_fill, 'moto'),
    ServiceTile('comfort', 'Comfort', 'Mais espaço', CupertinoIcons.car_detailed, 'comfort'),
    ServiceTile('xl', 'XL', 'Para o grupo todo', CupertinoIcons.person_3_fill, 'xl'),
    ServiceTile('black', 'Black', 'Viagem premium', CupertinoIcons.star_fill, 'black'),
    ServiceTile('aluguel', 'Aluguel', 'Motorista por hora', CupertinoIcons.clock_fill, null),
  ];

  // MARK: Driver path and ambient traffic

  /// Where the matched driver starts and the streets he drives to reach the pickup.
  static const driverApproach = [
    LatLng(-3.4878, -39.5714),
    LatLng(-3.4893, -39.5729),
    LatLng(-3.4906, -39.5748),
    LatLng(-3.4922, -39.5762),
    LatLng(-3.4934, -39.5777),
    pickup,
  ];

  static final ambientVehicles = [
    AmbientVehicle(VehicleKind.car, _loop(0.0000, -0.0030, 0.0040, 0.0024), 0.020, 0.10),
    AmbientVehicle(VehicleKind.car, _loop(0.0035, 0.0018, 0.0030, 0.0030), 0.016, 0.55),
    AmbientVehicle(VehicleKind.car, _loop(-0.0040, 0.0005, 0.0050, 0.0020), 0.012, 0.30),
    AmbientVehicle(VehicleKind.moto, _loop(0.0012, 0.0030, 0.0022, 0.0034), 0.026, 0.75),
    AmbientVehicle(VehicleKind.moto, _loop(-0.0018, -0.0042, 0.0026, 0.0028), 0.022, 0.40),
  ];

  /// A closed rectangular block around the city centre.
  static List<LatLng> _loop(double dLat, double dLon, double w, double h) {
    final lat = pickup.latitude + dLat;
    final lon = pickup.longitude + dLon;
    return [
      LatLng(lat - h / 2, lon - w / 2),
      LatLng(lat - h / 2, lon + w / 2),
      LatLng(lat + h / 2, lon + w / 2),
      LatLng(lat + h / 2, lon - w / 2),
      LatLng(lat - h / 2, lon - w / 2),
    ];
  }

  // MARK: History

  static final pastTrips = [
    Trip(id: 't1', date: BR.fortaleza(2026, 10, 19, 18, 42), pickupName: 'Casa', destination: place('praca'), rideName: 'ITAX Go', driverName: 'Francisca', payment: PaymentMethod.pix, fare: 9.90, tip: 2, rating: 5, distanceKm: 1.1, durationMinutes: 6),
    Trip(id: 't2', date: BR.fortaleza(2026, 10, 17, 7, 55), pickupName: 'Casa', destination: place('ifce'), rideName: 'Moto', driverName: 'Raimundo', payment: PaymentMethod.pix, fare: 5.90, tip: 0, rating: 5, distanceKm: 2.4, durationMinutes: 8),
    Trip(id: 't3', date: BR.fortaleza(2026, 10, 12, 9, 10), pickupName: 'Rodoviária', destination: place('baleia'), rideName: 'Comfort', driverName: 'Antônia', payment: PaymentMethod.visa, fare: 73.80, tip: 5, rating: 4, distanceKm: 33.2, durationMinutes: 41),
    Trip(id: 't4', date: BR.fortaleza(2026, 10, 5, 20, 15), pickupName: 'Mercado Público', destination: place('facedi'), rideName: 'ITAX Go', driverName: 'Cícero', payment: PaymentMethod.cash, fare: 9.90, tip: 0, rating: 5, distanceKm: 1.9, durationMinutes: 7),
  ];

  // MARK: Images (verified by scripts/check-urls.sh in CI)

  static final servicesBannerUrl = image('photo-1558981403-c5f9899a28bc');

  static String image(String id) => 'https://images.unsplash.com/$id?w=800&q=80&fit=crop';
}
