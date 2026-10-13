import 'package:flutter_test/flutter_test.dart';
import 'package:noyce_joyce_nixie/ble/night_mode_time_codec.dart';

void main() {
  test('encodes night mode times as seconds since midnight', () {
    expect(encodeNightModeTime(DateTime(2026, 10, 13, 17)), [0x10, 0xEF, 0x00, 0x00]);
    expect(encodeNightModeTime(DateTime(2026, 10, 13, 9)), [0x90, 0x7E, 0x00, 0x00]);
    expect(encodeNightModeTime(DateTime(2026, 10, 13, 8)), [0x80, 0x70, 0x00, 0x00]);
  });

  test('calendar dates cannot change the encoded time', () {
    expect(
      encodeNightModeTime(DateTime(1970, 1, 1, 9)),
      encodeNightModeTime(DateTime(2106, 2, 7, 9)),
    );
  });

  test('canonical values round-trip without timezone conversion', () {
    final times = [
      DateTime(2026, 1, 15, 0),
      DateTime(2026, 7, 15, 8),
      DateTime(2026, 7, 15, 9),
      DateTime(2026, 7, 15, 17),
      DateTime(2026, 1, 15, 23, 59),
    ];

    for (final time in times) {
      final decoded = decodeNightModeTime(encodeNightModeTime(time));
      expect(decoded.isUtc, isTrue);
      expect(decoded.hour, time.hour);
      expect(decoded.minute, time.minute);
      expect(decoded.second, 0);
    }
  });

  test('avoids timestamp overflow that turns 09:00 into 02:31:44', () {
    final timestamp = DateTime.utc(2106, 2, 7, 9).millisecondsSinceEpoch ~/ 1000;
    final truncated = timestamp & 0xFFFFFFFF;

    expect(truncated, 9104);
    expect(Duration(seconds: truncated).toString(), '2:31:44.000000');
    expect(encodeNightModeTime(DateTime(2106, 2, 7, 9)), [0x90, 0x7E, 0x00, 0x00]);
  });

  test('legacy uint32 values have a deterministic display time', () {
    final highValue = decodeNightModeTime([0x90, 0x42, 0xFF, 0xFF]);
    final lowValue = decodeNightModeTime([0x90, 0x23, 0x00, 0x00]);

    expect(highValue, DateTime.utc(1970, 1, 1, 17));
    expect(lowValue, DateTime.utc(1970, 1, 1, 2, 31, 44));
  });
}
