import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:uuid/uuid.dart';

import 'window/decorated_window.dart';
import 'window/desktop_window.dart';
import 'window/task_bar_window.dart';

part 'window_configuration.dart';

/// 窗口容器对外接口
abstract class WindowContainerController {
  /// 请求窗口焦点
  void focus(WindowConfiguration window);

  /// 打开新的窗口
  Future<T?> open<T>(WindowConfiguration window);

  /// 关闭窗口
  void close(WindowConfiguration window);
}

/// 窗口容器
class WindowContainer extends StatefulWidget {
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
  /// 所有显示窗口
  final List<WindowConfiguration> _windows = [];

  /// 窗口分组
  final Map<String, List<WindowConfiguration>> _windowGroups = {};

  /// 创建桌面组件
  WindowConfiguration _createDesktop() {
    return WindowConfiguration._type(
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
  WindowConfiguration _createTaskBar() {
    return WindowConfiguration._type(
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
  void focus(WindowConfiguration window) {
    if (window.indexMode != WindowIndexMode.normal) {
      return;
    }
    // 查找旧的下标和顶层下标
    int oldIndex = _windows.indexOf(window);
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

  /// 打开新窗口并添加到顶层
  @override
  Future<T?> open<T>(WindowConfiguration window) {
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
  void close(WindowConfiguration window) {
    // 移除状态改变监听
    window.removeListener(_onWindowChanged);
    _windowGroups[window.group]?.remove(window);
    if (_windowGroups[window.group]?.isEmpty == true) {
      _windowGroups.remove(window.group);
    }
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
    return [
      for (WindowConfiguration window in _windows)
        // 最小化不显示
        if (window.sizeMode != WindowSizeMode.min)
          GestureDetector(
            key: window._key,
            behavior: HitTestBehavior.opaque,
            onPanDown: (_) => focus(window),
            child: RepaintBoundary(
              child: WindowConfigureData(
                data: window,
                child: DecoratedWindow(),
              ),
            ),
          ),
    ];
  }

  @override
  void initState() {
    super.initState();
    // 添加桌面
    open(_createDesktop());
    // 添加任务栏
    open(_createTaskBar());
  }

  @override
  Widget build(BuildContext context) {
    return WindowContainerData(
      windows: _windows,
      groups: _windowGroups,
      child: _WindowStack(
        windows: _windows,
        children: _extractChildren(),
      ),
    );
  }
}

/// 窗口容器状态数据
class WindowContainerData extends InheritedWidget {
  /// 顶层窗口
  final WindowConfiguration? _topWindow;

  WindowConfiguration? get topWindow => _topWindow;

  /// 所有显示窗口
  final List<WindowConfiguration> _windows;

  List<WindowConfiguration> get windows => _windows;

  /// 窗口分组
  final Map<String, List<WindowConfiguration>> _groups;

  Map<String, List<WindowConfiguration>> get groups => _groups;
  final List<MapEntry<String, List<WindowConfiguration>>> groupList;

  WindowContainerData({
    Key? key,
    required List<WindowConfiguration> windows,
    required Map<String, List<WindowConfiguration>> groups,
    required Widget child,
  })   : _windows = List<WindowConfiguration>.from(windows),
        _topWindow = _findTopWindow(windows),
        _groups = Map<String, List<WindowConfiguration>>.from(groups),
        groupList = groups.entries.toList(),
        super(key: key, child: child);

  static WindowConfiguration? _findTopWindow(
      List<WindowConfiguration> windows) {
    try {
      return windows
          .lastWhere((window) => window.indexMode == WindowIndexMode.normal);
    } catch (e) {
      return null;
    }
  }

  static WindowContainerData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WindowContainerData>()!;
  }

  @override
  bool updateShouldNotify(WindowContainerData old) {
    // TODO: 需要优化
    return true;
  }
}

/// 窗口绘制组件
class _WindowStack extends MultiChildRenderObjectWidget {
  /// 窗口配置
  final List<WindowConfiguration> windows;

  _WindowStack({
    Key? key,
    required this.windows,
    required List<Widget> children,
  }) : super(
          key: key,
          children: children,
        );

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderWindowStack(
      windows: windows,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderWindowStack renderObject) {
    renderObject..windows = windows;
  }
}

/// 组件数据
class _WindowStackParentData extends ContainerBoxParentData<RenderBox> {
  late WindowConfiguration window;
}

/// 窗口绘制对象
class _RenderWindowStack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _WindowStackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _WindowStackParentData> {
  List<WindowConfiguration> _windows;

  set windows(List<WindowConfiguration> value) {
    if (_windows != value ||
        value.where((window) => window._changed).isNotEmpty) {
      _windows = value;
      _windows.forEach((window) {
        window._changed = false;
      });
      markNeedsLayout();
    }
  }

  _RenderWindowStack({
    required List<WindowConfiguration> windows,
  }) : _windows = windows;

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
    RenderBox? child = firstChild;
    while (child != null) {
      WindowConfiguration window = _windows[i];
      while (i < _windows.length && window.sizeMode == WindowSizeMode.min) {
        i++;
        window = _windows[i];
      }
      if (window.type == WindowType.task_bar) {
        taskChild = child;
        _WindowStackParentData taskChildParentData =
            taskChild.parentData as _WindowStackParentData;
        taskChildParentData.window = window;
        taskChild.layout(
          BoxConstraints.tightFor(width: size.width),
          parentUsesSize: true,
        );
        window._preRect = window.rect;
        window._rect =
            Offset(0.0, size.height - child.size.height) & child.size;
        window._firstSize ??= child.size;
        taskChildParentData.offset = window.rect.topLeft;
        break;
      }
      child = childAfter(child);
      i++;
    }

    // 处理剩余
    i = 0;
    child = firstChild;
    while (child != null) {
      WindowConfiguration window = _windows[i];
      while (i < _windows.length && window.sizeMode == WindowSizeMode.min) {
        i++;
        window = _windows[i];
      }
      if (window.type != WindowType.task_bar) {
        // 跳过任务栏
        _WindowStackParentData childParentData =
            child.parentData as _WindowStackParentData;
        childParentData.window = window;
        BoxConstraints childConstraints;
        switch (window.sizeMode) {
          case WindowSizeMode.max:
            // 最大化设置为显示尺寸
            if (window.type == WindowType.normal) {
              // 普通窗口需要考虑任务栏大小
              childConstraints = BoxConstraints.expand(
                width: size.width,
                height: size.height - ((taskChild?.size.height) ?? 0.0),
              );
            } else {
              childConstraints = BoxConstraints.expand(
                width: size.width,
                height: size.height,
              );
            }
            break;
          case WindowSizeMode.fixed:
            // 固定值设置为配置的值
            childConstraints = BoxConstraints.expand(
              width: window.rect.width,
              height: window.rect.height,
            );
            break;
          case WindowSizeMode.auto:
          default:
            childConstraints = constraints;
            break;
        }
        child.layout(
          childConstraints,
          parentUsesSize: true,
        );

        // 计算窗口大小与位置
        Size childSize = child.size;
        Offset childOffset;
        if (window.sizeMode == WindowSizeMode.max) {
          // 最大化时,位置设置为原点
          childOffset = Offset.zero;
        } else if (window._hasPosition) {
          // 不是最大化并且有位置时设置为左上角
          childOffset = window.rect.topLeft;
        } else {
          // 未设置位置则居中显示
          childOffset = ((size - childSize) as Offset) / 2.0;
        }
        window._preRect = window.rect;
        window._rect = childOffset & childSize;
        window._firstSize ??= childSize;

        // 设置位置
        childParentData.offset = window.rect.topLeft;
      }
      child = childAfter(child);
      i++;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
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
