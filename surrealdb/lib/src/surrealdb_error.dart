part of surrealdb;

sealed class SurrealDBError extends Error {
  String get message;
  @override
  String toString() {
    return '$runtimeType: $message';
  }
}

class SurrealDBNotReadyError extends SurrealDBError {
  SurrealDBNotReadyError(this.message);
  @override
  final String message;
}
