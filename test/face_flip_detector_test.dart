import 'package:flutter_test/flutter_test.dart';
import 'package:timcker/face_flip_detector.dart';

void main() {
  late FaceFlipDetector detector;
  setUp(() => detector = FaceFlipDetector());

  bool sample(int milliseconds, double z, {double x = 0, double y = 0}) =>
      detector.addSample(
        x: x,
        y: y,
        z: z,
        timestamp: Duration(milliseconds: milliseconds),
      );

  test(
    'requires a settled down-then-up sequence and rearms for another flip',
    () {
      expect(sample(0, 9.8), isFalse);
      expect(sample(300, 9.8), isFalse);
      expect(sample(400, -9.8), isFalse);
      expect(sample(650, -9.8), isFalse);
      expect(sample(700, 0, y: 9.8), isFalse);
      expect(sample(800, 9.8), isFalse);
      expect(sample(1049, 9.8), isFalse);
      expect(sample(1050, 9.8), isTrue);
      expect(sample(1100, 9.8), isFalse);
      expect(sample(1400, 9.8), isFalse);
      expect(sample(1500, -9.8), isFalse);
      expect(sample(1800, -9.8), isFalse);
      expect(sample(1900, 9.8), isFalse);
      expect(sample(2200, 9.8), isTrue);
    },
  );

  test('brief down movement and upright rotation do not arm a reset', () {
    expect(sample(0, -9.8), isFalse);
    expect(sample(100, 9.8), isFalse);
    expect(sample(400, 9.8), isFalse);
    expect(sample(500, 0, y: -9.8), isFalse);
    expect(sample(800, 0, y: -9.8), isFalse);
    expect(sample(900, 9.8), isFalse);
    expect(sample(1200, 9.8), isFalse);
  });

  test('rejects shaking, tilted samples, and non-finite readings', () {
    for (final z in [-20.0, -9.8, double.nan, double.infinity]) {
      expect(sample(0, z, x: 7), isFalse);
      expect(sample(300, z, x: 7), isFalse);
      expect(sample(400, 9.8), isFalse);
      expect(sample(700, 9.8), isFalse);
      detector.reset();
    }
  });

  test('interrupted face-up settling must start again', () {
    sample(0, -9.8);
    sample(300, -9.8);
    sample(400, 9.8);
    sample(600, 0, y: 9.8);
    expect(sample(700, 9.8), isFalse);
    expect(sample(900, 9.8), isFalse);
    expect(sample(950, 9.8), isTrue);
  });

  test('reset discards an armed gesture', () {
    sample(0, -9.8);
    sample(300, -9.8);
    detector.reset();
    expect(sample(400, 9.8), isFalse);
    expect(sample(700, 9.8), isFalse);
  });

  test('sample gaps and backwards timestamps discard stale gestures', () {
    sample(0, -9.8);
    sample(300, -9.8);
    expect(sample(2000, 9.8), isFalse);
    expect(sample(2300, 9.8), isFalse);
    sample(2400, -9.8);
    sample(2700, -9.8);
    expect(sample(100, 9.8), isFalse);
    expect(sample(400, 9.8), isFalse);
  });
}
