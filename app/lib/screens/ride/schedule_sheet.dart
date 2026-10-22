import 'package:flutter/cupertino.dart';

import '../../core/formatters.dart';
import '../../core/ride_store.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

/// Pick "Agora" or a later pickup time; the label shows on the "Para onde?" chip.
class ScheduleSheet extends StatefulWidget {
  const ScheduleSheet({super.key});

  @override
  State<ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<ScheduleSheet> {
  late bool _later;
  late DateTime _time;
  late final List<DateTime> _slots;

  @override
  void initState() {
    super.initState();
    final store = StoreScope.read(context);
    final now = DateTime.now();
    final firstSlot = DateTime.fromMillisecondsSinceEpoch(((now.millisecondsSinceEpoch + 30 * 60000) ~/ 900000 + 1) * 900000);
    _slots = [for (var i = 0; i < 12; i++) firstSlot.add(Duration(minutes: 15 * i))];
    _later = store.scheduleLabel != 'Agora';
    _time = _slots.firstWhere((d) => BR.time(d) == store.scheduleLabel, orElse: () => _slots[1]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Grabber(),
          const SizedBox(height: 16),
          const Text('Quando você quer ir?', style: ZText.title),
          const SizedBox(height: 16),
          CupertinoSlidingSegmentedControl<bool>(
            key: const ValueKey('schedulePicker'),
            groupValue: _later,
            onValueChanged: (v) => setState(() => _later = v ?? false),
            children: const {
              false: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Agora', style: TextStyle(fontWeight: FontWeight.w600))),
              true: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Agendar', style: TextStyle(fontWeight: FontWeight.w600))),
            },
          ),
          const SizedBox(height: 16),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: _later ? _times() : const Text('Um motorista é chamado assim que você confirmar.', style: ZText.foot),
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            _later ? 'Agendar para ${BR.time(_time)}' : 'Ir agora',
            key: const ValueKey('scheduleDone'),
            onTap: () {
              StoreScope.read(context).setSchedule(_later ? BR.time(_time) : 'Agora');
              Navigator.of(context).pop();
            },
          ),
        ]),
      ),
    );
  }

  Widget _times() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionLabel('Hoje, horário de embarque'),
      const SizedBox(height: 10),
      SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _slots.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final slot = _slots[i];
            final on = slot == _time;
            return Pressable(
              onTap: () => setState(() => _time = slot),
              scale: 0.94,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on ? ZTheme.ink : ZTheme.card,
                  border: Border.all(color: on ? ZTheme.ink : ZTheme.hairline),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(BR.time(slot), style: TextStyle(fontWeight: FontWeight.w600, color: on ? ZTheme.onInk : ZTheme.ink, fontFeatures: ZText.tabular)),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      const Text('O motorista espera até 5 min sem custo.', style: ZText.foot),
    ]);
  }
}
