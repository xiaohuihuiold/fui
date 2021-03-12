import 'package:flutter/material.dart';

import '../window_container.dart';

/// 装饰窗口,对窗口进行添加边框样式等操作
class DecoratedWindow extends StatelessWidget {
  final WindowConfiguration window;

  const DecoratedWindow({
    Key? key,
    required this.window,
  }) : super(key: key);

  /// 包裹装饰
  Widget _wrapDecoration(Widget result) {
    result = Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: window.color,
        borderRadius: BorderRadius.circular(4.0),
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
    Widget result = window.builder(context);
    if (window.hasDecoration) {
      result = _wrapDecoration(result);
    }
    return result;
  }
}
