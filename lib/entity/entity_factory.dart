import 'package:flutter/material.dart';

import 'manifest_entity.dart';
import 'post_entity.dart';
import 'link_entity.dart';

typedef EntityBuilder = Object Function(Map json);

class EntityFactory {
  static Map<Type, EntityBuilder> _entities = {
    ManifestEntity: (json) => ManifestEntity.fromJson(json),
    PostEntity: (json) => PostEntity.fromJson(json),
    LinkEntity: (json) => LinkEntity.fromJson(json),
  };

  static T? create<T>(Map json) {
    Object? object;
    try {
      object = _entities[T]?.call(json);
    } catch (e) {
      debugPrint(e.toString());
    }
    if (object is T) {
      return object;
    } else {
      return null;
    }
  }
}
