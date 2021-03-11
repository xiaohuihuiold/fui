import 'package:flutter/material.dart';

import 'window_container.dart';

/// 装饰窗口,对窗口进行添加边框样式等操作
class DecoratedWindow extends StatelessWidget {
  final WindowConfiguration window;

  const DecoratedWindow({
    Key? key,
    required this.window,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget result = window.builder(context);
    return result;
  }
}
