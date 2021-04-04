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

  /// 应用图标
  final IconData? icon;
  final String? iconUrl;

  /// 窗口
  final Map<String, WindowBuilder> windows;

  WindowApplicationManifest({
    this.showInDesktop = false,
    required this.applicationId,
    required this.windows,
    required this.applicationName,
    this.icon,
    this.iconUrl,
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
  final bool showInDesktop;

  /// 应用id
  final String applicationId;

  /// 应用名称
  final String applicationName;

  /// 应用图标
  final IconData? icon;
  final String? iconUrl;

  /// 窗口
  final Map<String, WindowBuilder> windows;

  /// 任务id
  final String taskId;

  /// 容器
  final WindowContainerState _state;

  WindowApplicationData({
    required this.showInDesktop,
    required this.applicationId,
    required this.applicationName,
    required this.windows,
    required this.taskId,
    this.icon,
    this.iconUrl,
    required WindowContainerState state,
  }) : _state = state;

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
