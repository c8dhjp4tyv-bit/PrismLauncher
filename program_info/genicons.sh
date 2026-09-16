#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LAUNCHER_APPID="io.github.c8dhjp4tyv_bit.TimelessLauncher"
LAUNCHER_BINARY_NAME="timeless-launcher"
LAUNCHER_COMMON_NAME="TimelessLauncher"

svg2png() {
    input_file="$1"
    output_file="$2"
    width="$3"
    height="$4"

    inkscape -w "$width" -h "$height" -o "$output_file" "$input_file"
}

if command -v "inkscape" && command -v "icotool" && command -v "oxipng"; then
    # Windows ICO
    d=$(mktemp -d)

    svg2png "${LAUNCHER_APPID}.svg" "$d/${LAUNCHER_BINARY_NAME}_16.png" 16 16
    svg2png "${LAUNCHER_APPID}.svg" "$d/${LAUNCHER_BINARY_NAME}_24.png" 24 24
    svg2png "${LAUNCHER_APPID}.svg" "$d/${LAUNCHER_BINARY_NAME}_32.png" 32 32
    svg2png "${LAUNCHER_APPID}.svg" "$d/${LAUNCHER_BINARY_NAME}_48.png" 48 48
    svg2png "${LAUNCHER_APPID}.svg" "$d/${LAUNCHER_BINARY_NAME}_64.png" 64 64
    svg2png "${LAUNCHER_APPID}.svg" "$d/${LAUNCHER_BINARY_NAME}_128.png" 128 128
    svg2png "${LAUNCHER_APPID}.svg" "$d/${LAUNCHER_BINARY_NAME}_256.png" 256 256

    oxipng --opt max --strip all --alpha --interlace 0 "$d/${LAUNCHER_BINARY_NAME}_"*".png"

    rm -f "${LAUNCHER_BINARY_NAME}.ico"
    icotool -o "${LAUNCHER_BINARY_NAME}.ico" -c \
        "$d/${LAUNCHER_BINARY_NAME}_256.png"  \
        "$d/${LAUNCHER_BINARY_NAME}_128.png"  \
        "$d/${LAUNCHER_BINARY_NAME}_64.png"   \
        "$d/${LAUNCHER_BINARY_NAME}_48.png"   \
        "$d/${LAUNCHER_BINARY_NAME}_32.png"   \
        "$d/${LAUNCHER_BINARY_NAME}_24.png"   \
        "$d/${LAUNCHER_BINARY_NAME}_16.png"
elif command -v "inkscape" && command -v "convert"; then
    # ImageMagick fallback for Linux and other environments without icotool.
    d=$(mktemp -d)
    svg2png "${LAUNCHER_APPID}.svg" "$d/${LAUNCHER_BINARY_NAME}.png" 256 256
    convert "$d/${LAUNCHER_BINARY_NAME}.png" \
        -define icon:auto-resize=256,128,96,64,48,32,24,16 \
        "${LAUNCHER_BINARY_NAME}.ico"
else
    echo "ERROR: Windows icons were NOT generated!" >&2
    echo "ERROR: requires inkscape, icotool and oxipng in PATH"
fi

if command -v "inkscape" && command -v "iconutil" && command -v "oxipng"; then
    # macOS ICNS
    d=$(mktemp -d)

    d="$d/${LAUNCHER_COMMON_NAME}.iconset"

    mkdir -p "$d"

    svg2png "${LAUNCHER_APPID}.bigsur.svg" "$d/icon_16x16.png" 16 16
    svg2png "${LAUNCHER_APPID}.bigsur.svg" "$d/icon_16x16@2x.png" 32 32
    svg2png "${LAUNCHER_APPID}.bigsur.svg" "$d/icon_32x32.png" 32 32
    svg2png "${LAUNCHER_APPID}.bigsur.svg" "$d/icon_32x32@2x.png" 64 64
    svg2png "${LAUNCHER_APPID}.bigsur.svg" "$d/icon_128x128.png" 128 128
    svg2png "${LAUNCHER_APPID}.bigsur.svg" "$d/icon_128x128@2x.png" 256 256
    svg2png "${LAUNCHER_APPID}.bigsur.svg" "$d/icon_256x256.png" 256 256
    svg2png "${LAUNCHER_APPID}.bigsur.svg" "$d/icon_256x256@2x.png" 512 512
    svg2png "${LAUNCHER_APPID}.bigsur.svg" "$d/icon_512x512.png" 512 512
    svg2png "${LAUNCHER_APPID}.bigsur.svg" "$d/icon_512x512@2x.png" 1024 1024

    oxipng --opt max --strip all --alpha --interlace 0 "$d/icon_"*".png"

    iconutil -c icns "$d"
    cp -v "$d/${LAUNCHER_COMMON_NAME}.icns" "${LAUNCHER_BINARY_NAME}.icns"
elif command -v "inkscape" && command -v "python3"; then
    # Portable fallback for CI and non-macOS development environments.
    d=$(mktemp -d)
    svg2png "${LAUNCHER_APPID}.bigsur.svg" "$d/icon_16x16.png" 16 16
    svg2png "${LAUNCHER_APPID}.bigsur.svg" "$d/icon_32x32.png" 32 32
    svg2png "${LAUNCHER_APPID}.bigsur.svg" "$d/icon_48x48.png" 48 48
    svg2png "${LAUNCHER_APPID}.bigsur.svg" "$d/icon_128x128.png" 128 128
    svg2png "${LAUNCHER_APPID}.bigsur.svg" "$d/icon_256x256.png" 256 256
    svg2png "${LAUNCHER_APPID}.bigsur.svg" "$d/icon_512x512.png" 512 512
    svg2png "${LAUNCHER_APPID}.bigsur.svg" "$d/icon_1024x1024.png" 1024 1024
    python3 ./make_icns.py "${LAUNCHER_BINARY_NAME}.icns" \
        "$d/icon_16x16.png" "$d/icon_32x32.png" "$d/icon_48x48.png" \
        "$d/icon_128x128.png" "$d/icon_256x256.png" "$d/icon_512x512.png" \
        "$d/icon_1024x1024.png"
else
    echo "ERROR: macOS icons were NOT generated!" >&2
    echo "ERROR: requires inkscape, iconutil and oxipng in PATH"
fi

# replace icon in themes
cp -v "${LAUNCHER_APPID}.svg" "../launcher/resources/multimc/scalable/launcher.svg"
