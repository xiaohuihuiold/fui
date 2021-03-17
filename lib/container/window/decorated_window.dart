import 'package:flutter/material.dart';

import '../window_container.dart';

class DecoratedWindowContentDelegate extends SingleChildLayoutDelegate {
  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) => true;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    print(constraints);
    return super.getConstraintsForChild(constraints);
  }
}

/// 装饰窗口,对窗口进行添加边框样式等操作
class DecoratedWindow extends StatelessWidget {
  const DecoratedWindow({
    Key? key,
  }) : super(key: key);

  /// 包裹装饰
  Widget _wrapDecoration(
    BuildContext context,
    WindowConfiguration window,
    WindowContainerData windowContainer,
    Widget result,
  ) {
    // 边距
    result = Padding(
      padding: EdgeInsets.only(left: 2.0, top: 2.0, right: 2.0, bottom: 2.0),
      child: result,
    );
    result = Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: result,
    );
    // 标题栏
    result = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DecoratedWindowDraggable(child: DecoratedWindowTitleBar()),
          Divider(thickness: 1.0, height: 1.0),
          if (window.sizeMode == WindowSizeMode.auto)
            result
          else
            Expanded(child: result),
        ],
      ),
    );
    // 边框样式
    result = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .scaffoldBackgroundColor
            .withOpacity(windowContainer.topWindow == window ? 0.8 : 0.4),
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.4),
            blurRadius: 4.0,
          ),
        ],
      ),
      child: result,
    );
    return DecoratedWindowResizeable(child: result);
  }

  @override
  Widget build(BuildContext context) {
    WindowConfiguration window = WindowConfigureData.of(context).data;
    WindowContainerData windowContainer = WindowContainerData.of(context);
    Widget result = window.builder(context);
    if (window.hasDecoration) {
      result = _wrapDecoration(context, window, windowContainer, result);
    }
    return result;
  }
}

/// 标题栏
class DecoratedWindowTitleBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WindowConfiguration window = WindowConfigureData.of(context).data;
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    window.title,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
            ),
            if (window.hasMinimize)
              InkWell(
                onTap: () {
                  window.minimize();
                },
                child: Container(
                  width: 28.0,
                  child: Icon(
                    Icons.remove,
                    size: 16.0,
                  ),
                ),
              ),
            if (window.hasMaximize)
              InkWell(
                onTap: () {
                  window.maximize();
                },
                child: Container(
                  width: 28.0,
                  child: Icon(
                    window.sizeMode != WindowSizeMode.max
                        ? Icons.web_asset
                        : Icons.web,
                    size: 16.0,
                  ),
                ),
              ),
            InkWell(
              onTap: () {
                WindowContainer.of(context).close(window);
              },
              child: Container(
                width: 28.0,
                child: Icon(
                  Icons.close,
                  size: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 拖动控件
class DecoratedWindowDraggable extends StatelessWidget {
  final Widget child;

  const DecoratedWindowDraggable({
    Key? key,
    required this.child,
  }) : super(key: key);

  /// 拖动窗口,如果是全屏,则不能拖动
  void _drag(BuildContext context, Offset delta) {
    WindowConfiguration window = WindowConfigureData.of(context).data;
    if (window.sizeMode != WindowSizeMode.max) {
      window.drag(delta);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (detail) => _drag(context, detail.delta),
      child: child,
    );
  }
}

/// 改变大小控件
class DecoratedWindowResizeable extends StatefulWidget {
  final Widget child;

  const DecoratedWindowResizeable({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _DecoratedWindowResizeableState createState() =>
      _DecoratedWindowResizeableState();
}

class _DecoratedWindowResizeableState extends State<DecoratedWindowResizeable> {
  bool _resizeLeft = false;
  bool _resizeRight = false;
  bool _resizeBottom = false;
  MouseCursor _cursor = MouseCursor.defer;

  /// 设置当前缩放方向
  void _setScaleDir(WindowConfiguration window, Offset position) {
    _resizeLeft = false;
    _resizeRight = false;
    _resizeBottom = false;
    if ((!window.resizeable) || window.sizeMode == WindowSizeMode.max) {
      return;
    }
    Offset local = position;
    if (local.dx <= 4.0) {
      _resizeLeft = true;
    } else if (local.dx >= window.rect.width - 4.0) {
      _resizeRight = true;
    }
    if (local.dy >= window.rect.height - 4.0) {
      _resizeBottom = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    WindowConfiguration window = WindowConfigureData.of(context).data;
    return MouseRegion(
      cursor: _cursor,
      onExit: (_) {
        _cursor = MouseCursor.defer;
        setState(() {});
      },
      onHover: (event) {
        _setScaleDir(window, event.localPosition);
        _cursor = MouseCursor.defer;
        if (_resizeBottom) {
          _cursor = SystemMouseCursors.resizeUpDown;
        }
        if (_resizeLeft || _resizeRight) {
          _cursor = SystemMouseCursors.resizeLeftRight;
          if (_resizeBottom) {
            if (_resizeRight) {
              _cursor = SystemMouseCursors.resizeUpLeftDownRight;
            } else {
              _cursor = SystemMouseCursors.resizeUpRightDownLeft;
            }
          }
        }
        setState(() {});
      },
      child: GestureDetector(
        onPanCancel: () {
          _cursor = MouseCursor.defer;
          setState(() {});
        },
        onPanEnd: (_) {
          _cursor = MouseCursor.defer;
          setState(() {});
        },
        onPanDown: (detail) {
          _setScaleDir(window, detail.localPosition);
        },
        onPanUpdate: (detail) {
          Rect deltaRect = Rect.zero;
          if (_resizeLeft) {
            // 在左侧时
            deltaRect = Rect.fromLTRB(detail.delta.dx, 0.0, 0.0, 0.0);
          } else if (_resizeRight) {
            // 在右侧时
            deltaRect = Rect.fromLTRB(0.0, 0.0, detail.delta.dx, 0.0);
          }
          if (_resizeBottom) {
            // 在底部时
            deltaRect = Rect.fromLTRB(
              deltaRect.left,
              deltaRect.top,
              deltaRect.right,
              detail.delta.dy,
            );
          }
          if (deltaRect != Rect.zero) {
            window.resize(deltaRect);
          }
        },
        child: widget.child,
      ),
    );
  }
}
