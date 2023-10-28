import 'package:websocket_universal/websocket_universal.dart';

import 'types.dart';

typedef SurrealCallback = Future<void> Function(SurrealDB db);

class SurrealDB {
  SurrealDB._(
    this._handler,
    SurrealCallback? callback,
  ) {
    if (callback != null) {
      _onConnected(callback);
    }
  }

  factory SurrealDB.connect(
    Uri url, {
    SurrealCallback? onConnected,
    Duration timeout = const Duration(seconds: 5),
  }) {
    final processor = SocketSimpleTextProcessor();
    final options = SocketConnectionOptions(
      timeoutConnectionMs: timeout.inMilliseconds,
    );
    final handler = IWebSocketHandler<String, String>.createClient(
      connectionOptions: options,
      url.toString(),
      processor,
    );
    return SurrealDB._(handler, onConnected);
  }

  final IWebSocketHandler<String, String> _handler;

  Stream<Response> get _messages {
    return _handler.incomingMessagesStream.asyncMap(
      ResponseExtension.fromJson,
    );
  }

  void _onConnected(SurrealCallback callback) {
    _handler.socketStateStream.listen((state) {
      if (state.status == SocketStatus.connected) {
        Future.microtask(() {
          return callback(this);
        });
      }
    });
  }

  Future<String> _request({
    required String method,
    List<Object?>? params,
  }) async {
    final connected = await _handler.connect();
    if (connected) {
      final id = shortHash(params);
      final data = await (
        method: method,
        params: params,
        id: id,
      ).toJson();
      _handler.sendMessage(data);
      return id;
    }
    throw Exception('no-connected');
  }

  Future<Response> _handle(String id) {
    return _messages.firstWhere((response) => response.id == id);
  }

  void close() => _handler.close();

  Future<void> use({
    required String namespace,
    required String database,
  }) async {
    final id = await _request(
      params: [namespace, database],
      method: 'use',
    );
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
  }

  Future<Object?> info() async {
    final id = await _request(method: 'info');
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
    return rs.result;
  }

  Future<String> signup({
    required String namespace,
    required String database,
    required String scope,
    Map<String, Object?>? data,
  }) async {
    final id = await _request(
      method: 'signup',
      params: [
        {
          'ns': namespace,
          'db': database,
          'sc': scope,
          ...?data,
        }
      ],
    );
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
    return rs.result as String;
  }

  Future<String> signin({
    String? namespace,
    String? database,
    String? scope,
    String? username,
    String? password,
    Map<String, Object?>? data,
  }) async {
    final id = await _request(
      method: 'signin',
      params: [
        {
          'ns': namespace,
          'db': database,
          'sc': scope,
          'user': username,
          'pass': password,
          if (data != null) ...data,
        }..removeWhere((key, value) => value == null),
      ],
    );
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
    return rs.result as String;
  }

  Future<void> authenticate(String token) async {
    final id = await _request(
      method: 'authenticate',
      params: [token],
    );
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
  }

  Future<void> invalidate() async {
    final id = await _request(method: 'invalidate');
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
  }

  Future<void> let(String variable, Object? value) async {
    final id = await _request(
      params: [variable, value],
      method: 'let',
    );
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
  }

  Future<void> unset(String variable) async {
    final id = await _request(
      params: [variable],
      method: 'unset',
    );
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
  }

  Future<String> live(String table) async {
    final id = await _request(
      params: [table],
      method: 'live',
    );
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
    return rs.result as String;
  }

  Stream<Object> listenLive(String queryUuid) {
    final messages = _messages.where((response) {
      return response.id == null && response.result != null;
    });
    final responses = messages.map((response) {
      return ResponseExtension.fromMap(response.result);
    });
    return responses.where((response) {
      return response.id == queryUuid;
    });
  }

  Future<void> kill(String queryUuid) async {
    final id = await _request(
      params: [queryUuid],
      method: 'kill',
    );
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
  }

  Future<List<Object?>?> query(String sql, {Object? vars}) async {
    final id = await _request(
      params: [sql, vars],
      method: 'query',
    );
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
    return ResponseExtension.fromList(rs.result!);
  }

  Future<Object> select(String thing) async {
    final id = await _request(
      params: [thing],
      method: 'select',
    );
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
    return rs.result!;
  }

  Future<Object> create(String thing, {Object? data}) async {
    final id = await _request(
      params: [thing, data],
      method: 'create',
    );
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
    return rs.result!;
  }

  Future<Object> insert(String thing, {Object? data}) async {
    final id = await _request(
      params: [thing, data],
      method: 'insert',
    );
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
    return rs.result!;
  }

  Future<Object> update(String thing, {Object? data}) async {
    final id = await _request(
      params: [thing, data],
      method: 'update',
    );
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
    return rs.result!;
  }

  Future<Object> merge(String thing, {Object? data}) async {
    final id = await _request(
      params: [thing, data],
      method: 'merge',
    );
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
    return rs.result!;
  }

  Future<Object> patch(String thing, {required List<Object> data, bool? diff}) async {
    final id = await _request(
      params: [thing, data, diff],
      method: 'patch',
    );
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
    return rs.result!;
  }

  Future<Object> delete(String thing) async {
    final id = await _request(
      params: [thing],
      method: 'delete',
    );
    final rs = await _handle(id);
    if (rs.error != null) throw rs.exception!;
    return rs.result!;
  }
}

class SurrealException {
  const SurrealException({
    required this.code,
    required this.message,
  });

  final int code;
  final String message;

  @override
  String toString() {
    return 'SurrealException(code: $code, message: $message)';
  }
}

extension on Response {
  SurrealException? get exception {
    if (error == null) return null;
    final data = error as Map<String, dynamic>;
    return SurrealException(
      message: data['message'],
      code: data['code'],
    );
  }
}
