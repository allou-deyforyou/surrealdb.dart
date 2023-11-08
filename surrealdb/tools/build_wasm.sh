rustup target add wasm32-unknown-unknown
cargo build --target wasm32-unknown-unknown --no-default-features -p surrealdb_core --release
mkdir bin
mv "target/wasm32-unknown-unknown/release/surrealdb_core.wasm" "bin/surrealdb_core.wasm"
