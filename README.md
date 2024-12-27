cargo install flutter_rust_bridge_codegen --version 1.80.1 --features uuid
flutter pub get
flutter_rust_bridge_codegen --rust-input ./src/flutter_ffi.rs --dart-output ./lib/generated_bridge.dart --llvm-path D:\WorlkSoftware\LLVM
cargo build --features flutter
cargo run 
flutter run

CMakeLists (line:102)

# Certificate、Sign
New-SelfSignedCertificate -Type Custom -Subject "CN=Contoso Software, O=Contoso Corporation, C=CN" -KeyUsage DigitalSignature -FriendlyName "yuanhong" -CertStoreLocation "Cert:\CurrentUser\My" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")

$password = ConvertTo-SecureString -String yuanhong -Force -AsPlainText
Export-PfxCertificate -cert "Cert:\CurrentUser\My\59384DA3ABAF8708F958B97177F933447C2EA626" -FilePath E:\Certificate\CertStoreLocation.pfx -Password $password 

SignTool sign /fd SHA256 E:\WorkPlace\Flutter\trade\build\windows\x64\runner\Release\trade.msix
SignTool sign /fd sha256 /a /f E:\Certificate\CertStoreLocation.pfx /p yuanhong E:\WorkPlace\Flutter\trade\build\windows\x64\runner\Release\trade.msix
