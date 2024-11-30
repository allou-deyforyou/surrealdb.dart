import 'internal/response/response.dart';

class SurrealException {
  const SurrealException({
    required this.code,
    required this.message,
  });

  final int code;
  final String message;

  factory SurrealException.fromResponse(SurrealResponse response) {
    final data = response.error as Map<String, dynamic>;
    return SurrealException(
      message: data['message'],
      code: data['code'],
    );
  }

  @override
  String toString() {
    return 'SurrealException(code: $code, message: $message)';
  }
}
