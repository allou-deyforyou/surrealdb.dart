import 'dart:convert';

final class SurrealQueryResponse {
  const SurrealQueryResponse({
    required this.result,
    required this.hasError,
    required this.id,
  });

  static const String resultKey = 'result';
  static const String hasErrorKey = 'status';
  static const String idKey = 'id';

  final dynamic result;
  final bool? hasError;
  final String? id;

  SurrealQueryResponse copyWith({
    Object? result,
    bool? hasError,
    String? id,
  }) {
    return SurrealQueryResponse(
      result: result ?? this.result,
      hasError: hasError ?? this.hasError,
      id: id ?? this.id,
    );
  }

  SurrealQueryResponse clone() {
    return copyWith(
      result: result,
      hasError: hasError,
      id: id,
    );
  }

  static SurrealQueryResponse? fromMap(dynamic data) {
    if (data == null) return null;
    return SurrealQueryResponse(
      hasError: data[hasErrorKey] == 'ERR',
      result: data[resultKey],
      id: data[idKey],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      resultKey: result,
      hasErrorKey: hasError,
      idKey: id,
    }..removeWhere((key, value) => value == null);
  }

  static SurrealQueryResponse fromJson(String source) {
    return fromMap(jsonDecode(source))!;
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  static List<SurrealQueryResponse> fromListSurrealResponse(dynamic data) {
    return List<SurrealQueryResponse>.from(data.map<SurrealQueryResponse?>(SurrealQueryResponse.fromMap));
  }

  @override
  String toString() {
    return "$runtimeType(${toMap()})";
  }
}
