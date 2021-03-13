part of 'window_container.dart';

/// 窗口大小模式
enum WindowSizeMode {
  /// 最大化
  max,

  /// 最小化
  min,

  /// 自动
  auto,

  /// 固定
  fixed,
}

/// 窗口位置索引
enum WindowIndexMode {
  /// 始终在顶层
  top,

  /// 始终在底层
  bottom,

  /// 普通
  normal,
}

/// 窗口配置
class WindowConfiguration extends ChangeNotifier {
  Key _key = UniqueKey();

  bool _changed = true;

  /// 能否修改
  final bool canChanged;

  /// 是否有装饰
  final bool hasDecoration;

  /// 是否含有最大化按钮
  final bool hasMaximize;

  /// 是否含有最小化按钮
  final bool hasMinimize;

  /// 是否可更改大小
  final bool resizeable;

  /// 窗口组
  String? _group;

  String? get group => _group;

  /// 窗口标题
  String _title;

  String get title => _title;

  set title(String value) {
    if (!canChanged) {
      return;
    }
    if (_title != value) {
      _title = value;
      notifyListeners();
    }
  }

  /// 窗口颜色,主要是标题栏
  Color _color;

  Color get color => _color;

  set color(Color value) {
    if (!canChanged) {
      return;
    }
    if (_color != value) {
      _color = value.withOpacity(value.opacity.clamp(0.5, 1.0));
      notifyListeners();
    }
  }

  /// 窗口大小状态
  WindowSizeMode _preSizeMode;

  WindowSizeMode get preSizeMode => _preSizeMode;
  WindowSizeMode _sizeMode;

  WindowSizeMode get sizeMode => _sizeMode;

  set sizeMode(WindowSizeMode value) {
    if (!canChanged) {
      return;
    }
    if (_sizeMode != value) {
      if (_sizeMode != WindowSizeMode.max && _sizeMode != WindowSizeMode.min) {
        _preSizeMode = _sizeMode;
      }
      _sizeMode = value;
      notifyListeners();
    }
  }

  /// 窗口索引状态
  WindowIndexMode _indexMode;

  WindowIndexMode get indexMode => _indexMode;

  set indexMode(WindowIndexMode value) {
    if (!canChanged) {
      return;
    }
    if (_indexMode != value) {
      _indexMode = value;
    }
    notifyListeners();
  }

  /// 窗口区域
  Offset? _position;
  Rect _rect;

  Rect get rect => _rect;

  set rect(Rect value) {
    if (!canChanged) {
      return;
    }
    if (_rect != value) {
      _rect = value;
      _position = _rect.topLeft;
      notifyListeners();
    }
  }

  /// 组件构造器
  final WidgetBuilder builder;

  WindowConfiguration({
    required String title,
    String? group,
    Color? color,
    this.canChanged = true,
    this.hasDecoration = true,
    this.hasMaximize = true,
    this.hasMinimize = true,
    this.resizeable = true,
    WindowSizeMode? sizeMode,
    Offset? position,
    Size? size,
    WindowIndexMode? indexMode,
    required this.builder,
  })   : _title = title,
        _group = group,
        _color = color ?? Colors.white.withOpacity(0.5),
        _sizeMode = sizeMode ?? WindowSizeMode.auto,
        _preSizeMode = sizeMode ?? WindowSizeMode.auto,
        _indexMode = indexMode ?? WindowIndexMode.normal,
        _position = position,
        _rect = (position ?? Offset.zero) & (size ?? Size.zero) {
    if (_sizeMode != WindowSizeMode.max && _sizeMode != WindowSizeMode.min) {
      _sizeMode = size != null ? WindowSizeMode.fixed : WindowSizeMode.auto;
      _preSizeMode = _sizeMode;
    }
  }

  @override
  void notifyListeners() {
    _changed = true;
    super.notifyListeners();
  }
}

/// 共享当前窗口设置
class WindowConfigureData extends InheritedWidget {
  final WindowConfiguration data;

  const WindowConfigureData({
    required Key key,
    required Widget child,
    required this.data,
  }) : super(key: key, child: child);

  static WindowConfigureData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WindowConfigureData>()!;
  }

  @override
  bool updateShouldNotify(WindowConfigureData old) {
    return data != old.data;
  }
}
