import '../entity/entity_factory.dart';
import '../ext/map_ext.dart';
import 'post_entity.dart';
import 'link_entity.dart';

class ManifestEntity {
  int version;
  int createTime;
  int lastUpdateTime;
  List<LinkEntity> links;
  List<PostEntity> posts;

  Map<int, PostEntity> _postIdMap = {};
  Map<String, List<PostEntity>> _postCategoryMap = {};
  Map<String, List<PostEntity>> _postTagMap = {};

  late String _basePath;

  String get basePath => _basePath;

  set basePath(String value) {
    _basePath = value;
    posts.forEach((post) {
      post.basePath = _basePath;
    });
  }

  ManifestEntity({
    required this.version,
    required this.createTime,
    required this.lastUpdateTime,
    required this.links,
    required this.posts,
  }) {
    posts.sort((a, b) {
      return b.lastUpdateTime.compareTo(a.lastUpdateTime);
    });
    posts.forEach((post) {
      _postIdMap[post.id] = post;
      if (post.category != null) {
        _postCategoryMap[post.category!] ??= [];
        _postCategoryMap[post.category!]!.add(post);
      }
      if (post.tags != null) {
        post.tags!.forEach((tag) {
          _postTagMap[tag] ??= [];
          _postTagMap[tag]!.add(post);
        });
      }
    });
  }

  PostEntity? getPostById(int id) {
    return _postIdMap[id];
  }

  List<PostEntity>? getPostsByCategory(String key) {
    return _postCategoryMap[key];
  }

  List<PostEntity>? getPostsByTag(String key) {
    return _postTagMap[key];
  }

  factory ManifestEntity.fromJson(Map json) {
    dynamic val;
    return ManifestEntity(
      version: json.getInt('version'),
      createTime: json.getInt('create_time'),
      lastUpdateTime: json.getInt('last_update_time'),
      links: json.getArray('links').map<LinkEntity>((e) {
        return EntityFactory.create<LinkEntity>(e)!;
      }).toList(),
      posts: json.getArray('posts').map<PostEntity>((e) {
        return EntityFactory.create<PostEntity>(e)!;
      }).toList(),
    );
  }
}
