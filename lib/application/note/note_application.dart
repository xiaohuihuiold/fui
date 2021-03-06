import 'dart:ui';

import 'package:flutter/material.dart';

import '../../container/window_container.dart';
import 'main_window.dart';

final noteApplication = WindowApplicationManifest(
  showInDesktop: true,
  applicationId: 'note',
  applicationName: '笔记',
  icon: Icons.note,
  windows: {
    'main': (_) => WindowConfigureData(
          title: '笔记',
          size: Size(500, 500),
          builder: (_) => MainWindow(),
        ),
  },
);
