import 'package:surrealdb_dart/surrealdb_dart.dart';
import 'package:test/test.dart';

void main() {
  final url = Uri.parse('ws://0.0.0.0:8080/rpc');

  test('create user', () async {
    final db = SurrealDB.connect(url, onConnected: (db) async {
      await db.use(namespace: 'surrealdb', database: 'dart');
    });
    final data = await db.create('user', data: {
      'firstname': 'Coulibaly',
      'lastname': 'Allou',
    });
    print(data.toString());
  });

  test('select user', () async {
    final db = SurrealDB.connect(url, onConnected: (db) async {
      await db.use(namespace: 'surrealdb', database: 'dart');
    });
    final data = await db.select('user');
    print(data.toString());
  });

  test('query user', () async {
    final db = SurrealDB.connect(url, onConnected: (db) async {
      return db.use(namespace: 'surrealdb', database: 'dart');
    });
    final data = await db.query('SELECT * FROM user;');
    print(data.toString());
  });

  test('update user', () async {
    final db = SurrealDB.connect(url, onConnected: (db) async {
      await db.use(namespace: 'surrealdb', database: 'dart');
    });
    final data = await db.merge('user', data: {'lastname': 'Flutter'});
    print(data.toString());
  });

  test('delete user', () async {
    final db = SurrealDB.connect(url, onConnected: (db) async {
      await db.use(namespace: 'surrealdb', database: 'dart');
    });
    final data = await db.delete('user');
    print(data.toString());
  });
}
