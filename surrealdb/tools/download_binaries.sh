#!/bin/bash

if [ -z "$SURREALDB_VERSION" ]; then
    echo "SURREALDB_VERSION is not set";
    exit 2;
fi

github="https://github.com/surrealdb/surrealdb.flutter/releases/download/$SURREALDB_VERSION"

curl "${github}/libsurrealdb_android_arm64.so" -o packages/surrealdb_flutter_libs/android/src/main/jniLibs/arm64-v8a/libsurrealdb.so --create-dirs -L -f
curl "${github}/libsurrealdb_android_armv7.so" -o packages/surrealdb_flutter_libs/android/src/main/jniLibs/armeabi-v7a/libsurrealdb.so --create-dirs -L -f
curl "${github}/libsurrealdb_android_x64.so" -o packages/surrealdb_flutter_libs/android/src/main/jniLibs/x86_64/libsurrealdb.so --create-dirs -L

curl "${github}/surrealdb_ios.xcframework.zip" -o packages/surrealdb_flutter_libs/ios/surrealdb_ios.xcframework.zip --create-dirs -L -f
unzip -o packages/surrealdb_flutter_libs/ios/surrealdb_ios.xcframework.zip -d packages/surrealdb_flutter_libs/ios
rm packages/surrealdb_flutter_libs/ios/surrealdb_ios.xcframework.zip

curl "${github}/libsurrealdb_macos.dylib" -o packages/surrealdb_flutter_libs/macos/libsurrealdb.dylib --create-dirs -L -f
curl "${github}/libsurrealdb_linux_x64.so" -o packages/surrealdb_flutter_libs/linux/libsurrealdb.so --create-dirs -L -f
curl "${github}/surrealdb_windows_x64.dll" -o packages/surrealdb_flutter_libs/windows/surrealdb.dll --create-dirs -L -f

curl "${github}/surrealdb.wasm" -o surrealdb.wasm -L -f
