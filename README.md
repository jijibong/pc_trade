cargo install flutter_rust_bridge_codegen --version 1.80.1 --features uuid
flutter pub get
flutter_rust_bridge_codegen --rust-input ./src/flutter_ffi.rs --dart-output ./lib/generated_bridge.dart --llvm-path D:\WorlkSoftware\LLVM
cargo build --features flutter
cargo run 
flutter run