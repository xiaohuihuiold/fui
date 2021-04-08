import 'dart:ui';

import 'package:flutter/material.dart';

import '../../container/window_container.dart';
import 'main_window.dart';

final linkApplication = WindowApplicationManifest(
  showInDesktop: true,
  applicationId: 'link',
  applicationName: '友链',
  icon: Icons.contacts,
  windows: {
    'main': (_) => WindowConfigureData(
      title: '友链',
      size: Size(300, 400),
      builder: (_) => MainWindow(),
    ),
  },
);
