#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_PATH="$SCRIPT_DIR/build/ProxymanScriptGen.app"
LINK_PATH="/usr/local/bin/proxyman"

# Build if needed
if [ ! -d "$APP_PATH" ]; then
  echo "🔨 Building..."
  bash "$SCRIPT_DIR/build.sh"
fi

# Create launcher script
cat > /tmp/proxyman-launcher << EOF
#!/bin/bash
open "$APP_PATH"
EOF

chmod +x /tmp/proxyman-launcher

# Install to /usr/local/bin
if [ -f "$LINK_PATH" ] || [ -L "$LINK_PATH" ]; then
  echo "⚠️  $LINK_PATH already exists, replacing..."
  sudo rm -f "$LINK_PATH"
fi

sudo mv /tmp/proxyman-launcher "$LINK_PATH"
echo "✅ Installed! Run 'proxyman' from anywhere to open the app."
