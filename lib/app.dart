import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_strings.dart';
import 'counter_page.dart';
import 'device_language.dart';

class TimckerApp extends StatelessWidget {
  const TimckerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final webLanguage = browserLanguage();
    final locale = webLanguage == null ? null : resolveLanguage(webLanguage);
    Locale resolveLocales(List<Locale>? locales, Iterable<Locale> supported) =>
        resolveLanguage(locales?.firstOrNull?.toLanguageTag());
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final isNativeMobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
    final page = CounterPage(
      useCupertino: isIOS,
      enableFlipReset: isNativeMobile,
      showSupportLinks: isNativeMobile,
    );

    if (isIOS) {
      return CupertinoApp(
        title: 'Timcker',
        locale: locale,
        supportedLocales: supportedLocales,
        localizationsDelegates: GlobalCupertinoLocalizations.delegates,
        localeListResolutionCallback: resolveLocales,
        debugShowCheckedModeBanner: false,
        theme: const CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue,
        ),
        home: page,
      );
    }

    return MaterialApp(
      title: 'Timcker',
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      localeListResolutionCallback: resolveLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006B60)),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006B60),
          brightness: Brightness.dark,
        ),
      ),
      home: page,
    );
  }
}
