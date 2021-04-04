import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider/theme_provider.dart';
import 'provider/screen_provider.dart';
import 'container/window_container.dart';

import 'application/note/note_application.dart';
import 'application/setting/setting_application.dart';
import 'application/post/post_application.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ThemeProvider()),
        Provider.value(value: ScreenProvider()),
      ],
      child: FlutterUi(),
    ),
  );
}

class FlutterUi extends StatefulWidget {
  @override
  _FlutterUiState createState() => _FlutterUiState();
}

class _FlutterUiState extends State<FlutterUi> {
  List<WindowApplicationManifest> _applications = [
    settingApplication,
    noteApplication,
    postApplication,
  ];

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = ThemeProvider.watch(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FUI',
      home: Scaffold(
        body: WindowContainer(
          theme: themeProvider.theme,
          applications: _applications,
        ),
      ),
    );
  }
}
