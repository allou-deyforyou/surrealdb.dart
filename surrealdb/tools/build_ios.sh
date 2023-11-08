export IPHONEOS_DEPLOYMENT_TARGET=11.0

rustup target add aarch64-apple-ios aarch64-apple-ios-sim x86_64-apple-ios
cargo build --target aarch64-apple-ios --release
cargo build --target aarch64-apple-ios-sim --release
cargo build --target x86_64-apple-ios --release

lipo "target/aarch64-apple-ios-sim/release/libsurrealdb_core.a" "target/x86_64-apple-ios/release/libsurrealdb_core.a" -output "target/aarch64-apple-ios-sim/libsurrealdb_core.a" -create
xcodebuild \
    -create-xcframework \
    -library target/aarch64-apple-ios/release/libsurrealdb_core.a \
    -library target/aarch64-apple-ios-sim/libsurrealdb_core.a \
    -output surrealdb_core.xcframework 

zip -r surrealdb_core_ios.xcframework.zip surrealdb_core.xcframework
mkdir bin
mv "surrealdb_core.xcframework" "bin/surrealdb_core_ios_arm64.xcframework"
rm surrealdb_core_ios.xcframework.zip
