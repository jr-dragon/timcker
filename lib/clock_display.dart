import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'app_strings.dart';

String formatClock(DateTime time) {
  String pad(int value, int width) => value.toString().padLeft(width, '0');
  return '${pad(time.hour, 2)}:${pad(time.minute, 2)}:'
      '${pad(time.second, 2)}.${pad(time.millisecond, 3)}';
}

class ClockDisplay extends StatefulWidget {
  const ClockDisplay({super.key, this.now = DateTime.now});

  final DateTime Function() now;

  @override
  State<ClockDisplay> createState() => _ClockDisplayState();
}

class _ClockDisplayState extends State<ClockDisplay>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final ValueNotifier<DateTime> _time;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _time = ValueNotifier(widget.now());
    _ticker = createTicker((_) => _time.value = widget.now());
    WidgetsBinding.instance.addObserver(this);
    if (WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      _ticker.start();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _time.value = widget.now();
      if (!_ticker.isActive) _ticker.start();
    } else {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _time,
      builder: (context, time, _) => Semantics(
        label: AppStrings.of(context).clock(time),
        excludeSemantics: true,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            formatClock(time),
            key: const ValueKey('clock-value'),
            maxLines: 1,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w500,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}
