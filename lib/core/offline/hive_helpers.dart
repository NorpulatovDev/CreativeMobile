import 'dart:convert';

/// Converts a model's toJson() output into a form safe for Hive storage.
/// Hive can't store custom objects, so we round-trip through JSON to ensure
/// everything is primitives (strings, numbers, booleans, lists, maps).
Map<String, dynamic> toHiveMap(Map<String, dynamic> json) {
  return jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
}

/// Converts a Hive-stored value back to Map<String, dynamic>.
/// Hive returns Map<dynamic, dynamic> — this does a deep recursive cast.
Map<String, dynamic> fromHiveMap(dynamic value) {
  return _deepCast(value) as Map<String, dynamic>;
}

dynamic _deepCast(dynamic value) {
  if (value is Map) {
    return value.map<String, dynamic>(
      (key, val) => MapEntry(key.toString(), _deepCast(val)),
    );
  } else if (value is List) {
    return value.map(_deepCast).toList();
  }
  return value;
}
