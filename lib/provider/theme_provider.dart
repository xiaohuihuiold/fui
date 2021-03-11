import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../storage/local_storage.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData? get darkTheme => isDark == null ? ThemeData.dark() : null;

  ThemeData get theme => isDark == true ? ThemeData.dark() : ThemeData.light();

  bool? get isDark => LocalStorage.theme.isDark;

  set isDark(bool? value) {
    LocalStorage.theme.isDark = value;
    notifyListeners();
  }

  static ThemeProvider read(BuildContext context) =>
      context.read<ThemeProvider>();

  static ThemeProvider watch(BuildContext context) =>
      context.watch<ThemeProvider>();
}
