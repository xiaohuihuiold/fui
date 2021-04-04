extension MapExt on Map {
  int getInt(String key) {
    return getIntOrNull(key)!;
  }

  int? getIntOrNull(String key) {
    dynamic value = this[key];
    if (value == null) {
      return null;
    }
    return (value as num).toInt();
  }

  double getDouble(String key) {
    return getDoubleOrNull(key)!;
  }

  double? getDoubleOrNull(String key) {
    dynamic value = this[key];
    if (value == null) {
      return null;
    }
    return (value as num).toDouble();
  }

  String getString(String key) {
    return getStringOrNull(key)!;
  }

  String? getStringOrNull(String key) {
    dynamic value = this[key];
    if (value == null) {
      return null;
    }
    return value.toString();
  }

  Map getObject(String key) {
    return getObjectOrNull(key)!;
  }

  Map? getObjectOrNull(String key) {
    dynamic value = this[key];
    if (value == null) {
      return null;
    }
    return value as Map;
  }

  List getArray(String key) {
    return getArrayOrNull(key)!;
  }

  List? getArrayOrNull(String key) {
    dynamic value = this[key];
    if (value == null) {
      return null;
    }
    return value as List;
  }
}
