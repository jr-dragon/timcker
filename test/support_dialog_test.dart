import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timcker/app_strings.dart';
import 'package:timcker/support_dialog.dart';

Widget app({
  required bool cupertino,
  required OpenUrl openUrl,
  Locale locale = const Locale('en'),
  double textScale = 1,
}) {
  Widget scaleText(BuildContext context, Widget? child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  );
  final button = SupportButton(useCupertino: cupertino, openUrl: openUrl);
  return cupertino
      ? CupertinoApp(
          theme: const CupertinoThemeData(brightness: Brightness.dark),
          locale: locale,
          supportedLocales: supportedLocales,
          localizationsDelegates: GlobalCupertinoLocalizations.delegates,
          builder: scaleText,
          home: CupertinoPageScaffold(child: button),
        )
      : MaterialApp(
          theme: ThemeData.dark(useMaterial3: true),
          locale: locale,
          supportedLocales: supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          builder: scaleText,
          home: Scaffold(body: button),
        );
}

void main() {
  for (final cupertino in [false, true]) {
    for (final locale in supportedLocales) {
      testWidgets('links open and modal closes: $cupertino $locale', (
        tester,
      ) async {
        final opened = <Uri>[];
        final strings = AppStrings(locale);
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            app(
              cupertino: cupertino,
              locale: locale,
              openUrl: (url) async {
                opened.add(url);
                return true;
              },
            ),
          );
          expect(
            find.bySemanticsLabel(strings.supportAndPrivacy),
            findsOneWidget,
          );
          await tester.tap(find.byKey(const ValueKey('support-button')));
          await tester.pumpAndSettle();
          expect(
            find.byType(cupertino ? CupertinoAlertDialog : AlertDialog),
            findsOneWidget,
          );
          expect(find.text(strings.supportAndPrivacy), findsOneWidget);
          expect(
            find.text('https://timcker.chivincent.net/support'),
            findsOneWidget,
          );
          expect(
            find.text('https://timcker.chivincent.net/privacy'),
            findsOneWidget,
          );
          await tester.tap(find.text(strings.support));
          await tester.pumpAndSettle();
          await tester.tap(find.text(strings.privacyPolicy));
          await tester.pumpAndSettle();
          expect(opened.map((url) => url.toString()), [
            'https://timcker.chivincent.net/support',
            'https://timcker.chivincent.net/privacy',
          ]);
          await tester.tap(find.text(strings.close));
          await tester.pumpAndSettle();
          expect(find.byType(CupertinoAlertDialog), findsNothing);
          expect(find.byType(AlertDialog), findsNothing);
        } finally {
          semantics.dispose();
        }
      });
    }

    for (final size in [const Size(320, 568), const Size(568, 320)]) {
      testWidgets('modal fits large text and dark mode: $cupertino $size', (
        tester,
      ) async {
        tester.view
          ..physicalSize = size
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          app(
            cupertino: cupertino,
            locale: const Locale('ja'),
            textScale: 2,
            openUrl: (_) async => true,
          ),
        );
        await tester.tap(find.byKey(const ValueKey('support-button')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('プライバシーポリシー'));
        await tester.tap(find.text('プライバシーポリシー'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('閉じる'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('failed launch can be retried: $cupertino', (tester) async {
      var attempts = 0;
      await tester.pumpWidget(
        app(
          cupertino: cupertino,
          openUrl: (_) async {
            attempts++;
            if (attempts == 1) throw StateError('Browser unavailable');
            return attempts > 2;
          },
        ),
      );
      await tester.tap(find.byKey(const ValueKey('support-button')));
      await tester.pumpAndSettle();
      for (var attempt = 1; attempt <= 3; attempt++) {
        await tester.tap(find.text('Support'));
        await tester.pumpAndSettle();
        expect(
          find.text('Unable to open the link. Please try again.'),
          attempt < 3 ? findsOneWidget : findsNothing,
        );
      }
      expect(attempts, 3);
      expect(tester.takeException(), isNull);
    });

    testWidgets('close while a URL is opening: $cupertino', (tester) async {
      final result = Completer<bool>();
      var attempts = 0;
      await tester.pumpWidget(
        app(
          cupertino: cupertino,
          openUrl: (_) {
            attempts++;
            return result.future;
          },
        ),
      );
      await tester.tap(find.byKey(const ValueKey('support-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Support'));
      await tester.pump();
      await tester.tap(find.text('Privacy policy'));
      expect(attempts, 1);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      result.complete(false);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}
