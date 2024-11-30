import 'dart:async';
import 'dart:developer';

import 'package:web_socket_client/web_socket_client.dart';

import 'live.dart';
import 'exception.dart';
import 'internal/hash.dart';
import 'internal/request.dart';
import 'internal/response/query.dart';
import 'internal/response/response.dart';

typedef SurrealCreatedCallback = Future<bool> Function(Surreal db);

class Surreal {
  Surreal.connect(
    this.uri, {
    this.timeout,
    this.debug = true,
    Map<String, dynamic>? headers,
    SurrealCreatedCallback? prepare,
  })  : _messageController = StreamController<SurrealResponse>.broadcast(),
        _prepareController = StreamController<bool>.broadcast(),
        _prepareCompleter = Completer<bool>(),
        _prepareCallback = prepare,
        _socket = WebSocket(
          protocols: ['rpc'],
          headers: headers,
          timeout: timeout,
          uri,
        ) {
    _socket.messages.asyncMap(_onMessage).listen(
          onDone: _messageController.close,
          _messageController.add,
          cancelOnError: true,
        );
    _openConnection();
  }

  final Uri uri;
  final bool debug;
  final Duration? timeout;
  final WebSocket _socket;
  final SurrealCreatedCallback? _prepareCallback;

  Completer<bool> _prepareCompleter;
  final StreamController<bool> _prepareController;

  StreamSubscription? _connectionSubscription;

  final StreamController<SurrealResponse> _messageController;

  Future<bool> _onConnectionState(ConnectionState state) async {
    void complete(bool done) {
      if (_prepareCompleter.isCompleted) {
        _prepareCompleter = Completer<bool>();
      }
      _prepareCompleter.complete(done);
      _prepareController.add(done);
    }

    bool done = false;
    switch (state) {
      case const Connected():
      case const Reconnected():
        try {
          done = await _prepareCallback?.call(this) ?? true;
        } finally {
          complete(done);
        }
        break;
      case const Disconnected():
        complete(done);
        break;
    }
    return done;
  }

  Future<SurrealResponse> _onMessage(dynamic data) async {
    if (debug) log('Response($data);', name: 'Surreal');
    return SurrealResponse.fromJson(data);
  }

  void _openConnection() {
    _onConnectionState(
      _socket.connection.state,
    );
    _connectionSubscription = _socket.connection.listen(
      _onConnectionState,
    );
  }

  void close() {
    _connectionSubscription?.cancel();
    _prepareController.close();
    _socket.close();
  }

  Stream<bool> get connection {
    final controller = StreamController<bool>();
    controller.onListen = () async {
      final done = await wait();
      controller.add(done);
      final subscription = _prepareController.stream.listen(
        onDone: controller.close,
        cancelOnError: true,
        controller.add,
      );
      controller.onResume = subscription.resume;
      controller.onCancel = subscription.cancel;
      controller.onPause = subscription.pause;
    };
    return controller.stream;
  }

  Future<bool> wait({Duration? timeout}) async {
    late bool done;
    timeout ??= this.timeout;
    final future = _prepareCompleter.future;
    if (timeout != null) {
      done = await future.timeout(onTimeout: () => false, timeout);
    } else {
      done = await future;
    }
    if (done == false) {
      done = await _onConnectionState(
        _socket.connection.state,
      );
    }
    return done;
  }

  Future<String> _request({
    required String method,
    List<Object?>? params,
  }) async {
    final id = shortHash(params);
    final request = SurrealRequest(
      method: method,
      params: params,
      id: id,
    );
    final data = request.toJson();
    if (debug) log('Request($data);', name: 'Surreal');
    _socket.send(data);
    return id;
  }

  Future<SurrealResponse> _handle(String id) {
    return _messageController.stream.firstWhere((response) {
      return response.id == id;
    });
  }

  Future<void> use({
    required String namespace,
    required String database,
  }) async {
    final id = await _request(
      params: [namespace, database],
      method: 'use',
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
  }

  Future<dynamic> info() async {
    final id = await _request(method: 'info');
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
    return response.result;
  }

  Future<dynamic> version() async {
    final id = await _request(method: 'version');
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
    return response.result;
  }

  Future<String> signup({
    required String namespace,
    required String database,
    required String access,
    Map<String, Object?>? data,
  }) async {
    final id = await _request(
      method: 'signup',
      params: [
        {
          'ns': namespace,
          'db': database,
          'ac': access,
          ...?data,
        }
      ],
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
    return response.result as String;
  }

  Future<String> signin({
    String? namespace,
    String? database,
    String? access,
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
          'ac': access,
          'user': username,
          'pass': password,
          if (data != null) ...data,
        }..removeWhere((key, value) => value == null),
      ],
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
    return response.result as String;
  }

  Future<void> authenticate(String token) async {
    final id = await _request(
      method: 'authenticate',
      params: [token],
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
  }

  Future<void> invalidate() async {
    final id = await _request(method: 'invalidate');
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
  }

  Future<void> let(String variable, dynamic value) async {
    final id = await _request(
      params: [variable, value],
      method: 'let',
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
  }

  Future<void> unset(String variable) async {
    final id = await _request(
      params: [variable],
      method: 'unset',
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
  }

  Future<String> live(String table) async {
    final id = await _request(
      params: [table],
      method: 'live',
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
    return response.result as String;
  }

  Stream<SurrealLiveResult> listenLive(String queryUuid) {
    final messages = _messageController.stream.where((response) {
      return response.id == null && response.result != null;
    });
    final responses = messages.map((response) {
      return SurrealResponse.fromMap(response.result)!;
    });
    return responses.where((response) {
      return response.id == queryUuid;
    }).asyncMap(SurrealLiveResult.fromResponse);
  }

  Future<void> kill(String queryUuid) async {
    final id = await _request(
      params: [queryUuid],
      method: 'kill',
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
  }

  Future<List<dynamic>> query(String sql, {Map<String, dynamic>? vars}) async {
    final id = await _request(
      params: [sql, vars],
      method: 'query',
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
    final queryResponses = SurrealQueryResponse.fromListSurrealResponse(response.result!);
    for (final response in queryResponses) {
      if (response.hasError!) {
        throw SurrealException(
          message: response.result,
          code: -1,
        );
      }
    }
    return List.of(queryResponses.map((item) => item.result));
  }

  Future<dynamic> run(
    String funcName, {
    String? version,
    List<dynamic>? args,
  }) async {
    final id = await _request(
      params: [funcName, version, args]..removeWhere((item) => item == null),
      method: 'run',
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
    return response.result;
  }

  Future<dynamic> select(String thing) async {
    final id = await _request(
      params: [thing],
      method: 'select',
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
    return response.result;
  }

  Future<dynamic> create(String thing, {Map<String, dynamic>? data}) async {
    final id = await _request(
      params: [thing, data],
      method: 'create',
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
    return response.result;
  }

  Future<dynamic> insert(String thing, {Map<String, dynamic>? data}) async {
    final id = await _request(
      params: [thing, data],
      method: 'insert',
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
    return response.result;
  }

  Future<dynamic> insertBulk(String table, {required List<Map<String, dynamic>> data}) async {
    final id = await _request(
      params: [table, data],
      method: 'insert',
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
    return response.result;
  }

  Future<dynamic> update(String thing, {Map<String, dynamic>? data}) async {
    final id = await _request(
      params: [thing, data],
      method: 'update',
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
    return response.result;
  }

  Future<dynamic> upsert(String thing, {Map<String, dynamic>? data}) async {
    final id = await _request(
      params: [thing, data],
      method: 'upsert',
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
    return response.result;
  }

  Future<dynamic> relate({
    required String from,
    required String thing,
    required String to,
    Map<String, dynamic>? data,
  }) async {
    final id = await _request(
      params: [from, thing, to, data]..removeWhere((value) => value == null),
      method: 'relate',
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
    return response.result;
  }

  Future<dynamic> merge(String thing, {Map<String, dynamic>? data}) async {
    final id = await _request(
      params: [thing, data],
      method: 'merge',
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
    return response.result;
  }

  Future<dynamic> patch(String thing, {required List<Map<String, dynamic>> data, bool? diff}) async {
    final id = await _request(
      params: [thing, data, diff],
      method: 'patch',
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
    return response.result;
  }

  Future<dynamic> delete(String thing) async {
    final id = await _request(
      params: [thing],
      method: 'delete',
    );
    final response = await _handle(id);
    if (response.error != null) throw SurrealException.fromResponse(response);
    return response.result;
  }
}
