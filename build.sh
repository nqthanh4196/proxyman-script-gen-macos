#!/bin/bash
set -e

echo "🔨 Building ProxymanScriptGen..."
swift build -c release

APP_NAME="ProxymanScriptGen"
APP_DIR="build/${APP_NAME}.app/Contents/MacOS"
mkdir -p "$APP_DIR"

cp ".build/release/${APP_NAME}" "$APP_DIR/"

cat > "build/${APP_NAME}.app/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>ProxymanScriptGen</string>
    <key>CFBundleIdentifier</key>
    <string>com.nqthanh4196.proxyman-script-gen</string>
    <key>CFBundleName</key>
    <string>Proxyman Script Gen</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "✅ Done! App created at: build/${APP_NAME}.app"
echo "🚀 Run: open build/${APP_NAME}.app"
