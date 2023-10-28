The Flutter SurrealDB package is a powerful integration for Flutter, built upon the foundation of surrealdb, the official SurrealDB library.

## Getting started

**❗ In order to start using surrealdb_dart you must have the [Flutter SDK][flutter_install_link] installed on your machine.**

Install via `flutter pub add`:

```sh
flutter pub add surrealdb_dart
```

Alternatively, add `surrealdb_dart` to your `pubspec.yaml`:

```yaml
dependencies:
  surrealdb_dart:
```

Install it:

```sh
flutter pub get
```

## Features

### `close()`

Closes the persistent connection to the database.

### `use({String namespace, String database})`

Switch to a specific namespace and database.

### `info()`

Retrieve info about the current Surreal instance.

### `signup({String namespace, String database, String scope,  Map<String, Object?>? data})`

Signs up to a specific authentication scope.

### `signin({String? namespace, String? database, String? scope, String? username, String? password Map<String, Object?>? data})`

Signs in to a specific authentication scope.

### `authenticate(String token)`

Authenticates the current connection with a JWT token.

### `invalidate()`

Invalidates the authentication for the current connection.

### `let(String variable, Object? value)`

Assigns a value as a parameter for this connection.

### `unset(String variable)`

Assigns a value as a parameter for this connection.

### `live(String table)`

Creates a stream queryUuid.

### `listenLive(String queryUuid)`

Listen a stream queryUuid.

### `kill(String queryUuid)`

Kill a stream queryUuid.

### `query(String sql, [Map<String, Object?>? vars])`

Runs a set of SurrealQL statements against the database.

### `select(String table)`

Selects all records in a table, or a specific record, from the database.

### `create(String thing, dynamic data)`

Creates a record in the database. `data` has to be json encodable object or `class` has `toJson` method.

### `insert(String thing, [Object? data])`

Updates all records in a table, or a specific record, in the database.

### `update(String thing, [Object? data])`

Updates all records in a table, or a specific record, in the database.
**_NOTE: This function replaces the current document / record data with the specified data._**

### `merge(String thing, [Object? data])`

Modifies all records in a table, or a specific record, in the database.
**_NOTE: This function merges the current document / record data with the specified data._**

### `patch(String thing, {List<Object> data, bool? diff})`

Applies JSON Patch changes to all records, or a specific record, in the database.
**_NOTE: This function patches the current document / record data with the specified JSON Patch data._**

### `delete(String thing)`

Deletes all records in a table, or a specific record, from the database.

## Usage

Here you have a simple example!

```dart
import 'package:surrealdb/surrealdb.dart';

void main() async {
  try {
    // Connect to the database
    final db = SurrealDB.connect(Uri.parse('wss://dei-surrealdb.fly.dev/rpc'));

    // Signin as a namespace, database, or root user
    await db.signin(
      username: "root",
      password: "root",
    );

    // Select a specific namespace / database
    await db.use(namespace: "test", database: "test");

    // Create a new person with a random id
    final created = await db.create("person", data: {
      'title': "Founder & CEO",
      'name': {
        'first': "Tobie",
        'last': "Morgan Hitchcock",
      },
      'marketing': true,
    });
    print(created);


    // Update a person record with a specific id
    final updated = await db.merge("person:jaime", data: {
      'marketing': true,
    });
    print(updated);


    // Select all people records
    final people = await db.select("person");
    print(people);

    // Perform a custom advanced query
    final groups = await db.query(
      "SELECT marketing, count() FROM type::table(\$tb) GROUP BY marketing",
      vars: {
        'tb': "person",
      },
    );
    print(groups);

  } catch (e) {
    print(e);
  }
}

```
