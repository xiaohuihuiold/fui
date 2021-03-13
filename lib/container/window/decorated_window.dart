import 'package:flutter/material.dart';

import '../window_container.dart';

/// 装饰窗口,对窗口进行添加边框样式等操作
class DecoratedWindow extends StatelessWidget {
  const DecoratedWindow({
    Key? key,
  }) : super(key: key);

  /// 包裹装饰
  Widget _wrapDecoration(WindowConfiguration window, Widget result) {
    // 边距
    result = Padding(
      padding: EdgeInsets.only(left: 1.0, top: 0.0, right: 1.0, bottom: 1.0),
      child: result,
    );
    // 标题栏
    result = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DecoratedWindowTitleBar(),
          Divider(thickness: 1.0, height: 1.0),
          Container(child: result),
        ],
      ),
    );
    // 边框样式
    result = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: window.color,
        borderRadius: BorderRadius.circular(2.0),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.4), blurRadius: 4.0),
        ],
      ),
      child: result,
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    WindowConfiguration window = WindowConfigureData.of(context).data;
    Widget result = window.builder(context);
    if (window.hasDecoration) {
      result = _wrapDecoration(window, result);
    }
    return result;
  }
}

class DecoratedWindowTitleBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WindowConfiguration window = WindowConfigureData.of(context).data;
    return Container(
      height: 18.0,
      alignment: Alignment.center,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Center(child: Text(window.title))),
            if (window.hasMinimize)
              InkWell(
                onTap: () {
                  window.sizeMode = WindowSizeMode.min;
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
                  if (window.sizeMode != WindowSizeMode.max) {
                    window.sizeMode = WindowSizeMode.max;
                  } else {
                    window.sizeMode = window.preSizeMode;
                  }
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
