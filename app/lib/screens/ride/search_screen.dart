import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/fixtures.dart';
import '../../core/formatters.dart';
import '../../core/models.dart';
import '../../core/ride_store.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../home/home_panel.dart';

/// Full-screen destination search with accent-insensitive filtering over the fixture places.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<Place> get _results {
    final key = BR.searchKey(_query.text);
    if (key.isEmpty) return Fixtures.suggestions;
    return Fixtures.places.where((p) => BR.searchKey(p.name).contains(key) || BR.searchKey(p.address).contains(key)).toList();
  }

  void _choose(Place place) {
    final store = StoreScope.read(context);
    Navigator.of(context).pop();
    store.choose(place);
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final empty = _query.text.trim().isEmpty;
    return Scaffold(
      backgroundColor: ZTheme.surface,
      body: SafeArea(
        child: Column(children: [
          _header(),
          const Divider(),
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              children: [
                if (empty) ...[
                  const SizedBox(height: 6),
                  _row(Fixtures.home, CupertinoIcons.house_fill),
                  const Divider(indent: 52),
                  _row(Fixtures.work, CupertinoIcons.briefcase_fill),
                  for (final p in Fixtures.recents) ...[const Divider(indent: 52), _row(p, CupertinoIcons.clock)],
                ],
                Padding(
                  padding: const EdgeInsets.only(top: 18, bottom: 4),
                  child: SectionLabel(empty ? 'Sugestões em Itapipoca' : 'Resultados'),
                ),
                if (results.isEmpty) _emptyState() else for (final p in results) _row(p),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 14, 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Pressable(
          key: const ValueKey('closeSearch'),
          onTap: () => Navigator.of(context).pop(),
          semanticLabel: 'Fechar busca',
          child: const SizedBox(width: 40, height: 44, child: Icon(CupertinoIcons.xmark, size: 20)),
        ),
        const SizedBox(width: 6),
        Column(children: [
          const SizedBox(height: 18),
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: ZTheme.ink, shape: BoxShape.circle)),
          Container(width: 2, height: 36, color: ZTheme.tertiary),
          Container(width: 8, height: 8, color: ZTheme.ink),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(children: [
            _field(const Text(Fixtures.pickupName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ZTheme.accent))),
            const SizedBox(height: 8),
            _field(Row(children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('searchField'),
                  controller: _query,
                  autofocus: true,
                  autocorrect: false,
                  cursorColor: ZTheme.accent,
                  textInputAction: TextInputAction.search,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: const InputDecoration.collapsed(hintText: 'Para onde?', hintStyle: TextStyle(color: ZTheme.secondary)),
                ),
              ),
              if (_query.text.isNotEmpty)
                Pressable(
                  onTap: () => setState(_query.clear),
                  semanticLabel: 'Limpar',
                  child: const Icon(CupertinoIcons.xmark_circle_fill, size: 18, color: ZTheme.secondary),
                ),
            ])),
          ]),
        ),
      ]),
    );
  }

  Widget _field(Widget child) => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(color: ZTheme.fill2, borderRadius: BorderRadius.circular(10)),
        child: child,
      );

  Widget _row(Place place, [IconData? icon]) =>
      PlaceRow(key: ValueKey('place_${place.id}'), place: place, icon: icon, onTap: () => _choose(place));

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(children: [
        const Icon(CupertinoIcons.map_pin_slash, size: 34, color: ZTheme.secondary),
        const SizedBox(height: 10),
        Text('Nada encontrado para “${_query.text.trim()}”', textAlign: TextAlign.center, style: ZText.headline),
        const SizedBox(height: 6),
        const Text('Tente “Mercado”, “Baleia” ou “Rodoviária”.', style: ZText.sub),
        const SizedBox(height: 14),
        SizedBox(width: 180, child: SecondaryButton('Limpar busca', onTap: () => setState(_query.clear))),
      ]),
    );
  }
}
