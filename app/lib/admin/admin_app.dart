import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/brand.dart';
import 'admin_store.dart';
import 'pages/map_page.dart';
import 'pages/overview_page.dart';
import 'pages/people_pages.dart';
import 'pages/pricing_page.dart';
import 'pages/rides_page.dart';
import 'pages/support_page.dart';
import 'pages/system_page.dart';

/// ITAX Admin: the panel for the operations, support and developer team.
class AdminApp extends StatelessWidget {
  const AdminApp({super.key, required this.store});

  final AdminStore store;

  @override
  Widget build(BuildContext context) {
    return AdminScope(
      store: store,
      child: MaterialApp(
        title: 'ITAX Admin',
        debugShowCheckedModeBanner: false,
        theme: ZTheme.data(),
        locale: ZTheme.locale,
        supportedLocales: ZTheme.locales,
        localizationsDelegates: ZTheme.delegates,
        home: const _AdminShell(),
      ),
    );
  }
}

class _AdminShell extends StatelessWidget {
  const _AdminShell();

  static const _icons = {
    AdminPage.overview: CupertinoIcons.square_grid_2x2_fill,
    AdminPage.map: CupertinoIcons.map_fill,
    AdminPage.rides: CupertinoIcons.car_fill,
    AdminPage.drivers: CupertinoIcons.person_crop_rectangle_fill,
    AdminPage.passengers: CupertinoIcons.person_2_fill,
    AdminPage.support: CupertinoIcons.chat_bubble_2_fill,
    AdminPage.pricing: CupertinoIcons.tag_fill,
    AdminPage.system: CupertinoIcons.gear_solid,
  };

  Widget _page(AdminPage page) => switch (page) {
        AdminPage.overview => const OverviewPage(),
        AdminPage.map => const MapPage(),
        AdminPage.rides => const RidesPage(),
        AdminPage.drivers => const DriversPage(),
        AdminPage.passengers => const PassengersPage(),
        AdminPage.support => const SupportPage(),
        AdminPage.pricing => const PricingPage(),
        AdminPage.system => const SystemPage(),
      };

  @override
  Widget build(BuildContext context) {
    final store = AdminScope.of(context);
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 900;
      final content = ColoredBox(
        color: ZTheme.surface,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: KeyedSubtree(key: ValueKey(store.page), child: _page(store.page)),
        ),
      );
      if (wide) {
        return Scaffold(
          body: Row(children: [
            SizedBox(width: 248, child: _Sidebar(icons: _icons, onPicked: null)),
            const VerticalDivider(width: 1, thickness: 1, color: ZTheme.hairline),
            Expanded(child: content),
          ]),
        );
      }
      return Scaffold(
        appBar: AppBar(title: Text(store.page.label), backgroundColor: ZTheme.surface),
        drawer: Drawer(
          backgroundColor: ZTheme.surface,
          child: Builder(builder: (context) => _Sidebar(icons: _icons, onPicked: () => Navigator.of(context).pop())),
        ),
        body: content,
      );
    });
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.icons, required this.onPicked});
  final Map<AdminPage, IconData> icons;
  final VoidCallback? onPicked;

  @override
  Widget build(BuildContext context) {
    final store = AdminScope.of(context);
    int? badge(AdminPage p) => switch (p) {
          AdminPage.support => store.openTickets,
          AdminPage.drivers => store.pendingDrivers,
          _ => null,
        };
    return ColoredBox(
      color: ZTheme.fill,
      child: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Row(children: [
              ItaxWordmark(size: 26),
              SizedBox(width: 8),
              Text('Admin', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ZTheme.secondary)),
            ]),
          ),
          for (final p in AdminPage.values)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
              child: Material(
                color: store.page == p ? ZTheme.fill2 : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  key: ValueKey('nav_${p.name}'),
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    store.go(p);
                    onPicked?.call();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(children: [
                      Icon(icons[p], size: 18, color: store.page == p ? ZTheme.accent : ZTheme.secondary),
                      const SizedBox(width: 12),
                      Expanded(child: Text(p.label, style: TextStyle(fontSize: 15, fontWeight: store.page == p ? FontWeight.w700 : FontWeight.w500))),
                      if ((badge(p) ?? 0) > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: const ShapeDecoration(color: ZTheme.danger, shape: StadiumBorder()),
                          child: Text('${badge(p)}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                    ]),
                  ),
                ),
              ),
            ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(children: [
              CircleAvatar(radius: 17, backgroundColor: ZTheme.accent, child: Text('EI', style: TextStyle(color: ZTheme.onInk, fontSize: 12, fontWeight: FontWeight.w700))),
              SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Equipe ITAX', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('Operações, suporte e dev', style: ZText.caption),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
