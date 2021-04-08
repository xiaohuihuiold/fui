import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/manifest_provider.dart';
import '../../entity/link_entity.dart';

class MainWindow extends StatefulWidget {
  @override
  _MainWindowState createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    ManifestProvider.read(context).load();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManifestProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          itemCount: provider.data?.links.length ?? 0,
          itemBuilder: (_, index) {
            LinkEntity linkEntity = provider.data!.links[index];
            return ListTile(
              leading: CircleAvatar(),
              title: Text(linkEntity.title),
              subtitle: Text(linkEntity.url),
              onTap: () {
                html.window.open(linkEntity.url, '_blank ');
              },
            );
          },
        );
      },
    );
  }
}
