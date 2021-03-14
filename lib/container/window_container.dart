import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'window/decorated_window.dart';
import 'window/desktop_window.dart';

part 'window_configuration.dart';

/// 窗口容器对外接口
abstract class WindowContainerController {
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
  List<WindowConfiguration> _windows = [];

  /// 创建桌面组件
  WindowConfiguration _createDesktop() {
    return WindowConfiguration(
      title: 'desktop',
      canChanged: false,
      hasDecoration: false,
      sizeMode: WindowSizeMode.max,
      indexMode: WindowIndexMode.bottom,
      builder: (_) => DesktopWindow(),
    );
  }

  /// 设置窗口焦点,只能普通窗口有作用
  void _focusedWindow(WindowConfiguration window) {
    if (window.indexMode != WindowIndexMode.normal) {
      return;
    }
    int oldIndex = _windows.indexOf(window);
    int insertIndex = _windows
        .indexWhere((window) => window.indexMode == WindowIndexMode.top);
    if (insertIndex == -1) {
      insertIndex = _windows.length;
    }
    if (oldIndex + 1 == insertIndex) {
      return;
    }
    _windows.insert(insertIndex, window);
    _windows.removeAt(oldIndex);
    setState(() {});
  }

  /// 窗口改变监听
  void _onWindowChanged() {
    setState(() {});
  }

  /// 打开新窗口并添加到顶层
  @override
  Future<T?> open<T>(WindowConfiguration window) {
    window.addListener(_onWindowChanged);
    if (_windows.isEmpty || window.indexMode == WindowIndexMode.top) {
      // 没有窗口以及窗口模式为顶层则直接插入
      _windows.add(window);
    } else {
      // 窗口不为空时,自动寻找合适的位置插入
      int index = 0;
      switch (window.indexMode) {
        case WindowIndexMode.bottom:
          // 查找最后一个底层
          index = _windows.indexWhere(
              (window) => window.indexMode != WindowIndexMode.bottom);
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
    }
    setState(() {});
    return Future<T>.value(null);
  }

  /// 关闭指定窗口
  @override
  void close(WindowConfiguration window) {
    window.removeListener(_onWindowChanged);
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
            onPanDown: (_) => _focusedWindow(window),
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
  }

  @override
  Widget build(BuildContext context) {
    return _WindowStack(
      windows: _windows,
      children: _extractChildren(),
    );
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
    int i = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      WindowConfiguration window = _windows[i];
      _WindowStackParentData childParentData =
          child.parentData as _WindowStackParentData;
      childParentData.window = window;
      BoxConstraints childConstraints;
      switch (window.sizeMode) {
        case WindowSizeMode.max:
          // 最大化设置为显示尺寸
          childConstraints = BoxConstraints.expand(
            width: size.width,
            height: size.height,
          );
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
