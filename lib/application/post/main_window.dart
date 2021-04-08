import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../entity/post_entity.dart';
import '../../provider/manifest_provider.dart';
import '../../net/http_client.dart';
import '../../entity/manifest_entity.dart';

/// 文章主窗口
class MainWindow extends StatefulWidget {
  @override
  _MainWindowState createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  int? _currentId;
  Map<int, String?> _posts = {};

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
        Widget left = ListView.builder(
          itemCount: provider.data?.posts.length ?? 0,
          itemBuilder: (_, index) {
            PostEntity item = provider.data!.posts[index];
            return ListTile(
              leading: item.cover == null
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    )
                  : Image.network(item.withBasePath(item.cover!)),
              title: Text(item.title),
              subtitle: Text(item.description),
              onTap: () async {
                _currentId = item.id;
                setState(() {});
                if (_posts[item.id] != null) {
                  return;
                }
                _posts[item.id] = await provider.openPostById(item.id);
                setState(() {});
              },
            );
          },
        );
        Widget right = Container();
        if (_posts[_currentId] != null) {
          right = Markdown(
            data: _posts[_currentId]!,
            imageDirectory: 'data/posts/$_currentId/',
            onTapLink: (text, href, title) {
              html.window.open(href!, '_blank ');
            },
          );
        }
        return Row(
          children: [
            Container(width: 180, child: left),
            VerticalDivider(),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}
