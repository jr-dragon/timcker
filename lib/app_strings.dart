import 'package:flutter/widgets.dart';

const supportedLocales = [
  Locale('en'),
  Locale('zh', 'TW'),
  Locale('zh', 'CN'),
  Locale('ja'),
];

Locale resolveLanguage(String? languageTag) {
  final parts = (languageTag ?? '')
      .replaceAll('_', '-')
      .toLowerCase()
      .split('-');
  return switch (parts.first) {
    'ja' => const Locale('ja'),
    'zh' =>
      parts.contains('hant')
          ? const Locale('zh', 'TW')
          : parts.contains('hans')
          ? const Locale('zh', 'CN')
          : parts.any(['tw', 'hk', 'mo'].contains)
          ? const Locale('zh', 'TW')
          : const Locale('zh', 'CN'),
    _ => const Locale('en'),
  };
}

class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  static AppStrings of(BuildContext context) =>
      AppStrings(Localizations.localeOf(context));

  String get _language => locale.languageCode == 'zh'
      ? locale.countryCode == 'TW'
            ? 'zh-TW'
            : 'zh-CN'
      : locale.languageCode;

  String get reset => switch (_language) {
    'zh-TW' => '歸零',
    'zh-CN' => '归零',
    'ja' => 'リセット',
    _ => 'Reset',
  };

  String get supportAndPrivacy => switch (_language) {
    'zh-TW' => '支援與隱私權',
    'zh-CN' => '支持与隐私',
    'ja' => 'サポートとプライバシー',
    _ => 'Support and privacy',
  };

  String get support => switch (_language) {
    'zh-TW' => '支援',
    'zh-CN' => '支持',
    'ja' => 'サポート',
    _ => 'Support',
  };

  String get privacyPolicy => switch (_language) {
    'zh-TW' => '隱私權政策',
    'zh-CN' => '隐私政策',
    'ja' => 'プライバシーポリシー',
    _ => 'Privacy policy',
  };

  String get close => switch (_language) {
    'zh-TW' => '關閉',
    'zh-CN' => '关闭',
    'ja' => '閉じる',
    _ => 'Close',
  };

  String get urlOpenFailed => switch (_language) {
    'zh-TW' => '無法開啟連結，請稍後再試。',
    'zh-CN' => '无法打开链接，请稍后重试。',
    'ja' => 'リンクを開けませんでした。もう一度お試しください。',
    _ => 'Unable to open the link. Please try again.',
  };

  String get incrementHint => switch (_language) {
    'zh-TW' => '點按增加 1',
    'zh-CN' => '点击增加 1',
    'ja' => 'タップして 1 増やす',
    _ => 'Tap to add 1',
  };

  String counter(int count) => switch (_language) {
    'zh-TW' => '計數器 $count',
    'zh-CN' => '计数器 $count',
    'ja' => 'カウンター $count',
    _ => 'Counter $count',
  };

  String clock(DateTime time) => switch (_language) {
    'zh-TW' => '目前時間 ${time.hour} 時 ${time.minute} 分 ${time.second} 秒',
    'zh-CN' => '当前时间 ${time.hour} 时 ${time.minute} 分 ${time.second} 秒',
    'ja' => '現在時刻 ${time.hour} 時 ${time.minute} 分 ${time.second} 秒',
    _ =>
      'Current time ${time.hour} hours ${time.minute} minutes ${time.second} seconds',
  };

  String get sensorUnavailable => switch (_language) {
    'zh-TW' => '無法使用動作感測器，請點按歸零。',
    'zh-CN' => '无法使用动作传感器，请点击归零。',
    'ja' => 'モーションセンサーを使用できません。リセットをタップしてください。',
    _ => 'Motion sensor unavailable. Tap Reset to reset the counter.',
  };
}
