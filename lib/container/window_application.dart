part of 'window_container.dart';

/// 应用构造器
typedef WindowApplicationDataBuilder = WindowApplicationData Function();

/// 窗口构造器
typedef WindowBuilder = WindowConfigureData Function(dynamic arguments);

/// 应用清单
class WindowApplicationManifest {
  /// 是否展示桌面图标
  final bool showInDesktop;

  /// 应用id
  final String applicationId;

  /// 应用名称
  final String applicationName;

  /// 构造器
  final WindowApplicationDataBuilder builder;

  WindowApplicationManifest({
    this.showInDesktop = false,
    required this.applicationId,
    required this.applicationName,
    required this.builder,
  });
}

/// 窗口容器应用对外接口
abstract class WindowApplicationController {
  /// 打开新的窗口
  Future<T?> open<T>(String name);
}

/// 窗口应用数据
class WindowApplicationData implements WindowApplicationController {
  /// 是否展示桌面图标
  late bool showInDesktop;

  /// 应用id
  late String applicationId;

  /// 应用名称
  late String applicationName;

  /// 窗口
  final Map<String, WindowBuilder> windows;

  /// 任务id
  late String taskId;

  /// 容器
  late WindowContainerState _state;

  WindowApplicationData({
    required this.windows,
  });

  @override
  Future<T?> open<T>(String name, {dynamic arguments}) {
    WindowBuilder? builder = windows[name];
    if (builder == null) {
      return Future.value(null);
    }
    WindowConfigureData window = builder(arguments);
    window._group = taskId;
    return _state.open<T>(window);
  }
}

/// 共享当前应用
class WindowApplication extends InheritedWidget {
  final WindowApplicationData application;

  const WindowApplication({
    Key? key,
    required Widget child,
    required this.application,
  }) : super(key: key, child: child);

  static WindowApplicationData of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<WindowApplication>()!
        .application;
  }

  @override
  bool updateShouldNotify(WindowApplication old) {
    // TODO: 需要优化
    return true;
  }
}
