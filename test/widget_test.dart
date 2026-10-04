import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:timcker/app.dart';
import 'package:timcker/app_strings.dart';
import 'package:timcker/device_language.dart';
import 'package:timcker/clock_display.dart';
import 'package:timcker/counter_page.dart';

void main() {
  final instant = DateTime(2026, 10, 4, 9, 8, 7, 6);

  Widget page({
    bool cupertino = false,
    AccelerometerStreamFactory? sensors,
    DateTime Function()? now,
    Brightness brightness = Brightness.light,
    double textScale = 1,
    Locale locale = const Locale('zh', 'TW'),
    bool showSupportLinks = false,
    EdgeInsets safePadding = EdgeInsets.zero,
  }) {
    final content = MediaQuery(
      data: MediaQueryData(
        textScaler: TextScaler.linear(textScale),
        padding: safePadding,
      ),
      child: CounterPage(
        useCupertino: cupertino,
        enableFlipReset: sensors != null,
        showSupportLinks: showSupportLinks,
        accelerometerStreamFactory: sensors,
        now: now ?? () => instant,
      ),
    );
    return cupertino
        ? CupertinoApp(
            theme: CupertinoThemeData(brightness: brightness),
            locale: locale,
            supportedLocales: supportedLocales,
            localizationsDelegates: GlobalCupertinoLocalizations.delegates,
            home: content,
          )
        : MaterialApp(
            theme: ThemeData(brightness: brightness),
            locale: locale,
            supportedLocales: supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: content,
          );
  }

  String count(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const ValueKey('counter-value'))).data!;

  AccelerometerEvent event(int milliseconds, double z) => AccelerometerEvent(
    0,
    0,
    z,
    instant.add(Duration(milliseconds: milliseconds)),
  );

  Future<void> sample(
    WidgetTester tester,
    StreamController<AccelerometerEvent> controller,
    int milliseconds,
    double z,
  ) async {
    controller.add(event(milliseconds, z));
    await tester.pump();
  }

  test('clock pads hours, minutes, seconds and three millisecond digits', () {
    expect(formatClock(instant), '09:08:07.006');
    expect(formatClock(DateTime(2026, 10, 4)), '00:00:00.000');
    expect(formatClock(DateTime(2026, 10, 4, 23, 59, 59, 999)), '23:59:59.999');
  });

  for (final cupertino in [false, true]) {
    testWidgets('${cupertino ? 'Cupertino' : 'Material'} increment and reset', (
      tester,
    ) async {
      await tester.pumpWidget(page(cupertino: cupertino));
      expect(find.text('09:08:07.006'), findsOneWidget);
      expect(count(tester), '0');
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const ValueKey('counter-value')));
        await tester.pump();
      }
      expect(count(tester), '3');
      await tester.tap(find.text('歸零'));
      await tester.pump();
      expect(count(tester), '0');
      expect(find.text('09:08:07.006'), findsOneWidget);
      expect(
        find.byType(CupertinoButton),
        cupertino ? findsNWidgets(2) : findsNothing,
      );
      expect(find.byType(FilledButton), findsNothing);
      expect(find.text('Timcker'), findsNothing);
      expect(find.text('現在時間'), findsNothing);
      expect(find.text('計數器'), findsNothing);
      expect(find.text('增加 1'), findsNothing);
      expect(find.text('點按增加計數，隨時歸零重新開始。'), findsNothing);
      expect(find.textContaining('24 小時制'), findsNothing);
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(CupertinoNavigationBar), findsNothing);
    });

    for (final size in [
      const Size(568, 320),
      const Size(896, 414),
      const Size(926, 428),
      const Size(414, 896),
    ]) {
      testWidgets('all controls fit without scrolling $cupertino $size', (
        tester,
      ) async {
        tester.view
          ..physicalSize = size
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          page(
            cupertino: cupertino,
            showSupportLinks: true,
            safePadding: const EdgeInsets.fromLTRB(44, 0, 44, 21),
          ),
        );
        final viewport = tester.getRect(find.byType(SingleChildScrollView));
        final reset = cupertino
            ? find.widgetWithText(CupertinoButton, '歸零')
            : find.widgetWithText(OutlinedButton, '歸零');
        for (final control in [
          find.byKey(const ValueKey('clock-value')),
          find.byKey(const ValueKey('counter-button')),
          reset,
        ]) {
          final rect = tester.getRect(control);
          expect(rect.top, greaterThanOrEqualTo(viewport.top));
          expect(rect.bottom, lessThanOrEqualTo(viewport.bottom));
        }
        expect(
          tester
              .state<ScrollableState>(find.byType(Scrollable))
              .position
              .maxScrollExtent,
          0,
        );
        await tester.tap(find.byKey(const ValueKey('counter-value')));
        await tester.pump();
        expect(count(tester), '1');
        await tester.tap(reset);
        await tester.pump();
        expect(count(tester), '0');
        expect(tester.takeException(), isNull);
      });
    }

    for (final size in [const Size(320, 568), const Size(568, 320)]) {
      testWidgets('layout $cupertino $size with dark mode and large text', (
        tester,
      ) async {
        tester.view
          ..physicalSize = size
          ..devicePixelRatio = 1;
        addTearDown(() => tester.view.reset());
        await tester.pumpWidget(
          page(
            cupertino: cupertino,
            brightness: Brightness.dark,
            textScale: 2,
            showSupportLinks: true,
          ),
        );
        expect(tester.takeException(), isNull);
        final help = find.byKey(const ValueKey('support-button'));
        expect(tester.getCenter(help).dx, greaterThan(size.width / 2));
        expect(tester.getCenter(help).dy, lessThan(60));
        await tester.ensureVisible(find.byKey(const ValueKey('counter-value')));
        await tester.tap(find.byKey(const ValueKey('counter-value')));
        await tester.pump();
        expect(count(tester), '1');
        await tester.ensureVisible(find.text('歸零'));
        await tester.tap(find.text('歸零'));
        await tester.pump();
        expect(count(tester), '0');
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('app selects the platform design system', (tester) async {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await tester.pumpWidget(const TimckerApp());
      await tester.pump();
      final isCupertino = !kIsWeb && platform == TargetPlatform.iOS;
      expect(
        find.byType(CupertinoApp),
        isCupertino ? findsOneWidget : findsNothing,
      );
      expect(
        find.byType(MaterialApp),
        isCupertino ? findsNothing : findsOneWidget,
      );
      expect(
        tester.widget<CounterPage>(find.byType(CounterPage)).enableFlipReset,
        !kIsWeb,
      );
      expect(
        find.byKey(const ValueKey('support-button')),
        kIsWeb ? findsNothing : findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    }
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets(
    'clock follows current time and refreshes immediately on resume',
    (tester) async {
      var now = instant;
      await tester.pumpWidget(page(now: () => now));
      now = instant.add(const Duration(milliseconds: 123));
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.text('09:08:07.129'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      now = DateTime(2026, 10, 5);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('09:08:07.129'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.text('00:00:00.000'), findsOneWidget);
      expect(find.textContaining('2026 /'), findsNothing);
    },
  );

  testWidgets('complete flip resets once; manual reset clears pending flip', (
    tester,
  ) async {
    final controller = StreamController<AccelerometerEvent>.broadcast();
    addTearDown(controller.close);
    await tester.pumpWidget(page(sensors: () => controller.stream));
    await tester.tap(find.byKey(const ValueKey('counter-value')));
    await tester.pump();
    await sample(tester, controller, 0, -9.8);
    await sample(tester, controller, 300, -9.8);
    expect(count(tester), '1');
    await sample(tester, controller, 400, 9.8);
    await sample(tester, controller, 700, 9.8);
    expect(count(tester), '0');
    await tester.tap(find.byKey(const ValueKey('counter-value')));
    await tester.pump();
    await sample(tester, controller, 800, 9.8);
    await sample(tester, controller, 1100, 9.8);
    expect(count(tester), '1');
    await sample(tester, controller, 1200, -9.8);
    await sample(tester, controller, 1500, -9.8);
    await tester.tap(find.text('歸零'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('counter-value')));
    await tester.pump();
    await sample(tester, controller, 1600, 9.8);
    await sample(tester, controller, 1900, 9.8);
    expect(count(tester), '1');
    await tester.pumpWidget(const SizedBox.shrink());
    expect(controller.hasListener, isFalse);
  });

  testWidgets('background cancels sensors and clears an incomplete gesture', (
    tester,
  ) async {
    final controller = StreamController<AccelerometerEvent>.broadcast();
    addTearDown(controller.close);
    await tester.pumpWidget(page(sensors: () => controller.stream));
    await tester.tap(find.byKey(const ValueKey('counter-value')));
    await tester.pump();
    await sample(tester, controller, 0, -9.8);
    await sample(tester, controller, 300, -9.8);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(controller.hasListener, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(controller.hasListener, isTrue);
    await sample(tester, controller, 400, 9.8);
    await sample(tester, controller, 700, 9.8);
    expect(count(tester), '1');
    await sample(tester, controller, 800, -9.8);
    await sample(tester, controller, 1100, -9.8);
    await sample(tester, controller, 1200, 9.8);
    await sample(tester, controller, 1500, 9.8);
    expect(count(tester), '0');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('unavailable sensors preserve manual counting and reset', (
    tester,
  ) async {
    final controller = StreamController<AccelerometerEvent>.broadcast();
    addTearDown(controller.close);
    await tester.pumpWidget(page(sensors: () => controller.stream));
    controller.addError(StateError('No accelerometer'));
    await tester.pump();
    expect(find.text('無法使用動作感測器，請點按歸零。'), findsOneWidget);
    expect(controller.hasListener, isFalse);
    await tester.tap(find.byKey(const ValueKey('counter-value')));
    await tester.pump();
    expect(count(tester), '1');
    await tester.tap(find.text('歸零'));
    await tester.pump();
    expect(count(tester), '0');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final locale in supportedLocales) {
    for (final cupertino in [false, true]) {
      testWidgets('localized controls and semantics $locale $cupertino', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(page(locale: locale, cupertino: cupertino));
          await tester.pump();
          final strings = AppStrings(locale);
          expect(find.text(strings.reset), findsOneWidget);
          expect(find.bySemanticsLabel(strings.counter(0)), findsOneWidget);
          expect(
            tester
                .getSemantics(find.bySemanticsLabel(strings.counter(0)))
                .childrenCount,
            0,
            reason:
                'The reset control must not be nested in the counter button.',
          );
          expect(find.bySemanticsLabel(strings.clock(instant)), findsOneWidget);
          await tester.tap(find.byKey(const ValueKey('counter-value')));
          await tester.pump();
          expect(count(tester), '1');
          expect(find.bySemanticsLabel(strings.counter(1)), findsOneWidget);
          await tester.tap(find.text(strings.reset));
          await tester.pump();
          expect(count(tester), '0');
        } finally {
          semantics.dispose();
        }
      });
    }
  }

  testWidgets('detects primary device language and falls back to English', (
    tester,
  ) async {
    final dispatcher = tester.binding.platformDispatcher;
    addTearDown(dispatcher.clearLocalesTestValue);
    for (final deviceLocale in [
      const Locale('zh', 'TW'),
      const Locale('zh', 'CN'),
      const Locale('ja', 'JP'),
      const Locale('en', 'GB'),
      const Locale('fr', 'FR'),
    ]) {
      dispatcher.localesTestValue = [deviceLocale, const Locale('ja')];
      await tester.pumpWidget(const TimckerApp());
      await tester.pump();
      final detected = browserLanguage() ?? deviceLocale.toLanguageTag();
      final expected = resolveLanguage(detected);
      final context = tester.element(find.byType(CounterPage));
      expect(Localizations.localeOf(context), expected);
      expect(find.text(AppStrings(expected).reset), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
