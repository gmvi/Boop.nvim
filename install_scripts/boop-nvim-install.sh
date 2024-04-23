#!/bin/sh

project_root="$(dirname $(dirname $0))"
install_target="$project_root/bin/boop"
repo="gmvi/Boop.nvim"
tag="v0.1.0-beta.1"
if [ "$(uname -o)" = "Android" ]; then
    platform="Android $(uname -m)"
else
    platform="$(uname -sm)"
fi

case "$platform" in
    # Supported platforms
    Darwin\ Arm64|Darwin\ aarch64)
        platform="macOS-aarch64"
        ;;
    Darwin\ x86_64)
        platform="macOS-x86_64"
        ;;
    Linux\ aarch64)
        platform="Linux-aarch64"
        ;;
    Linux\ x86_64)
        platform="Linux-x86_64"
        ;;
    # Unsupported platforms
    Android\ *)
        exit 122
        ;;
    *\ i?86)
        exit 132
        ;;
    *)
        exit 104
        ;;
esac

prebuilt_bin_url="https://github.com/$repo/releases/download/$tag/boop-$platform"
set -e # exit if curl fails
curl -Lso "$install_target" "$prebuilt_bin_url"
chmod u+x "$install_target"
