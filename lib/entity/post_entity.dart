import '../ext/map_ext.dart';

class PostEntity {
  int id;
  String type;
  String title;
  String description;
  String? cover;
  String file;
  int createTime;
  int lastUpdateTime;
  String? category;
  List<String>? tags;

  late String basePath;

  String get path => 'posts/$id';

  PostEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.cover,
    required this.file,
    required this.createTime,
    required this.lastUpdateTime,
    this.category,
    this.tags,
  });

  String withBasePath(String path) {
    return '$basePath/${withPath(path)}';
  }

  String withPath(String path) {
    return '${this.path}/$path';
  }

  factory PostEntity.fromJson(Map json) {
    dynamic value;
    return PostEntity(
      id: json.getInt('id'),
      type: json.getString('type'),
      title: json.getString('title'),
      description: json.getString('description'),
      cover: json.getStringOrNull('cover'),
      file: json.getString('file'),
      createTime: json.getInt('create_time'),
      lastUpdateTime: json.getInt('last_update_time'),
      category: json.getStringOrNull('category'),
      tags: json.getArrayOrNull('tags')?.cast<String>(),
    );
  }
}
