part of 'window_container.dart';

/// 窗口类型
enum WindowType {
  /// 桌面类型,只能至于最底层
  desktop,

  /// 任务栏,在最顶层
  task_bar,

  /// 普通窗口
  normal,
}

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
class WindowConfigureData extends ChangeNotifier {
  Key _key = UniqueKey();

  /// 是否已经改变
  bool _changed = true;

  /// 窗口类型
  WindowType _type = WindowType.normal;

  WindowType get type => _type;

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

  /// 是否需要动画
  final bool needAnimation;

  /// 是否完成动画
  bool _isAnimationCompleted = true;

  bool get isAnimationCompleted => _isAnimationCompleted;

  set isAnimationCompleted(bool value) {
    if (_isAnimationCompleted != value) {
      _isAnimationCompleted = value;
      notifyListeners();
    }
  }

  /// 窗口组
  String _group;

  String get group => _group;

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
  WindowSizeMode _sizeMode;

  WindowSizeMode get sizeMode => _sizeMode;

  set sizeMode(WindowSizeMode value) {
    if (!canChanged) {
      return;
    }
    if (_sizeMode != value) {
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

  /// 是否含有位置
  ///
  /// 用于第一次打开窗口时判断居中
  bool _hasPosition;

  /// 记录初次打开窗口大小,后续不能小于此大小
  Size? _firstSize;

  /// 窗口区域
  Rect _rect;

  Rect get rect => _rect;

  set rect(Rect value) {
    if (!canChanged) {
      return;
    }
    if (_rect != value) {
      _rect = value;
      // 主动设置区域则有位置
      _hasPosition = true;
      notifyListeners();
    }
  }

  /// 组件构造器
  final WidgetBuilder builder;

  factory WindowConfigureData._type({
    required WindowType type,
    required String title,
    String? group,
    Color? color,
    bool canChanged = true,
    bool hasDecoration = true,
    bool hasMaximize = true,
    bool hasMinimize = true,
    bool resizeable = true,
    WindowSizeMode? sizeMode,
    Offset? position,
    Size? size,
    WindowIndexMode? indexMode,
    required WidgetBuilder builder,
  }) {
    return WindowConfigureData(
      title: title,
      group: group,
      color: color,
      canChanged: canChanged,
      hasDecoration: hasDecoration,
      hasMaximize: hasMaximize,
      hasMinimize: hasMinimize,
      resizeable: resizeable,
      needAnimation: false,
      sizeMode: sizeMode,
      position: position,
      size: size,
      indexMode: indexMode,
      builder: builder,
    ).._type = type;
  }

  WindowConfigureData({
    required String title,
    String? group,
    Color? color,
    this.canChanged = true,
    this.hasDecoration = true,
    this.hasMaximize = true,
    this.hasMinimize = true,
    this.resizeable = true,
    this.needAnimation = true,
    WindowSizeMode? sizeMode,
    Offset? position,
    Size? size,
    WindowIndexMode? indexMode,
    required this.builder,
  })   : _title = title,
        _group = group ?? Uuid().v4(),
        _color = color ?? Colors.white.withOpacity(0.5),
        _sizeMode = sizeMode ?? WindowSizeMode.auto,
        _indexMode = indexMode ?? WindowIndexMode.normal,
        _hasPosition = position != null,
        _rect = (position ?? Offset.zero) & (size ?? Size.zero) {
    if (_sizeMode != WindowSizeMode.max && _sizeMode != WindowSizeMode.min) {
      _sizeMode = size != null ? WindowSizeMode.fixed : WindowSizeMode.auto;
    }
  }

  @override
  void notifyListeners() {
    _changed = true;
    super.notifyListeners();
  }

  /// 拖动窗口
  void drag(Offset delta) {
    rect = rect.shift(delta);
  }

  /// 设置大小
  void resize(Rect delta) {
    sizeMode = WindowSizeMode.fixed;
    Rect newRect = Rect.fromLTRB(
      rect.left + delta.left,
      rect.top + delta.top,
      rect.right + delta.right,
      rect.bottom + delta.bottom,
    );
    if (newRect.size >= _firstSize!) {
      rect = newRect;
    }
  }

  /// 最大化之前的模式
  WindowSizeMode? _maxSizeMode;
  Rect? _maxRect;

  /// 最大化
  void maximize() {
    if (needAnimation) {
      _isAnimationCompleted = false;
    }
    if (_sizeMode != WindowSizeMode.max) {
      // 记录当前窗口状态
      _maxSizeMode = _sizeMode;
      _maxRect = _rect;
      // 跳过最小化
      if (_maxSizeMode == WindowSizeMode.min) {
        _maxSizeMode = _minSizeMode;
        _maxRect = _minRect;
      }
      // 如果无值则自动
      if (_maxSizeMode == null || _maxSizeMode == WindowSizeMode.max) {
        _maxSizeMode = WindowSizeMode.auto;
        _maxRect = Rect.zero;
      }
      // 执行最大化
      sizeMode = WindowSizeMode.max;
    } else {
      // 执行恢复
      _rect = _maxRect ?? Rect.zero;
      sizeMode = _maxSizeMode ?? WindowSizeMode.auto;
      _maxSizeMode = _sizeMode;
    }
  }

  /// 最小化之前的模式
  WindowSizeMode? _minSizeMode;

  WindowSizeMode? get minSizeMode => _minSizeMode;
  Rect? _minRect;

  /// 最小化
  void minimize() {
    if (needAnimation) {
      _isAnimationCompleted = false;
    }
    if (_sizeMode != WindowSizeMode.min) {
      // 记录当前窗口状态
      _minSizeMode = _sizeMode;
      _minRect = _rect;
      // 执行最小化
      sizeMode = WindowSizeMode.min;
    } else {
      // 执行恢复
      _rect = _minRect ?? Rect.zero;
      sizeMode = _minSizeMode ?? WindowSizeMode.auto;
      _minSizeMode = _sizeMode;
    }
  }
}

/// 共享当前窗口设置
class WindowConfiguration extends InheritedWidget {
  final WindowConfigureData window;

  const WindowConfiguration({
    Key? key,
    required Widget child,
    required this.window,
  }) : super(key: key, child: child);

  static WindowConfigureData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WindowConfiguration>()!.window;
  }

  @override
  bool updateShouldNotify(WindowConfiguration old) {
    // TODO: 需要优化
    return true;
  }
}
