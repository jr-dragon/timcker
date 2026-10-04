import 'dart:math' as math;

enum _Face { up, down, other }

/// Detects a settled face-down position followed by a settled face-up position.
class FaceFlipDetector {
  static const settleTime = Duration(milliseconds: 250);
  static const maxSampleGap = Duration(seconds: 1);

  _Face _candidate = _Face.other;
  Duration? _candidateSince;
  Duration? _lastSample;
  bool _armed = false;

  bool addSample({
    required double x,
    required double y,
    required double z,
    required Duration timestamp,
  }) {
    final lastSample = _lastSample;
    if (lastSample != null &&
        (timestamp < lastSample || timestamp - lastSample > maxSampleGap)) {
      reset();
    }
    _lastSample = timestamp;

    final magnitude = math.sqrt(x * x + y * y + z * z);
    final isSettled =
        magnitude >= 7.5 && magnitude <= 12 && x.abs() <= 4.5 && y.abs() <= 4.5;
    final face = !isSettled
        ? _Face.other
        : z <= -7.5
        ? _Face.down
        : z >= 7.5
        ? _Face.up
        : _Face.other;

    if (face == _Face.other) {
      _candidate = _Face.other;
      _candidateSince = null;
      return false;
    }
    if (face != _candidate) {
      _candidate = face;
      _candidateSince = timestamp;
      return false;
    }
    if (timestamp - _candidateSince! < settleTime) return false;

    if (face == _Face.down) {
      _armed = true;
    } else if (_armed) {
      reset();
      return true;
    }
    return false;
  }

  void reset() {
    _candidate = _Face.other;
    _candidateSince = null;
    _lastSample = null;
    _armed = false;
  }
}
