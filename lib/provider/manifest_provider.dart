import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../net/http_client.dart';
import '../entity/manifest_entity.dart';
import '../entity/post_entity.dart';

class ManifestProvider extends ChangeNotifier {
  String _basePath = '/data';
  ManifestEntity? _manifestEntity;

  ManifestEntity? get data => _manifestEntity;

  Future<ManifestEntity?> load() async {
    if (_manifestEntity != null) {
      return _manifestEntity;
    }
    return await reload();
  }

  Future<ManifestEntity?> reload() async {
    HttpResponse response =
    await HttpClient.get<ManifestEntity>('$_basePath/manifest.json');
    _manifestEntity = response.entity;
    _manifestEntity?.basePath = _basePath;
    notifyListeners();
    return _manifestEntity;
  }

  Future<String?> openPostById(int id) async {
    await load();
    PostEntity? post = _manifestEntity?.getPostById(id);
    if (post == null) {
      return null;
    }
    HttpResponse response = await HttpClient.get(post.withBasePath(post.file));
    return response.data?.toString();
  }

  static ManifestProvider read(BuildContext context) =>
      context.read<ManifestProvider>();

  static ManifestProvider watch(BuildContext context) =>
      context.watch<ManifestProvider>();
}
