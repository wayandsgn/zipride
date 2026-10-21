import '../core/fixtures.dart';
import '../core/geo.dart';
import '../core/models.dart';

enum RideStatus {
  live('Em andamento'),
  done('Concluída'),
  cancelled('Cancelada'),
  refunded('Reembolsada');

  const RideStatus(this.label);
  final String label;
}

enum DriverStatus {
  online('Online'),
  onTrip('Em corrida'),
  offline('Offline'),
  review('Em análise'),
  blocked('Bloqueado');

  const DriverStatus(this.label);
  final String label;
}

class AdminRide {
  AdminRide({
    required this.id,
    required this.time,
    required this.passenger,
    required this.driver,
    required this.from,
    required this.to,
    required this.rideName,
    required this.fare,
    required this.payment,
    required this.status,
    this.rating,
  });

  final String id;
  final DateTime time;
  final String passenger;
  final String driver;
  final Place from;
  final Place to;
  final String rideName;
  final double fare;
  final PaymentMethod payment;
  RideStatus status;
  final int? rating;

  double get km => Geo.roadDistanceKm(from.point, to.point);
}

class AdminDriver {
  AdminDriver(this.id, this.name, this.car, this.plate, this.rating, this.trips, this.status, {this.since = '2024'});
  final String id;
  final String name;
  final String car;
  final String plate;
  final double rating;
  final int trips;
  DriverStatus status;
  final String since;
}

class AdminPassenger {
  AdminPassenger(this.name, this.phone, this.trips, this.rating, {this.blocked = false});
  final String name;
  final String phone;
  final int trips;
  final double rating;
  bool blocked;
}

class TicketMessage {
  const TicketMessage(this.text, {required this.fromTeam, required this.time});
  final String text;
  final bool fromTeam;
  final DateTime time;
}

class Ticket {
  Ticket(this.id, this.subject, this.author, this.role, this.priority, this.messages, {this.resolved = false});
  final String id;
  final String subject;
  final String author;
  final String role;
  final String priority;
  final List<TicketMessage> messages;
  bool resolved;
}

class AdminEvent {
  const AdminEvent(this.time, this.kind, this.message);
  final DateTime time;
  final String kind;
  final String message;
}

/// Demo data for the admin panel, generated the same way on every launch.
class AdminData {
  static const passengerNames = [
    'Davi Filipe', 'Ana Beatriz', 'João Pedro', 'Francisca Lima', 'Cícera Alves', 'Lucas Rocha',
    'Maria Sousa', 'Antônio Carlos', 'Juliana Freitas', 'Raimundo Nonato', 'Larissa Monteiro', 'Pedro Henrique',
  ];

  static List<AdminDriver> drivers() => [
        AdminDriver('m1', 'Marcos Vieira', 'Chevrolet Onix · Prata', 'PNX4E21', 4.92, 2341, DriverStatus.offline),
        AdminDriver('m2', 'Francisca Oliveira', 'Hyundai HB20 · Branco', 'POI2B47', 4.95, 1820, DriverStatus.onTrip),
        AdminDriver('m3', 'Raimundo Costa', 'Honda CG 160 · Vermelha', 'SBX9C03', 4.88, 3102, DriverStatus.online),
        AdminDriver('m4', 'Antônia Ribeiro', 'Toyota Corolla · Preto', 'RIE5D88', 4.97, 954, DriverStatus.online),
        AdminDriver('m5', 'Cícero Matos', 'Fiat Argo · Cinza', 'PNA7F12', 4.79, 1488, DriverStatus.onTrip),
        AdminDriver('m6', 'José Wellington', 'VW Gol · Prata', 'OSD3H56', 4.84, 2210, DriverStatus.online),
        AdminDriver('m7', 'Luana Farias', 'Honda Biz · Azul', 'SAM1J90', 4.93, 640, DriverStatus.online),
        AdminDriver('m8', 'Francisco Neto', 'Chevrolet Spin · Branca', 'PMQ8K34', 4.86, 1730, DriverStatus.offline),
        AdminDriver('m9', 'Rita Paiva', 'Renault Kwid · Laranja', 'RHT6L21', 4.90, 410, DriverStatus.offline),
        AdminDriver('m10', 'Gabriel Teixeira', 'Fiat Mobi · Branco', 'SBC2M77', 0, 0, DriverStatus.review, since: 'hoje'),
        AdminDriver('m11', 'Aline Barros', 'Yamaha Factor · Preta', 'SBD4N08', 0, 0, DriverStatus.review, since: 'ontem'),
        AdminDriver('m12', 'Edilson Rocha', 'VW Voyage · Prata', 'OSE9P45', 4.21, 802, DriverStatus.blocked),
      ];

  static List<AdminPassenger> passengers() => [
        for (final (i, name) in passengerNames.indexed)
          AdminPassenger(
            name,
            '(88) 9${(9812 + i * 137) % 9000 + 1000}-${(4417 + i * 911) % 9000 + 1000}',
            i == 0 ? Fixtures.userTrips : 12 + (i * 37) % 160,
            [4.89, 4.95, 4.81, 4.98, 4.90, 4.76, 4.93, 4.70, 4.88, 4.85, 4.97, 4.66][i],
            blocked: i == 11,
          ),
      ];

  static List<AdminRide> rides(DateTime now) {
    final places = [...Fixtures.places, Fixtures.home, Fixtures.work];
    final driverNames = drivers().where((d) => d.trips > 0 && d.status != DriverStatus.blocked && d.id != 'm1').map((d) => d.name).toList();
    final list = <AdminRide>[];
    for (var i = 0; i < 28; i++) {
      final from = places[(i * 3) % 8];
      var to = places[(i * 5 + 3) % places.length];
      if (to.id == from.id) to = places[(i + 1) % places.length];
      final ride = Fixtures.rideTypes[[0, 0, 1, 0, 2, 1, 0, 3, 0, 4][i % 10]];
      final status = i >= 26
          ? RideStatus.live
          : i % 9 == 4
              ? RideStatus.cancelled
              : RideStatus.done;
      list.add(AdminRide(
        id: 'Z${(4810 + i).toString()}',
        time: now.subtract(Duration(minutes: (27 - i) * 23 + 4)),
        passenger: passengerNames[(i * 7 + 1) % passengerNames.length],
        driver: driverNames[(i * 5) % driverNames.length],
        from: from,
        to: to,
        rideName: ride.name,
        fare: ride.priceFor(Geo.roadDistanceKm(from.point, to.point)),
        payment: PaymentMethod.values[[0, 0, 1, 0, 2][i % 5]],
        status: status,
        rating: status == RideStatus.done ? [5, 5, 4, 5, 5, 3, 5][i % 7] : null,
      ));
    }
    return list.reversed.toList();
  }

  static List<Ticket> tickets(DateTime now) {
    DateTime ago(int m) => now.subtract(Duration(minutes: m));
    return [
      Ticket('T-1042', 'Cobrança duplicada no Pix', 'Ana Beatriz', 'Passageira', 'Alta', [
        TicketMessage('Oi, paguei a corrida da Rodoviária e apareceram duas cobranças no meu Pix.', fromTeam: false, time: ago(18)),
      ]),
      Ticket('T-1041', 'Esqueci minha bolsa no carro', 'Juliana Freitas', 'Passageira', 'Alta', [
        TicketMessage('Esqueci uma bolsa preta no carro da corrida até o IFCE, como recupero?', fromTeam: false, time: ago(42)),
        TicketMessage('Oi, Juliana! Já avisamos o motorista Cícero. Ele vai deixar na Praça da Matriz às 18h.', fromTeam: true, time: ago(35)),
      ]),
      Ticket('T-1040', 'App não atualiza minha CNH', 'Gabriel Teixeira', 'Motorista', 'Média', [
        TicketMessage('Enviei a foto da CNH três vezes e continua em análise.', fromTeam: false, time: ago(75)),
      ]),
      Ticket('T-1039', 'Passageiro não apareceu', 'José Wellington', 'Motorista', 'Baixa', [
        TicketMessage('Esperei 8 minutos no Mercado Público e o passageiro não veio. Recebo a taxa de espera?', fromTeam: false, time: ago(130)),
      ]),
      Ticket('T-1038', 'Elogio ao motorista', 'Maria Sousa', 'Passageira', 'Baixa', [
        TicketMessage('A Francisca foi super atenciosa na viagem para a Praia da Baleia!', fromTeam: false, time: ago(300)),
        TicketMessage('Que bom! Repassamos o elogio para ela. Obrigado, Maria!', fromTeam: true, time: ago(280)),
      ], resolved: true),
    ];
  }

  static List<AdminEvent> events(DateTime now) => [
        AdminEvent(now.subtract(const Duration(minutes: 2)), 'ride.completed', 'Corrida Z4836 concluída · R\$ 9,90 no Pix'),
        AdminEvent(now.subtract(const Duration(minutes: 4)), 'driver.online', 'Luana Farias ficou online'),
        AdminEvent(now.subtract(const Duration(minutes: 7)), 'payment.pix', 'Pix confirmado em 1,2 s · Z4835'),
        AdminEvent(now.subtract(const Duration(minutes: 11)), 'support.ticket', 'Novo chamado T-1042 (prioridade alta)'),
        AdminEvent(now.subtract(const Duration(minutes: 16)), 'driver.signup', 'Gabriel Teixeira enviou documentos'),
      ];
}
