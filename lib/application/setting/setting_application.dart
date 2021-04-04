import 'dart:ui';

import '../../container/window_container.dart';
import 'main_window.dart';

final settingApplication = WindowApplicationManifest(
  showInDesktop: true,
  applicationId: 'setting',
  applicationName: '设置',
  builder: () => WindowApplicationData(
    windows: {
      'main': (_) => WindowConfigureData(
            title: '设置',
            size: Size(400, 300),
            builder: (_) => MainWindow(),
          ),
    },
  ),
);
