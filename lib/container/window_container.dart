import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:uuid/uuid.dart';

import 'window/decorated_window.dart';
import 'window/desktop_window.dart';
import 'window/task_bar_window.dart';
import 'window_container_theme.dart';

part 'window_configuration.dart';

part 'window_application.dart';

/// 窗口容器对外接口
abstract class WindowContainerController {
  /// 请求窗口焦点
  void focus(WindowConfigureData window);

  /// 打开新的应用
  Future<T?> openApplication<T>(String applicationId);

  /// 打开新的窗口
  Future<T?> open<T>(WindowConfigureData window);

  /// 关闭窗口
  void close(WindowConfigureData window);
}

/// 窗口容器
class WindowContainer extends StatefulWidget {
  /// 容器主题
  final WindowContainerThemeData theme;

  /// 应用
  final List<WindowApplicationManifest> applications;

  const WindowContainer({
    Key? key,
    this.theme = const WindowContainerThemeData(),
    this.applications = const [],
  }) : super(key: key);

  @override
  WindowContainerState createState() => WindowContainerState();

  /// 根据[context]查找最近的容器,如果[rootContainer]为true则查找根容器
  ///
  /// 参考[Navigator.of]
  static WindowContainerController of(
    BuildContext context, {
    bool rootContainer = false,
  }) {
    WindowContainerState? container;
    if (context is StatefulElement && context.state is WindowContainerState) {
      container = context.state as WindowContainerState;
    }
    if (rootContainer) {
      // 查找根容器
      container = context.findRootAncestorStateOfType<WindowContainerState>() ??
          container;
    } else {
      // 查找最近的容器
      container =
          container ?? context.findAncestorStateOfType<WindowContainerState>();
    }
    assert(() {
      if (container == null) {
        throw FlutterError('Cannot find WindowContainer');
      }
      return true;
    }());
    return container!;
  }
}

class WindowContainerState extends State<WindowContainer>
    implements WindowContainerController {
  /// 窗口应用
  final Map<String, WindowApplicationManifest> _applications = {};

  /// 打开的应用
  final Map<String, WindowApplicationData> _applicationTasks = {};

  /// 所有显示窗口
  final List<WindowConfigureData> _windows = [];

  /// 窗口分组
  final Map<String, List<WindowConfigureData>> _windowGroups = {};

  /// 初始化应用
  void _initApplications() {
    _applications.clear();
    widget.applications.forEach((application) {
      _applications[application.applicationId] = application;
    });
  }

  /// 创建桌面组件
  WindowConfigureData _createDesktop() {
    return WindowConfigureData._type(
      type: WindowType.desktop,
      title: 'desktop',
      canChanged: false,
      hasDecoration: false,
      sizeMode: WindowSizeMode.max,
      indexMode: WindowIndexMode.bottom,
      builder: (_) => DesktopWindow(),
    );
  }

  /// 创建任务栏组件
  WindowConfigureData _createTaskBar() {
    return WindowConfigureData._type(
      type: WindowType.task_bar,
      title: 'task_bar',
      canChanged: false,
      hasDecoration: false,
      indexMode: WindowIndexMode.top,
      builder: (_) => TaskBarWindow(),
    );
  }

  /// 窗口改变监听
  void _onWindowChanged() {
    setState(() {});
  }

  /// 设置窗口焦点并置顶,只对普通窗口有用
  @override
  void focus(WindowConfigureData window) {
    if (window.indexMode != WindowIndexMode.normal) {
      return;
    }
    // 查找旧的下标和顶层下标
    final int oldIndex = _windows.indexOf(window);
    int insertIndex = _windows
        .indexWhere((window) => window.indexMode == WindowIndexMode.top);
    if (insertIndex == -1) {
      insertIndex = _windows.length;
    }
    // 如果顶层是自己则无需交换
    if (oldIndex + 1 == insertIndex) {
      return;
    }
    // 插入新的位置并移除旧的
    _windows.insert(insertIndex, window);
    _windows.removeAt(oldIndex);
    setState(() {});
  }

  /// 打开新的应用
  @override
  Future<T?> openApplication<T>(String applicationId) {
    WindowApplicationManifest? manifest = _applications[applicationId];
    if (manifest == null) {
      return Future<T>.value(null);
    }
    WindowApplicationData applicationData = WindowApplicationData(
      showInDesktop: manifest.showInDesktop,
      applicationId: manifest.applicationId,
      applicationName: manifest.applicationName,
      windows: manifest.windows,
      taskId: Uuid().v4(),
      icon: manifest.icon,
      iconUrl: manifest.iconUrl,
      state: this,
    );
    _applicationTasks[applicationData.taskId] = applicationData;
    return applicationData.open('main');
  }

  /// 打开新窗口并添加到顶层
  @override
  Future<T?> open<T>(WindowConfigureData window) {
    // 添加状态改变监听
    window.addListener(_onWindowChanged);
    if (window.type == WindowType.normal) {
      _windowGroups[window.group] ??= [];
      _windowGroups[window.group]!.add(window);
    }

    // 寻找合适的位置插入
    int index = 0;
    switch (window.indexMode) {
      case WindowIndexMode.top:
        // 查找最后一个顶层
        index = _windows.indexWhere((window) =>
            window.indexMode == WindowIndexMode.top &&
            window.type == WindowType.task_bar);
        break;
      case WindowIndexMode.bottom:
        // 查找最后一个底层
        index = _windows
            .indexWhere((window) => window.indexMode != WindowIndexMode.bottom);
        index += index != -1 ? 1 : 0;
        break;
      case WindowIndexMode.normal:
        // 查找第一个顶层
        index = _windows
            .indexWhere((window) => window.indexMode == WindowIndexMode.top);
        break;
      default:
        break;
    }
    if (index == -1) {
      index = _windows.length;
    }
    _windows.insert(index, window);

    setState(() {});
    return Future<T>.value(null);
  }

  /// 关闭指定窗口
  @override
  void close(WindowConfigureData window) {
    // 移除状态改变监听
    window.removeListener(_onWindowChanged);
    _windowGroups[window.group]?.remove(window);
    if (_windowGroups[window.group]?.isEmpty == true) {
      _windowGroups.remove(window.group);
      // 移除应用
      _applicationTasks.remove(window.group);
    }
    // 移除窗口
    _windows.remove(window);
    setState(() {});
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  /// 根据窗口配置生成widget
  List<Widget> _extractChildren() {
    return _windows.map<Widget>((window) {
      Widget result = _WindowOverlay(
        key: window._key,
        window: window,
        child: WindowConfiguration(
          window: window,
          child: _WindowDecorated(
            onFocused: (window) => focus(window),
          ),
        ),
      );
      if (_applicationTasks[window.group] != null) {
        result = WindowApplication(
          key: window._key,
          application: _applicationTasks[window.group]!,
          child: result,
        );
      }
      return result;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // 初始化应用
    _initApplications();
    // 添加桌面
    open(_createDesktop());
    // 添加任务栏
    open(_createTaskBar());
  }

  @override
  void didUpdateWidget(covariant WindowContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.applications != oldWidget.applications) {
      _initApplications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WindowContainerTheme(
      theme: widget.theme,
      child: Theme(
        data: ThemeData(
          brightness: widget.theme.brightness,
          backgroundColor: widget.theme.backgroundColor,
          scaffoldBackgroundColor: widget.theme.backgroundColor,
          shadowColor: widget.theme.shadowColor,
        ),
        child: WindowContainerStatus(
          applications: widget.applications,
          applicationTasks: _applicationTasks,
          windows: _windows,
          groups: _windowGroups,
          child: _WindowStack(
            windows: _windows,
            children: _extractChildren(),
          ),
        ),
      ),
    );
  }
}

/// 窗口容器状态数据
class WindowContainerStatus extends InheritedWidget {
  /// 顶层窗口
  final WindowConfigureData? _topWindow;

  WindowConfigureData? get topWindow => _topWindow;

  /// 应用
  final List<WindowApplicationManifest> _applications;

  List<WindowApplicationManifest> get applications => _applications;

  /// 打开的应用
  final Map<String, WindowApplicationData> _applicationTasks;

  Map<String, WindowApplicationData> get applicationTasks => _applicationTasks;

  /// 所有显示窗口
  final List<WindowConfigureData> _windows;

  List<WindowConfigureData> get windows => _windows;

  /// 窗口分组
  final Map<String, List<WindowConfigureData>> _groups;

  Map<String, List<WindowConfigureData>> get groups => _groups;
  final List<MapEntry<String, List<WindowConfigureData>>> groupList;

  WindowContainerStatus({
    Key? key,
    required List<WindowApplicationManifest> applications,
    required Map<String, WindowApplicationData> applicationTasks,
    required List<WindowConfigureData> windows,
    required Map<String, List<WindowConfigureData>> groups,
    required Widget child,
  })   : _applications = List<WindowApplicationManifest>.from(applications),
        _applicationTasks =
            Map<String, WindowApplicationData>.from(applicationTasks),
        _windows = List<WindowConfigureData>.from(windows),
        _topWindow = _findTopWindow(windows),
        _groups = Map<String, List<WindowConfigureData>>.from(groups),
        groupList = groups.entries.toList(),
        super(key: key, child: child);

  /// 查找顶层普通窗口
  static WindowConfigureData? _findTopWindow(
      List<WindowConfigureData> windows) {
    try {
      return windows
          .lastWhere((window) => window.indexMode == WindowIndexMode.normal);
    } catch (e) {
      return null;
    }
  }

  static WindowContainerStatus of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WindowContainerStatus>()!;
  }

  @override
  bool updateShouldNotify(WindowContainerStatus old) {
    // TODO: 需要优化
    return true;
  }
}

/// 窗口焦点回调
typedef OnWindowFocused = void Function(WindowConfigureData window);

/// 窗口装饰
class _WindowDecorated extends StatefulWidget {
  /// 动画时间
  final Duration duration;

  /// 窗口焦点回调
  final OnWindowFocused onFocused;

  const _WindowDecorated({
    Key? key,
    this.duration = const Duration(milliseconds: 200),
    required this.onFocused,
  }) : super(key: key);

  @override
  __WindowDecoratedState createState() => __WindowDecoratedState();
}

class __WindowDecoratedState extends State<_WindowDecorated>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late WindowConfigureData _window;

  /// 记录上一次模式,用以判断是否改变
  WindowSizeMode? _oldSizeMode;

  /// 判断动画执行方向
  bool _isReverse = false;

  /// 当前值,过渡用
  double _value = 0.0;

  /// 变换矩阵
  Matrix4 _matrix4 = Matrix4.identity();

  /// 更新动画状态,一帧执行完再更新
  void _updateStatus(bool isCompleted) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _window.isAnimationCompleted = isCompleted;
    });
  }

  /// 更新动画状态,需要判断执行方向
  void _updateAnimationStatus(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
        if (_isReverse) {
          _updateStatus(true);
        }
        break;
      case AnimationStatus.completed:
        if (!_isReverse) {
          _updateStatus(true);
        }
        break;
      default:
        break;
    }
  }

  /// 初始化动画
  void _initAnimation([bool isFirst = false]) {
    if (!isFirst) {
      _controller.dispose();
    }
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.addListener(() {
      _value = _controller.value;
      _matrix4.setIdentity();
      _matrix4.setEntry(3, 2, 0.001);
      _matrix4.rotateX(((45.0 - (45.0 * _value)) / 180) * pi);
      setState(() {});
    });
    _controller.addStatusListener(_updateAnimationStatus);
  }

  /// 播放动画
  void _startAnimation({bool isReverse = false}) {
    _isReverse = isReverse;
    _stopAnimation();
    _updateStatus(false);
    if (!isReverse) {
      _controller.forward(from: _value);
    } else {
      _controller.reverse(from: _value);
    }
  }

  /// 停止动画
  void _stopAnimation() {
    _controller.stop();
  }

  @override
  void initState() {
    super.initState();
    _initAnimation(true);
  }

  @override
  void didUpdateWidget(covariant _WindowDecorated oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      // 时长更新重新初始化动画
      _initAnimation();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _window = WindowConfiguration.of(context);
    // 发送改变时再执行
    if (_window.sizeMode != _oldSizeMode) {
      // 是否需要动画
      if (_window.needAnimation) {
        // 第一次启动以及非最小化执行正向动画
        if (_oldSizeMode == null || _window.sizeMode != WindowSizeMode.min) {
          // 最大化与非最小化切换
          if ((_window.sizeMode == WindowSizeMode.max &&
                  _oldSizeMode != WindowSizeMode.min) ||
              (_window.sizeMode != WindowSizeMode.min &&
                  _oldSizeMode == WindowSizeMode.max)) {
            _value = 0.0;
          }
          // 非缩放执行
          if (!(_oldSizeMode == WindowSizeMode.auto &&
              _window.sizeMode == WindowSizeMode.fixed)) {
            _startAnimation();
          }
        } else if (_window.sizeMode == WindowSizeMode.min) {
          // 最小化执行反向动画
          _startAnimation(isReverse: true);
        }
      }
      _oldSizeMode = _window.sizeMode;
    }
  }

  @override
  void dispose() {
    _stopAnimation();
    _controller.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget result = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (_) => widget.onFocused(_window),
      child: DecoratedWindow(),
    );
    if (_window.needAnimation) {
      result = Transform(
        alignment: Alignment.topCenter,
        transform: _matrix4,
        child: Opacity(
          opacity: _controller.value,
          child: result,
        ),
      );
    }
    return result;
  }
}

/// 窗口叠加层
///
/// 使用叠加层是为了使layout和paint作用范围限制到窗口内
class _WindowOverlay extends SingleChildRenderObjectWidget {
  /// 窗口配置
  final WindowConfigureData window;

  /// 窗口组件
  final Widget child;

  _WindowOverlay({
    required Key key,
    required this.window,
    required this.child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderWindowOverlay(
      window: window,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderWindowOverlay renderObject) {
    renderObject..window = window;
  }
}

class _RenderWindowOverlay extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  WindowConfigureData _window;

  /// 对象变化或者值改变则relayout
  set window(WindowConfigureData value) {
    if (_window != value || _window._changed) {
      _window = value;
      _window._changed = false;
      markNeedsLayout();
    }
  }

  _RenderWindowOverlay({
    required WindowConfigureData window,
  }) : _window = window;

  /// 设置repaint区域
  @override
  bool get isRepaintBoundary => true;

  /// 为true能让relayout不会影响到父RenderObject
  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child is! BoxParentData) {
      child.parentData = BoxParentData();
    }
  }

  @override
  void performLayout() {
    // 只能用在[_WindowStack]
    assert(parentData is _WindowStackParentData);
    final _WindowStackParentData stackParentData =
        parentData as _WindowStackParentData;
    // 如果动画未执行完成则继续
    if (child == null ||
        (_window.sizeMode == WindowSizeMode.min &&
            _window.isAnimationCompleted)) {
      return;
    }
    final bool isTaskBar = _window.type == WindowType.task_bar;
    // 任务栏特殊处理
    final Rect taskRect = isTaskBar ? Rect.zero : stackParentData.taskBarRect;
    final BoxParentData childParentData = child!.parentData as BoxParentData;
    BoxConstraints childConstraints;
    WindowSizeMode sizeMode = _window.sizeMode;
    // 找回之前的模式
    if (sizeMode == WindowSizeMode.min && !_window.isAnimationCompleted) {
      sizeMode = _window._minSizeMode ?? sizeMode;
    }
    switch (sizeMode) {
      case WindowSizeMode.max:
        // 最大化设置为显示尺寸
        // 同时普通窗口会多减去任务栏的高度
        childConstraints = BoxConstraints.expand(
          width: size.width,
          height: size.height -
              (_window.type == WindowType.normal ? taskRect.height : 0.0),
        );
        break;
      case WindowSizeMode.fixed:
        // 固定值设置为配置的值
        childConstraints = BoxConstraints.expand(
          width: _window.rect.width,
          height: _window.rect.height,
        );
        break;
      case WindowSizeMode.auto:
      default:
        // 靠子组件决定大小
        childConstraints = constraints.loosen();
        break;
    }
    if (isTaskBar) {
      // 任务栏占满宽度,高度自适应
      childConstraints = BoxConstraints.tightFor(width: size.width);
    }
    child!.layout(
      childConstraints,
      parentUsesSize: true,
    );

    // 计算窗口大小与位置
    final Size childSize = child!.size;
    Offset childOffset;
    if (sizeMode == WindowSizeMode.max) {
      // 最大化时,位置设置为原点
      childOffset = Offset.zero;
    } else if (_window._hasPosition) {
      // 不是最大化并且有位置时设置为左上角
      childOffset = _window.rect.topLeft;
    } else {
      // 未设置位置则居中显示
      childOffset = ((size - childSize) as Offset) / 2.0;
    }
    // 任务栏在底部,普通的就按照上面计算的位置来
    _window._rect = (isTaskBar
            ? Offset(0.0, size.height - childSize.height)
            : childOffset) &
        childSize;
    _window._firstSize ??= childSize;

    // 设置位置
    childParentData.offset = _window.rect.topLeft;
    if (isTaskBar) {
      stackParentData.taskBarRect = _window.rect;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // 动画未执行完成则继续
    if (child == null ||
        (_window.sizeMode == WindowSizeMode.min &&
            _window.isAnimationCompleted)) {
      return;
    }
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    context.paintChild(child!, childParentData.offset + offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (_window.sizeMode == WindowSizeMode.min) {
      return false;
    }
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    return result.addWithPaintOffset(
      offset: childParentData.offset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset? transformed) {
        assert(transformed == position - childParentData.offset);
        return child!.hitTest(result, position: transformed!);
      },
    );
  }
}

/// 窗口绘制组件
class _WindowStack extends MultiChildRenderObjectWidget {
  /// 窗口配置
  final List<WindowConfigureData> windows;

  _WindowStack({
    Key? key,
    required this.windows,
    required List<Widget> children,
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderWindowStack(
      windows: windows,
      themeData: WindowContainerTheme.of(context),
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderWindowStack renderObject) {
    renderObject
      ..windows = windows
      ..themeData = WindowContainerTheme.of(context);
  }
}

/// 组件数据
class _WindowStackParentData extends ContainerBoxParentData<RenderBox> {
  late WindowConfigureData window;

  /// 任务栏区域
  Rect taskBarRect = Rect.zero;
}

/// 窗口绘制对象
class _RenderWindowStack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _WindowStackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _WindowStackParentData> {
  List<WindowConfigureData> _windows;

  /// 当数量和对象有一个改变时重绘
  set windows(List<WindowConfigureData> value) {
    if (_isWindowsChanged(_windows, value)) {
      _windows = value;
      markNeedsLayout();
    }
  }

  /// 主题
  WindowContainerThemeData _themeData;

  set themeData(WindowContainerThemeData value) {
    if (_themeData != value) {
      _themeData = value;
      markNeedsPaint();
    }
  }

  _RenderWindowStack({
    required List<WindowConfigureData> windows,
    required WindowContainerThemeData themeData,
  })   : _windows = windows,
        _themeData = themeData;

  /// 检查是否改变数组对象
  bool _isWindowsChanged(List<WindowConfigureData> oldWindows,
      List<WindowConfigureData> newWindows) {
    if (oldWindows.length != newWindows.length) {
      return true;
    }
    bool changed = false;
    for (int i = 0; i < oldWindows.length; i++) {
      if (oldWindows[i] != newWindows[i]) {
        changed = true;
        break;
      }
    }
    return changed;
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _WindowStackParentData) {
      child.parentData = _WindowStackParentData();
    }
  }

  @override
  void performLayout() {
    // 查找任务栏
    int i = 0;
    RenderBox? taskChild;
    Rect taskBarRect = Rect.zero;
    RenderBox? child = firstChild;
    while (child != null) {
      final WindowConfigureData window = _windows[i];
      if (window.type == WindowType.task_bar) {
        taskChild = child;
        final _WindowStackParentData taskChildParentData =
            taskChild.parentData as _WindowStackParentData;
        taskChildParentData.window = window;
        taskChild.layout(
          BoxConstraints.expand(width: size.width, height: size.height),
        );
        taskBarRect = taskChildParentData.taskBarRect;
        break;
      }
      child = childAfter(child);
      i++;
    }

    // 处理剩余
    i = 0;
    child = firstChild;
    while (child != null) {
      final WindowConfigureData window = _windows[i];
      if (window.type != WindowType.task_bar) {
        // 跳过任务栏
        final _WindowStackParentData childParentData =
            child.parentData as _WindowStackParentData;
        childParentData.taskBarRect = taskBarRect;
        childParentData.window = window;
        child.layout(
          BoxConstraints.expand(width: size.width, height: size.height),
        );
      }
      child = childAfter(child);
      i++;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // 绘制背景
    Canvas canvas = context.canvas;
    canvas.drawColor(_themeData.backgroundColor, BlendMode.src);
    defaultPaint(context, offset);
  }

  @override
  bool hitTestSelf(Offset position) {
    return size.contains(position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
