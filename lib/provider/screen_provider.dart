import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// 屏幕状态
class ScreenProvider {
  bool isDesktop = true;

  static ScreenProvider read(BuildContext context) =>
      context.read<ScreenProvider>();
}
