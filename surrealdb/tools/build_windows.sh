if [ "$1" = "x64" ]; then
  rustup target add x86_64-pc-windows-msvc
  cargo build --target x86_64-pc-windows-msvc --release
  mv "target/x86_64-pc-windows-msvc/release/surrealdb_core.dll" "surrealdb_core.dll"
else
  rustup target add aarch64-pc-windows-msvc
  cargo build --target aarch64-pc-windows-msvc --release
  mkdir bin
  mv "target/aarch64-pc-windows-msvc/release/surrealdb_core.dll" "bin/surrealdb_core.dll"
fi
