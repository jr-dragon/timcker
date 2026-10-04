import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timcker/app_strings.dart';

void main() {
  test(
    'resolves supported languages, Chinese scripts and regional variants',
    () {
      final cases = {
        'zh-TW': const Locale('zh', 'TW'),
        'zh-HK': const Locale('zh', 'TW'),
        'zh-MO': const Locale('zh', 'TW'),
        'zh-Hant': const Locale('zh', 'TW'),
        'zh-Hant-CN': const Locale('zh', 'TW'),
        'ZH_hant_hk': const Locale('zh', 'TW'),
        'zh-CN': const Locale('zh', 'CN'),
        'zh-SG': const Locale('zh', 'CN'),
        'zh-Hans-TW': const Locale('zh', 'CN'),
        'zh': const Locale('zh', 'CN'),
        'en-US': const Locale('en'),
        'en-GB': const Locale('en'),
        'ja-JP': const Locale('ja'),
        'de-DE': const Locale('en'),
        'fr': const Locale('en'),
        '': const Locale('en'),
      };
      for (final entry in cases.entries) {
        expect(resolveLanguage(entry.key), entry.value, reason: entry.key);
      }
      expect(resolveLanguage(null), const Locale('en'));
    },
  );

  test('all translations contain controls, hints, errors and semantics', () {
    final resetLabels = ['Reset', '歸零', '归零', 'リセット'];
    for (var i = 0; i < supportedLocales.length; i++) {
      final strings = AppStrings(supportedLocales[i]);
      expect(strings.reset, resetLabels[i]);
      expect(strings.counter(7), contains('7'));
      expect(strings.incrementHint, contains('1'));
      expect(strings.clock(DateTime(2026, 10, 4, 13, 22, 33)), contains('13'));
      expect(strings.sensorUnavailable, isNotEmpty);
      expect(strings.supportAndPrivacy, isNotEmpty);
      expect(strings.support, isNotEmpty);
      expect(strings.privacyPolicy, isNotEmpty);
      expect(strings.close, isNotEmpty);
      expect(strings.urlOpenFailed, isNotEmpty);
    }
    expect(const AppStrings(Locale('de')).reset, 'Reset');
  });
}
