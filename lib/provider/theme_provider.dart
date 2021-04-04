import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../container/window_container_theme.dart';
import '../storage/local_storage.dart';

/// 主题状态
class ThemeProvider extends ChangeNotifier {
  WindowContainerThemeData get theme => isDark == true
      ? WindowContainerThemeData.dark()
      : WindowContainerThemeData.light();

  bool? get isDark => LocalStorage.theme.isDark;

  set isDark(bool? value) {
    LocalStorage.theme.isDark = value;
    notifyListeners();
  }

  bool get showWallpaper => LocalStorage.theme.showWallpaper;

  set showWallpaper(bool value) {
    LocalStorage.theme.showWallpaper = value;
    notifyListeners();
  }

  static ThemeProvider read(BuildContext context) =>
      context.read<ThemeProvider>();

  static ThemeProvider watch(BuildContext context) =>
      context.watch<ThemeProvider>();
}
