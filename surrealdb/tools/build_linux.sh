if [ "$1" = "x64" ]; then
  rustup target add target x86_64-unknown-linux-gnu
  cargo build --target x86_64-unknown-linux-gnu --release
  mv "target/x86_64-unknown-linux-gnu/release/libsurrealdb_core.so" "libsurrealdb_core_linux_x64.so"
else
  rustup target add aarch64-unknown-linux-gnu
  cargo build --target aarch64-unknown-linux-gnu --release
  mkdir bin
  mv "target/aarch64-unknown-linux-gnu/release/libsurrealdb_core.so" "bin/libsurrealdb_core.so"
fi
