import 'dart:convert';

final class SurrealResponse {
  const SurrealResponse({
    required this.result,
    required this.action,
    required this.error,
    required this.id,
  });

  static const String resultKey = 'result';
  static const String actionKey = 'action';
  static const String errorKey = 'error';
  static const String idKey = 'id';

  final Object? result;
  final String? action;
  final Object? error;
  final String? id;

  SurrealResponse copyWith({
    Object? result,
    String? action,
    Object? error,
    String? id,
  }) {
    return SurrealResponse(
      result: result ?? this.result,
      action: action ?? this.action,
      error: error ?? this.error,
      id: id ?? this.id,
    );
  }

  SurrealResponse clone() {
    return copyWith(
      result: result,
      action: action,
      error: error,
      id: id,
    );
  }

  static SurrealResponse? fromMap(dynamic data) {
    if (data == null) return null;
    return SurrealResponse(
      result: data[resultKey],
      action: data[actionKey],
      error: data[errorKey],
      id: data[idKey],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      resultKey: result,
      actionKey: action,
      errorKey: error,
      idKey: id,
    }..removeWhere((key, value) => value == null);
  }

  static SurrealResponse fromJson(String source) {
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
