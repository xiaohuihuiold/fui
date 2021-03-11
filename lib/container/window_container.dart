import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'decorated_window.dart';

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

  /// 根据窗口配置生成widget
  List<Widget> _extractChildren() {
    return [
      for (WindowConfiguration window in _windows)
        WindowConfigureData(
          key: window._key,
          data: window,
          child: DecoratedWindow(
            window: window,
          ),
        ),
    ];
  }

  /// 打开新窗口并添加到顶层
  @override
  Future<T?> open<T>(WindowConfiguration window) {
    _windows.add(window);
    setState(() {});
    return Future<T>.value(null);
  }

  /// 关闭指定窗口
  @override
  void close(WindowConfiguration window) {
    _windows.remove(window);
    setState(() {});
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
class _WindowStackParentData extends ContainerBoxParentData<RenderBox> {}

/// 窗口绘制对象
class _RenderWindowStack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _WindowStackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _WindowStackParentData> {
  List<WindowConfiguration> _windows;

  set windows(List<WindowConfiguration> value) {
    if (_windows != value) {
      _windows = value;
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
    if (child.parentData! is _WindowStackParentData) {
      child.parentData = _WindowStackParentData();
    }
  }

  @override
  void performLayout() {
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(constraints, parentUsesSize: true);
      child = childAfter(child);
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
