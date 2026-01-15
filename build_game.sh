#!/bin/bash
set -e

DO_UPLOAD=false
while getopts "u" opt; do
    case $opt in
        u) DO_UPLOAD=true ;;
    esac
done

GAME_NAME="TypeSkiier"
VERSION="0.1"
DIST_DIR="dist"
LOVE_FILE="$DIST_DIR/$GAME_NAME.love"
BUTLER="/Applications/butler/butler"

# Create dist directory
mkdir -p "$DIST_DIR"

# Clean previous builds
rm -rf "$DIST_DIR"/*

echo "Building $GAME_NAME v$VERSION..."

# Create .love file (exclude dist, git, and other non-game files)
echo "Creating .love file..."
zip -9 -r "$LOVE_FILE" . -x "dist/*" -x ".git/*" -x "*.sh" -x ".DS_Store" -x "*.md"

# Web build
echo "Building web version..."
echo "$GAME_NAME" | npx love.js "$LOVE_FILE" "$DIST_DIR/${GAME_NAME}_web" -c
zip -r "$DIST_DIR/${GAME_NAME}_${VERSION}_web.zip" "$DIST_DIR/${GAME_NAME}_web"

# macOS build
echo "Building macOS version..."
MAC_APP="$DIST_DIR/$GAME_NAME.app"
if [[ -d "/Applications/love.app" ]]; then
    LOVE_APP="/Applications/love.app"
elif [[ -d "$HOME/Applications/love.app" ]]; then
    LOVE_APP="$HOME/Applications/love.app"
else
    echo "Warning: love.app not found, skipping macOS build"
    LOVE_APP=""
fi

if [[ -n "$LOVE_APP" ]]; then
    cp -r "$LOVE_APP" "$MAC_APP"
    cp "$LOVE_FILE" "$MAC_APP/Contents/Resources/"
    # Update Info.plist with game name (optional)
    /usr/libexec/PlistBuddy -c "Set :CFBundleName $GAME_NAME" "$MAC_APP/Contents/Info.plist" 2>/dev/null || true
    zip -r "$DIST_DIR/${GAME_NAME}_${VERSION}_macos.zip" "$MAC_APP"
fi

# Windows build (requires love win64 binaries)
echo "Building Windows version..."
WIN_DIR="$DIST_DIR/${GAME_NAME}_win"
LOVE_WIN_DIR="love-win64"  # Download from love2d.org and place here

if [[ -d "$LOVE_WIN_DIR" ]]; then
    mkdir -p "$WIN_DIR"
    cp "$LOVE_WIN_DIR"/*.dll "$WIN_DIR/"
    cp "$LOVE_WIN_DIR/license.txt" "$WIN_DIR/" 2>/dev/null || true
    cat "$LOVE_WIN_DIR/love.exe" "$LOVE_FILE" > "$WIN_DIR/$GAME_NAME.exe"
    zip -r "$DIST_DIR/${GAME_NAME}_${VERSION}_windows.zip" "$WIN_DIR"
else
    echo "Warning: $LOVE_WIN_DIR not found, skipping Windows build"
    echo "Download from: https://love2d.org/ and extract to $LOVE_WIN_DIR/"
fi

echo "Build complete! Output in $DIST_DIR/"
ls -lh "$DIST_DIR"/*.zip 2>/dev/null || echo "No zip files created"

# Upload to itch.io
if [[ "$DO_UPLOAD" == true ]]; then
    if [[ -x "$BUTLER" ]]; then
        ITCH_USER="dendrobyte"
        ITCH_GAME="typeskiier"

        echo "Uploading to itch.io..."
        "$BUTLER" push "$DIST_DIR/${GAME_NAME}_${VERSION}_web.zip" "$ITCH_USER/$ITCH_GAME:web"
        "$BUTLER" push "$DIST_DIR/${GAME_NAME}_${VERSION}_macos.zip" "$ITCH_USER/$ITCH_GAME:osx-universal"
        "$BUTLER" push "$DIST_DIR/${GAME_NAME}_${VERSION}_windows.zip" "$ITCH_USER/$ITCH_GAME:windows"
        echo "Upload complete!"
    else
        echo "Error: butler not found at $BUTLER"
        echo "Install from: https://itch.io/docs/butler/"
        exit 1
    fi
fi