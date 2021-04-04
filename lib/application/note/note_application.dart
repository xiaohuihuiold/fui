import 'dart:ui';

import '../../container/window_container.dart';
import 'main_window.dart';

final noteApplication = WindowApplicationManifest(
  showInDesktop: true,
  applicationId: 'note',
  applicationName: '笔记',
  builder: () => WindowApplicationData(
    windows: {
      'main': (_) => WindowConfigureData(
            title: '笔记',
            size: Size(400, 300),
            builder: (_) => MainWindow(),
          ),
    },
  ),
);
