#!/usr/bin/env bash
# Builds the macOS app and packs it into a .dmg — free, no Apple account.
#
#   tool/build_macos_dmg.sh
#   tool/build_macos_dmg.sh --skip-build     # reuse the last build
#
# Run it on a Mac. The result is dist/<name>-<version>.dmg: open it, drag the
# app onto Applications.
#
# THE CATCH. Without Apple's paid Developer Program there is no Developer ID
# certificate, so the app cannot be notarised, and macOS shows «cannot verify
# the developer» the first time. Whoever installs it opens System Settings →
# Privacy & Security and clicks «Open Anyway» once (Apple: support.apple.com
# /en-us/102445). docs/DESKTOP_SETUP.md has the notarising steps for when you
# do join — the same script plus `codesign` and `xcrun notarytool`.
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ "$(uname)" != "Darwin" ]]; then
  echo "The .dmg is built on a Mac." >&2
  exit 1
fi

name="$(sed -n 's/^name: *//p' pubspec.yaml | head -1 | tr -d '[:space:]')"
version="$(sed -n 's/^version: *//p' pubspec.yaml | head -1 | sed 's/+.*//' | tr -d '[:space:]')"

if [[ "${1:-}" != "--skip-build" ]]; then
  flutter build macos --release
fi

app="$(find build/macos/Build/Products/Release -maxdepth 1 -name '*.app' | head -1)"
if [[ -z "$app" ]]; then
  echo "No .app under build/macos/Build/Products/Release. Run without --skip-build." >&2
  exit 1
fi

mkdir -p dist
out="dist/${name}-${version}.dmg"
rm -f "$out"

# A folder holding the app and a link to /Applications: the «drag it across»
# window people know.
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT
cp -R "$app" "$stage/"
ln -s /Applications "$stage/Applications"

hdiutil create -volname "$(basename "$app" .app)" \
  -srcfolder "$stage" -ov -format UDZO "$out"

echo "Done: $out"
