import 'package:flutter/material.dart';

/// TODO: 主题完善
/// 容器主题
class WindowContainerThemeData {
  final String fontFamily;

  /// 对比度
  final Brightness brightness;

  /// 窗口背景色
  final Color backgroundColor;

  /// 阴影颜色
  final Color shadowColor;

  /// 文本颜色
  final Color textColor;

  factory WindowContainerThemeData.light() {
    return WindowContainerThemeData();
  }

  factory WindowContainerThemeData.dark() {
    return WindowContainerThemeData(
      brightness: Brightness.dark,
      backgroundColor: Colors.grey[850]!,
      shadowColor: Colors.grey,
      textColor: Colors.white,
    );
  }

  const WindowContainerThemeData({
    this.fontFamily = 'PuHuiTi',
    this.brightness = Brightness.light,
    this.backgroundColor = Colors.white,
    this.shadowColor = Colors.grey,
    this.textColor = Colors.black,
  });

  WindowContainerThemeData copyWith({
    String? fontFamily,
    Brightness? brightness,
    Color? backgroundColor,
    Color? shadowColor,
    Color? textColor,
  }) {
    return WindowContainerThemeData(
      fontFamily: fontFamily ?? this.fontFamily,
      brightness: brightness ?? this.brightness,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shadowColor: shadowColor ?? this.shadowColor,
      textColor: textColor ?? this.textColor,
    );
  }
}

/// 容器主题共享
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
