#!/bin/sh

cargo install cbindgen

cbindgen --config tools/cbindgen.toml --crate surrealdb_core --output src/surrealdb_core-dart.h

# cd packages/surrealdb_core

dart pub get
dart run ffigen --config ffigen.yaml
dart run ffigen --config ffigen_web.yaml
rm src/surrealdb_core-dart.h

dart tools/fix_web_bindings.dart

dart format --fix lib/src/native/bindings.dart
dart format  --fix lib/src/web/bindings.dart
