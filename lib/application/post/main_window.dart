import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '/entity/post_entity.dart';
import '../../net/http_client.dart';
import '../../entity/manifest_entity.dart';

/// 文章主窗口
class MainWindow extends StatefulWidget {
  @override
  _MainWindowState createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  String _basePath = '/data';
  ManifestEntity? _manifestEntity;
  int? _currentId;
  Map<int, String?> _posts = {};

  Future<void> reload() async {
    HttpResponse response =
        await HttpClient.get<ManifestEntity>('$_basePath/manifest.json');
    _manifestEntity = response.entity;
    _manifestEntity?.basePath = _basePath;
    setState(() {});
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 180,
          child: ListView.builder(
            itemCount: _manifestEntity?.posts.length ?? 0,
            itemBuilder: (_, index) {
              PostEntity item = _manifestEntity!.posts[index];
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
                  HttpResponse response =
                      await HttpClient.get(item.withBasePath(item.file));
                  _posts[item.id] = response.data?.toString();
                  setState(() {});
                },
              );
            },
          ),
        ),
        VerticalDivider(),
        Expanded(
          child: _posts[_currentId] == null
              ? Container()
              : Markdown(
                  data: _posts[_currentId]!,
                  imageDirectory: 'data/posts/$_currentId/',
                  onTapLink: (text, href, title) {
                    html.window.open(href!, '_blank ');
                  },
                ),
        ),
      ],
    );
  }
}
