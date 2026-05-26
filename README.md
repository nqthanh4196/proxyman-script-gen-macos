# Proxyman Script Gen

Native macOS app tạo Proxyman mock response scripts từ JSON.  
Viết bằng Swift/SwiftUI — nhẹ, nhanh, không cần Electron hay Node.js.

![macOS](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)

## Quick Start

```bash
git clone https://github.com/nqthanh4196/proxyman-script-gen-macos.git
cd proxyman-script-gen-macos
./build.sh
open build/ProxymanScriptGen.app
```

## Install Command (mở từ mọi nơi)

```bash
./install.sh
```

Sau đó gõ `proxyman` ở bất kỳ terminal nào để mở app.

## Cách sử dụng

1. Paste JSON response cần mock vào ô input
2. Bấm **Generate** để tạo script
3. Bấm **Copy Script** để copy sang clipboard
4. Paste vào Proxyman (Menu > Scripts > Add Script)

## Build thủ công

```bash
# Debug build
swift build
open .build/debug/ProxymanScriptGen

# Release build (.app bundle)
./build.sh
```

## Yêu cầu

- macOS 13+
- Xcode Command Line Tools (`xcode-select --install`)

## License

MIT
