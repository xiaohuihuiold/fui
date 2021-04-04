import 'dart:ui';

import '../../container/window_container.dart';
import 'main_window.dart';

final postApplication = WindowApplicationManifest(
  showInDesktop: true,
  applicationId: 'post',
  applicationName: '文章',
  windows: {
    'main': (_) => WindowConfigureData(
          title: '文章',
          size: Size(500, 400),
          builder: (_) => MainWindow(),
        ),
  },
);
