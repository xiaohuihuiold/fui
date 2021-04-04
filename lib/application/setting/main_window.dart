import 'package:flutter/material.dart';
import '/provider/theme_provider.dart';

/// 设置主窗口
class MainWindow extends StatefulWidget {
  @override
  _MainWindowState createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = ThemeProvider.watch(context);
    return Column(
      children: [
        CheckboxListTile(
          tristate: false,
          value: themeProvider.isDark,
          title: Text('暗黑模式'),
          subtitle: Text(() {
            if (themeProvider.isDark == true) {
              return '暗黑模式开启';
            } else if (themeProvider.isDark == false) {
              return '暗黑模式关闭';
            } else {
              return '跟随系统';
            }
          }()),
          onChanged: (value) {
            themeProvider.isDark = value;
          },
        ),
        CheckboxListTile(
          tristate: false,
          value: themeProvider.showWallpaper,
          title: Text('壁纸'),
          subtitle: Text(() {
            if (themeProvider.showWallpaper == true) {
              return '壁纸开启';
            } else {
              return '壁纸关闭';
            }
          }()),
          onChanged: (value) {
            themeProvider.showWallpaper = value == true;
          },
        ),
      ],
    );
  }
}
