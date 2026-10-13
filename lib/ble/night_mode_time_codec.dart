List<int> encodeNightModeTime(DateTime time) {
  final secondsSinceMidnight = time.hour * 3600 + time.minute * 60;
  return [
    secondsSinceMidnight & 0xFF,
    (secondsSinceMidnight >> 8) & 0xFF,
    (secondsSinceMidnight >> 16) & 0xFF,
    (secondsSinceMidnight >> 24) & 0xFF,
  ];
}

DateTime decodeNightModeTime(List<int> data) {
  final value = data[0] + (data[1] << 8) + (data[2] << 16) + (data[3] << 24);
  final secondsSinceMidnight = value % Duration.secondsPerDay;
  return DateTime.utc(1970, 1, 1).add(Duration(seconds: secondsSinceMidnight));
}
