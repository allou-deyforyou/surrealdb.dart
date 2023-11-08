export MACOSX_DEPLOYMENT_TARGET=10.11

rustup target add aarch64-apple-darwin x86_64-apple-darwin
cargo build --target aarch64-apple-darwin --release
cargo build --target x86_64-apple-darwin --release

lipo "target/aarch64-apple-darwin/release/libsurrealdb_core.dylib" "target/x86_64-apple-darwin/release/libsurrealdb_core.dylib" -output "bin/libsurrealdb_core.dylib" -create
install_name_tool -id @rpath/libsurrealdb_core.dylib bin/libsurrealdb_core.dylib
