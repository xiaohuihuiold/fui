import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ScreenProvider {
  bool isDesktop = true;

  static ScreenProvider read(BuildContext context) =>
      context.read<ScreenProvider>();
}
