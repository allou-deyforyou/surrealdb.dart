import 'dart:convert';

import 'internal/response/response.dart';

enum SurrealLiveAction {
  close,
  create,
  update,
  delete;

  factory SurrealLiveAction.fromString(String value) {
    return switch (value) {
      'CLOSE' => close,
      'CREATE' => create,
      'UPDATE' => update,
      'DELETE' => delete,
      _ => throw 'no implement: $value',
    };
  }
}

class SurrealLiveResult {
  const SurrealLiveResult({
    required this.data,
    required this.action,
  });

  static const String actionKey = 'action';
  static const String dataKey = 'data';

  final SurrealLiveAction action;
  final dynamic data;

  factory SurrealLiveResult.fromResponse(SurrealResponse response) {
    return SurrealLiveResult(
      action: SurrealLiveAction.fromString(response.action!),
      data: response.result!,
    );
  }

  SurrealLiveResult copyWith({
    SurrealLiveAction? action,
    Object? data,
  }) {
    return SurrealLiveResult(
      action: action ?? this.action,
      data: data ?? this.data,
    );
  }

  SurrealLiveResult clone() {
    return copyWith(
      action: action,
      data: data,
    );
  }

  static SurrealLiveResult? fromMap(dynamic data) {
    if (data == null) return null;
    return SurrealLiveResult(
      action: SurrealLiveAction.fromString(data[actionKey]),
      data: data[dataKey],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      actionKey: action,
      dataKey: data,
    }..removeWhere((key, value) => value == null);
  }

  static SurrealLiveResult fromJson(String source) {
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
