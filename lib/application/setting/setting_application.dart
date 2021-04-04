import 'dart:ui';

import 'package:flutter/material.dart';

import '../../container/window_container.dart';
import 'main_window.dart';

final settingApplication = WindowApplicationManifest(
  showInDesktop: true,
  applicationId: 'setting',
  applicationName: '设置',
  icon: Icons.settings,
  windows: {
    'main': (_) => WindowConfigureData(
          title: '设置',
          size: Size(300, 400),
          builder: (_) => MainWindow(),
        ),
  },
);
