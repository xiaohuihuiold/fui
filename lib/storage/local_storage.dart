import 'dart:html';

/// 浏览器本地存储
class LocalStorage {
  static _ThemeStorage theme = _ThemeStorage();
  static _NoteStorage note = _NoteStorage();
  static Storage _storage = window.localStorage;

  /// 当前设置所属
  final String scope;

  LocalStorage(this.scope);

  void putString(String key, String? value) {
    if (value == null) {
      removeString(key);
      return;
    }
    _storage['string_${scope}_$key'] = value;
  }

  String? getString(String key) {
    return _storage['string_${scope}_$key'];
  }

  void removeString(String key) {
    _storage.remove('string_${scope}_$key');
  }

  void putBool(String key, bool? value) {
    if (value == null) {
      removeBool(key);
      return;
    }
    _storage['bool_${scope}_$key'] = '$value';
  }

  bool? getBool(String key) {
    String? value = _storage['bool_${scope}_$key'];
    if (value == null) {
      return null;
    }
    return value == 'true';
  }

  void removeBool(String key) {
    _storage.remove('bool_${scope}_$key');
  }

  void putInt(String key, int? value) {
    if (value == null) {
      removeInt(key);
      return;
    }
    _storage['int_${scope}_$key'] = '$value';
  }

  int? getInt(String key) {
    String? value = _storage['int_${scope}_$key'];
    if (value == null) {
      return null;
    }
    return int.tryParse(value);
  }

  void removeInt(String key) {
    _storage.remove('int_${scope}_$key');
  }

  void putDouble(String key, double? value) {
    if (value == null) {
      removeDouble(key);
      return;
    }
    _storage['double_${scope}_$key'] = '$value';
  }

  double? getDouble(String key) {
    String? value = _storage['double_${scope}_$key'];
    if (value == null) {
      return null;
    }
    return double.tryParse(value);
  }

  void removeDouble(String key) {
    _storage.remove('double_${scope}_$key');
  }
}

abstract class _BaseStorage {
  final String scope;
  final LocalStorage storage;

  _BaseStorage(this.scope) : storage = LocalStorage(scope);
}

/// 主题配置
class _ThemeStorage extends _BaseStorage {
  _ThemeStorage() : super('theme');

  bool? get isDark => storage.getBool('is_dark');

  set isDark(bool? value) => storage.putBool('is_dark', value);

  bool get showWallpaper => storage.getBool('show_wallpaper') != false;

  set showWallpaper(bool value) => storage.putBool('show_wallpaper', value);
}

/// 笔记存储
class _NoteStorage extends _BaseStorage {
  _NoteStorage() : super('note');

  String? get text => storage.getString('text');

  set text(String? value) => storage.putString('text', value);
}
