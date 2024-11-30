extension SurrealStringExtension on String {
  String toSurrealQL() {
    return "'$this'";
  }
}

extension SurrealIntExtension on num {
  String toSurrealQL() {
    return "$this";
  }
}

extension SurrealBoolExtension on bool {
  String toSurrealQL() {
    return "$this";
  }
}

extension SurrealDateTimeExtension on DateTime {
  String toSurrealQL() {
    return "d'${toUtc().toIso8601String()}'";
  }
}

extension SurrealMapExtension on Map {
  String toSurrealQL() {
    return map((key, value) {
      return MapEntry(key, value.toSurrealQL());
    }).toString();
  }
}
