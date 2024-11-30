import 'dart:convert';

class SurrealRequest {
  const SurrealRequest({
    required this.params,
    required this.method,
    required this.id,
  });

  static const String schema = 'request';

  static const String paramsKey = 'params';
  static const String methodKey = 'method';
  static const String idKey = 'id';

  final List<Object?>? params;
  final String method;
  final String id;

  SurrealRequest copyWith({
    List<Object?>? params,
    String? method,
    String? id,
  }) {
    return SurrealRequest(
      params: params ?? this.params,
      method: method ?? this.method,
      id: id ?? this.id,
    );
  }

  SurrealRequest clone() {
    return copyWith(
      params: params,
      method: method,
      id: id,
    );
  }

  static SurrealRequest? fromMap(dynamic data) {
    if (data == null) return null;
    return SurrealRequest(
      params: data[paramsKey],
      method: data[methodKey],
      id: data[idKey],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      paramsKey: params,
      methodKey: method,
      idKey: id,
    }..removeWhere((key, value) => value == null);
  }

  static SurrealRequest fromJson(String source) {
    return fromMap(jsonDecode(source))!;
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  @override
  String toString() {
    return "$runtimeType(${toMap()})";
  }
}
