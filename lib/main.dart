import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider/theme_provider.dart';
import 'provider/screen_provider.dart';
import 'container/window_container.dart';

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
  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = ThemeProvider.watch(context);
    return MaterialApp(
      title: 'FUI',
      darkTheme: themeProvider.darkTheme,
      theme: themeProvider.theme,
      home: WindowContainer(),
    );
  }
}
