import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'clock_display.dart';
import 'app_strings.dart';
import 'face_flip_detector.dart';
import 'support_dialog.dart';

typedef AccelerometerStreamFactory = Stream<AccelerometerEvent> Function();

class CounterPage extends StatefulWidget {
  const CounterPage({
    super.key,
    required this.useCupertino,
    required this.enableFlipReset,
    this.showSupportLinks = false,
    this.accelerometerStreamFactory,
    this.now = DateTime.now,
  });

  final bool useCupertino;
  final bool enableFlipReset;
  final bool showSupportLinks;
  final AccelerometerStreamFactory? accelerometerStreamFactory;
  final DateTime Function() now;

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> with WidgetsBindingObserver {
  final _flipDetector = FaceFlipDetector();
  StreamSubscription<AccelerometerEvent>? _subscription;
  int _sensorGeneration = 0;
  int _count = 0;
  bool _sensorUnavailable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      _startSensors();
    }
  }

  void _startSensors() {
    if (!widget.enableFlipReset || _subscription != null) return;
    final generation = ++_sensorGeneration;
    try {
      final stream =
          widget.accelerometerStreamFactory?.call() ??
          accelerometerEventStream(
            samplingPeriod: const Duration(milliseconds: 50),
          );
      _subscription = stream.listen(
        (event) {
          if (!mounted || generation != _sensorGeneration) return;
          if (_sensorUnavailable) setState(() => _sensorUnavailable = false);
          if (_flipDetector.addSample(
            x: event.x,
            y: event.y,
            z: event.z,
            timestamp: Duration(
              microseconds: event.timestamp.microsecondsSinceEpoch,
            ),
          )) {
            _resetCount();
          }
        },
        onError: (Object error) => _onSensorError(generation),
        onDone: () => _onSensorError(generation),
        cancelOnError: true,
      );
    } catch (_) {
      _onSensorError(generation);
    }
  }

  void _onSensorError(int generation) {
    if (!mounted || generation != _sensorGeneration) return;
    _stopSensors();
    setState(() => _sensorUnavailable = true);
  }

  void _stopSensors() {
    _sensorGeneration++;
    final subscription = _subscription;
    _subscription = null;
    if (subscription != null) unawaited(subscription.cancel());
    _flipDetector.reset();
  }

  void _resetCount() {
    _flipDetector.reset();
    setState(() => _count = 0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startSensors();
    } else {
      _stopSensors();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopSensors();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final counterContent = LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 400;
        final veryShort = constraints.maxHeight < 300;
        final inset = veryShort
            ? 8.0
            : compact
            ? 12.0
            : 24.0;
        final gap = compact ? 12.0 : 20.0;
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(inset),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _panel(
                        context,
                        inset: inset,
                        child: ClockDisplay(now: widget.now),
                      ),
                      SizedBox(height: gap),
                      _panel(
                        context,
                        inset: inset,
                        child: _counter(
                          context,
                          fontSize: veryShort
                              ? 48
                              : compact
                              ? 64
                              : 96,
                          gap: compact ? 12 : 24,
                        ),
                      ),
                      if (_sensorUnavailable) ...[
                        SizedBox(height: gap),
                        Text(
                          AppStrings.of(context).sensorUnavailable,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.useCupertino
                                ? CupertinoColors.secondaryLabel.resolveFrom(
                                    context,
                                  )
                                : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    final content = SafeArea(
      child: Column(
        children: [
          if (widget.showSupportLinks)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: SupportButton(useCupertino: widget.useCupertino),
              ),
            ),
          Expanded(child: counterContent),
        ],
      ),
    );

    if (widget.useCupertino) {
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        child: content,
      );
    }
    return Scaffold(body: content);
  }

  Widget _panel(
    BuildContext context, {
    required Widget child,
    required double inset,
  }) {
    final padding = Padding(padding: EdgeInsets.all(inset), child: child);
    if (widget.useCupertino) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(
            context,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: padding,
      );
    }
    return Card.filled(margin: EdgeInsets.zero, child: padding);
  }

  Widget _counter(
    BuildContext context, {
    required double fontSize,
    required double gap,
  }) {
    void increment() => setState(() => _count++);
    final strings = AppStrings.of(context);
    final number = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        '$_count',
        key: const ValueKey('counter-value'),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
          color: widget.useCupertino
              ? CupertinoTheme.of(context).primaryColor
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          label: strings.counter(_count),
          hint: strings.incrementHint,
          button: true,
          onTap: increment,
          liveRegion: true,
          excludeSemantics: true,
          child: widget.useCupertino
              ? CupertinoButton(
                  key: const ValueKey('counter-button'),
                  padding: EdgeInsets.zero,
                  onPressed: increment,
                  child: number,
                )
              : InkWell(
                  key: const ValueKey('counter-button'),
                  borderRadius: BorderRadius.circular(16),
                  onTap: increment,
                  child: number,
                ),
        ),
        SizedBox(height: gap),
        if (widget.useCupertino) ...[
          CupertinoButton(onPressed: _resetCount, child: Text(strings.reset)),
        ] else ...[
          OutlinedButton.icon(
            onPressed: _resetCount,
            icon: const Icon(Icons.refresh),
            label: Text(strings.reset),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ],
    );
  }
}
