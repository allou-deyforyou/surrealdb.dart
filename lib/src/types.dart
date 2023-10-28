import 'dart:convert';
import 'dart:isolate';

String shortHash(Object? object) {
  return object.hashCode.toUnsigned(20).toRadixString(16).padLeft(5, '0');
}

typedef Request = ({
  String id,
  String method,
  List<Object?>? params,
});

extension RequestExtension on Request {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'method': method,
      'params': params,
    }..removeWhere((key, value) => value == null);
  }

  Future<String> toJson() {
    return Isolate.run(() => jsonEncode(toMap()));
  }
}

typedef Response = ({
  String? id,
  String? action,
  Object? result,
  Object? error,
});

extension ResponseExtension on Response {
  static Response fromMap(dynamic data) {
    return (
      id: data['id'],
      action: data['action'],
      result: data['result'],
      error: data['error'],
    );
  }

  static Future<Response> fromJson(String source) {
    return Isolate.run(() => fromMap(jsonDecode(source)));
  }

  static Future<List<Object?>> fromList(Object data) async {
    return List.of((data as List).map((data) => fromMap(data).result));
  }
}
