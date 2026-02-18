class TempIdGenerator {
  int _counter = 0;

  /// Generates a negative integer temp ID to distinguish from real server IDs.
  int next() {
    _counter--;
    return _counter;
  }

  /// Returns true if the given ID is a temp ID (negative).
  static bool isTempId(int id) => id < 0;
}
