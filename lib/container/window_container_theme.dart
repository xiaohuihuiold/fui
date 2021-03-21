import 'package:flutter/material.dart';

/// 容器主题
class WindowContainerThemeData {
  /// 窗口背景色
  final Color backgroundColor;

  factory WindowContainerThemeData.light() {
    return WindowContainerThemeData();
  }

  factory WindowContainerThemeData.dark() {
    return WindowContainerThemeData(
      backgroundColor: Colors.grey[700]!,
    );
  }

  const WindowContainerThemeData({
    this.backgroundColor = Colors.white,
  });

  WindowContainerThemeData copyWith({
    Color? backgroundColor,
  }) {
    return WindowContainerThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}

class WindowContainerTheme extends InheritedWidget {
  final WindowContainerThemeData theme;

  const WindowContainerTheme({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(key: key, child: child);

  static WindowContainerThemeData of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<WindowContainerTheme>()!
        .theme;
  }

  @override
  bool updateShouldNotify(WindowContainerTheme old) {
    return old.theme != theme;
  }
}
