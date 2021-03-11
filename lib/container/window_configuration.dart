part of 'window_container.dart';

/// 窗口配置
class WindowConfiguration extends ChangeNotifier {
  Key _key = UniqueKey();

  /// 是否含有标题栏
  final bool hasTitleBar;

  /// 是否含有最大化按钮
  final bool hasMaximize;

  /// 是否含有最小化按钮
  final bool hasMinimize;

  /// 窗口组
  String? _group;

  String? get group => _group;

  /// 窗口标题
  String _title;

  String get title => _title;

  set title(String value) {
    if (_title != value) {
      _title = value;
      notifyListeners();
    }
  }

  /// 窗口颜色,主要是标题栏
  Color _color;

  Color get color => _color;

  set color(Color value) {
    if (_color != value) {
      _color = value.withOpacity(value.opacity.clamp(0.5, 1.0));
      notifyListeners();
    }
  }

  /// 组件构造器
  final WidgetBuilder builder;

  WindowConfiguration({
    required String title,
    String? group,
    Color? color,
    this.hasTitleBar = true,
    this.hasMaximize = true,
    this.hasMinimize = true,
    required this.builder,
  })   : _title = title,
        _group = group,
        _color = color ?? Colors.white.withOpacity(0.5);
}

/// 共享当前窗口设置
class WindowConfigureData extends InheritedWidget {
  final WindowConfiguration data;

  const WindowConfigureData({
    required Key key,
    required Widget child,
    required this.data,
  }) : super(key: key, child: child);

  static WindowConfigureData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WindowConfigureData>()!;
  }

  @override
  bool updateShouldNotify(WindowConfigureData old) {
    return data != old.data;
  }
}
