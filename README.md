# Timcker

A small, single-screen Flutter app for Web, iOS, and Android.

- Shows the device's current local time in 24-hour `HH:mm:ss.SSS` format.
- Starts the integer counter at zero. Tap the counter number to increment it and **歸零**
  to reset it. Resetting the counter does not affect the clock.
- On native iOS and Android, turn the screen face down, then face up to reset.
  Hold each position for at least 250 ms. Brief tilts and upright rotation do
  not count as the gesture. When sensors are unavailable, use the reset button.
- Uses Material 3 on Web and Android and Cupertino on native iOS, including
  system light/dark appearance. Web on an iPhone still uses Material 3.
- Supports narrow screens, landscape, scrolling, and larger accessibility text.
  Short viewports use tighter spacing and smaller counter digits so standard-size
  text and the reset control fit without scrolling, including below the native
  support control. Larger accessibility text can still scroll when needed.
- Automatically translates reset controls, accessibility labels, and sensor errors
  into Traditional Chinese, Simplified Chinese, English, or Japanese. Unsupported
  languages fall back to English. There is no language picker. Web reads
  `navigator.language`; native apps use the primary device locale. Explicit Chinese
  script tags take priority over regions: Hant and TW/HK/MO use Traditional
  Chinese; Hans and other Chinese regions (including bare `zh`) use Simplified.
- Shows the time, tappable counter, and reset control. Native iOS and Android
  also include a top-right circled question button. It opens a platform-styled
  modal with support and privacy policy URLs, which open in the system browser.
  No date, title bar, section headings, increment button, or static hints.

The counter lives in memory and starts at zero on a fresh launch or Web reload.
The clock samples device time on display frames; its three millisecond digits
are displayed at the screen's refresh rate, rather than updating 1,000 times
per second. Sensor listening and clock frame updates stop while inactive.
Incomplete flip gestures are discarded when the app leaves the foreground.

## Development

Use Flutter 3.47.6 / Dart 3.13.5 or a compatible newer stable SDK.

```sh
flutter pub get
flutter run -d chrome
flutter run -d <ios-or-android-device-id>
```

## Web information pages

The Web build includes `/privacy` and `/support` as independent static pages.
Edit the localized articles in `web/privacy/index.html` and
`web/support/index.html` to update policy and support content. Keep all four
languages in sync. The policy describes the current app's local processing;
confirm the website host's logging practices when deploying. Both pages include
the support email `timcker@chivinent.net` and the support URL
`https://timcker.chivincent.net/support`.
The pages use `navigator.language` with the same language resolution as the app
and fall back to English when JavaScript is disabled. Shared styles follow the
system light/dark appearance. The counter screen remains unchanged.

Deploy all of `build/web`, including these directories and `info.css`/`info.js`.
The static host must serve directory `index.html` files and redirect `/privacy`
and `/support` to their trailing-slash URLs before any SPA fallback. No Flutter
router or additional build step is required. Relative links also support a
deployment below a URL prefix.

## Validation

```sh
dart format lib test
flutter analyze
flutter test
flutter test --platform chrome
flutter build web
flutter build apk --debug
flutter build ios --simulator
```

Native builds require the corresponding Flutter platform toolchain. Motion
uses [sensors_plus](https://pub.dev/packages/sensors_plus); iOS includes
`NSMotionUsageDescription` in `ios/Runner/Info.plist`.

For signed Android AAB builds, credential backups, and Play Console uploads,
see [Android release signing](android/SIGNING.md).

For a physical-device check on **both iOS and Android**:

1. Add several counts. Hold the screen face down: the count should stay unchanged.
2. Turn it face up and hold it steady: the count should become zero once.
3. Add another count while face up: it should stay until the next full flip.
4. Try brief tilts and portrait/landscape rotation: the count should stay unchanged.
5. Turn face down, switch away from the app, then return face up: the pending
   gesture should be discarded and the clock should show the current time.
6. Confirm tapping the number and the reset button work and the native controls follow system theme.

Tests cover synthetic sensor readings and lifecycle transitions. They do not
replace physical-device motion verification. See [AGENTS.md](AGENTS.md) for
review, branch, commit attribution, and squash merge conventions.
