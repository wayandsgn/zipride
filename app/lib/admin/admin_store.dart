import 'package:flutter/widgets.dart';

import '../core/driver_store.dart';
import '../core/fixtures.dart';
import '../core/models.dart';
import '../core/ride_store.dart';
import 'admin_data.dart';

enum AdminPage {
  overview('Visão geral'),
  map('Mapa ao vivo'),
  rides('Corridas'),
  drivers('Motoristas'),
  passengers('Passageiros'),
  support('Suporte'),
  pricing('Preços'),
  system('Sistema');

  const AdminPage(this.label);
  final String label;
}

/// State of the admin panel. It also watches the customer and driver apps when they
/// run on the same page, so their rides show up here live.
class AdminStore extends ChangeNotifier {
  AdminStore({this.rider, this.driver}) {
    rider?.addListener(notifyListeners);
    driver?.addListener(notifyListeners);
  }

  final RideStore? rider;
  final DriverStore? driver;

  final DateTime opened = DateTime.now();
  AdminPage page = AdminPage.overview;
  late final List<AdminRide> _rides = AdminData.rides(opened);
  late final List<AdminDriver> drivers = AdminData.drivers();
  late final List<AdminPassenger> passengers = AdminData.passengers();
  late final List<Ticket> tickets = AdminData.tickets(opened);
  late final List<AdminEvent> events = AdminData.events(opened);
  final Map<String, bool> flags = {
    'Moto disponível': true,
    'Agendamento de corridas': true,
    'Gorjeta no app': true,
    'Tarifa dinâmica automática': false,
    'Modo manutenção': false,
  };

  void go(AdminPage value) {
    page = value;
    notifyListeners();
  }

  void log(String kind, String message) {
    events.insert(0, AdminEvent(DateTime.now(), kind, message));
    if (events.length > 60) events.removeLast();
    notifyListeners();
  }

  /// Fixture rides plus everything that happened in the linked apps.
  List<AdminRide> get rides {
    final extra = <AdminRide>[];
    final d = driver;
    final r = d?.request;
    if (d != null && r != null && d.phase.index >= DriverPhase.toPickup.index) {
      extra.add(AdminRide(
        id: 'Z4840',
        time: DateTime.now(),
        passenger: r.passenger,
        driver: 'Marcos Vieira',
        from: r.pickup,
        to: r.destination,
        rideName: r.rideName,
        fare: r.fare,
        payment: r.payment,
        status: RideStatus.live,
      ));
    }
    for (final t in (rider?.trips ?? const <Trip>[]).where((t) => t.id.startsWith('new-'))) {
      extra.add(AdminRide(
        id: 'Z48${40 + int.parse(t.id.substring(4))}',
        time: t.date,
        passenger: Fixtures.userName,
        driver: 'Marcos Vieira',
        from: Fixtures.place('praca'),
        to: t.destination,
        rideName: t.rideName,
        fare: t.total,
        payment: t.payment,
        status: RideStatus.done,
        rating: t.rating,
      ));
    }
    return [...extra, ..._rides];
  }

  /// Marcos follows the driver app when it is open.
  DriverStatus statusOf(AdminDriver d) {
    final app = driver;
    if (d.id != 'm1' || app == null) return d.status;
    return switch (app.phase) {
      DriverPhase.offline => DriverStatus.offline,
      DriverPhase.searching || DriverPhase.request || DriverPhase.finished => DriverStatus.online,
      _ => DriverStatus.onTrip,
    };
  }

  int get ridesToday => rides.where((r) => r.status != RideStatus.cancelled).length + 61;
  double get revenueToday => rides.where((r) => r.status == RideStatus.done).fold(0.0, (s, r) => s + r.fare) + 912.40;
  int get onlineDrivers => drivers.where((d) => statusOf(d) == DriverStatus.online || statusOf(d) == DriverStatus.onTrip).length + 14;
  int get openTickets => tickets.where((t) => !t.resolved).length;
  int get pendingDrivers => drivers.where((d) => d.status == DriverStatus.review).length;

  void approve(AdminDriver d) {
    d.status = DriverStatus.offline;
    log('driver.approved', '${d.name} aprovado(a) para dirigir');
  }

  void toggleBlock(AdminDriver d) {
    d.status = d.status == DriverStatus.blocked ? DriverStatus.offline : DriverStatus.blocked;
    log(d.status == DriverStatus.blocked ? 'driver.blocked' : 'driver.unblocked', '${d.name} ${d.status == DriverStatus.blocked ? 'bloqueado(a)' : 'desbloqueado(a)'}');
  }

  void toggleBlockPassenger(AdminPassenger p) {
    p.blocked = !p.blocked;
    log(p.blocked ? 'rider.blocked' : 'rider.unblocked', '${p.name} ${p.blocked ? 'bloqueado(a)' : 'desbloqueado(a)'}');
  }

  void refund(AdminRide ride) {
    ride.status = RideStatus.refunded;
    log('payment.refund', 'Reembolso da corrida ${ride.id} para ${ride.passenger}');
  }

  void reply(Ticket t, String text) {
    if (text.trim().isEmpty) return;
    t.messages.add(TicketMessage(text.trim(), fromTeam: true, time: DateTime.now()));
    log('support.reply', 'Resposta enviada no chamado ${t.id}');
  }

  void resolve(Ticket t) {
    t.resolved = !t.resolved;
    log('support.status', 'Chamado ${t.id} ${t.resolved ? 'resolvido' : 'reaberto'}');
  }

  void setFlag(String name, bool value) {
    flags[name] = value;
    log('flag.changed', '$name ${value ? 'ligado' : 'desligado'}');
  }

  @override
  void dispose() {
    rider?.removeListener(notifyListeners);
    driver?.removeListener(notifyListeners);
    super.dispose();
  }
}

class AdminScope extends InheritedNotifier<AdminStore> {
  const AdminScope({super.key, required AdminStore store, required super.child}) : super(notifier: store);

  static AdminStore of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AdminScope>()!.notifier!;
  static AdminStore read(BuildContext context) => context.getInheritedWidgetOfExactType<AdminScope>()!.notifier!;
}
