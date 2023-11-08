import 'dart:io';
import 'dart:ffi';
import 'dart:async';

import 'package:surrealdb/surrealdb.dart';

import 'ffi/native_bindings.dart';

const _libName = 'surrealdb_core';

FutureOr<SurrealDBCoreBindings> initializePlatformBindings([String? library]) {
  try {
    final DynamicLibrary dylib = () {
      if (Platform.isMacOS || Platform.isIOS) {
        return DynamicLibrary.open('bin/lib$_libName.dylib');
      }
      if (Platform.isAndroid || Platform.isLinux) {
        return DynamicLibrary.open('bin/lib$_libName.so');
      }
      if (Platform.isWindows) {
        return DynamicLibrary.open('bin/$_libName.dll');
      }
      throw SurrealDBNotReadyError('Unknown platform: ${Platform.operatingSystem}');
    }();

    final bindings = SurrealDBCoreBindings(dylib);

    print(bindings.add(1, 3));

    return bindings;
  } catch (e) {
    throw SurrealDBNotReadyError(
      'Could not initialize SurrealDBCore library for processor architecture '
      '"${Abi.current()}". If you create a Flutter app, make sure to add '
      'isar_flutter_libs to your dependencies. For Dart-only apps or unit '
      'tests, make sure to place the correct Isar binary in the correct '
      'directory.\n$e',
    );
  }
}
