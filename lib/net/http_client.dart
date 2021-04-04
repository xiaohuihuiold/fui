import 'dart:async';
import 'dart:convert';
import 'dart:html';

import '../entity/entity_factory.dart';

class HttpResponse<T> {
  final int status;
  final String message;
  final Object? data;
  final T? entity;

  HttpResponse({
    required this.status,
    required this.message,
    this.data,
    this.entity,
  });

  @override
  String toString() {
    return 'HttpResponse(status:$status, message:$message, data:$data)';
  }
}

class HttpClient {
  static Future<HttpResponse<T>> get<T>(String url) {
    return _fetch<T>('get', url);
  }

  static HttpResponse<T> _parseResponse<T>(HttpRequest httpRequest) {
    int status = -1;
    String message = 'unknown';
    Object? data;
    String? responseText = httpRequest.responseText;
    T? entity;
    if (httpRequest.status != null) {
      status = httpRequest.status!;
    }
    if (httpRequest.statusText != null) {
      message = httpRequest.statusText!;
    }
    if (responseText != null) {
      try {
        switch (httpRequest.getResponseHeader('content-type')) {
          case 'application/json':
            data = json.decode(responseText);
            break;
          default:
            data = httpRequest.response;
            break;
        }
      } catch (e) {}
    }
    if (data is Map) {
      entity = EntityFactory.create<T>(data);
    }
    return HttpResponse<T>(
      status: status,
      message: message,
      data: data,
      entity: entity,
    );
  }

  static Future<HttpResponse<T>> _fetch<T>(String method, String url) {
    Completer<HttpResponse<T>> completer = Completer();
    HttpRequest.request(url, method: 'get').then(
      (value) {
        if (!completer.isCompleted) {
          completer.complete(_parseResponse<T>(value));
        }
      },
      onError: completer.completeError,
    );
    return completer.future;
  }
}
