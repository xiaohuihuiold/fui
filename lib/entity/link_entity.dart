import '../ext/map_ext.dart';

class LinkEntity {
  String title;
  String url;
  int createTime;

  LinkEntity({
    required this.title,
    required this.url,
    required this.createTime,
  });

  factory LinkEntity.fromJson(Map json) {
    dynamic value;
    return LinkEntity(
      title: json.getString('title'),
      url: json.getString('url'),
      createTime: json.getInt('create_time'),
    );
  }
}
