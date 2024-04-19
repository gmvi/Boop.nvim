#!/bin/sh

project_root="$(dirname $(dirname $0))"
install_target="$project_root/bin/boop"
repo="gmvi/Boop.nvim"
tag="v0.1.0-alpha.3"
platform="$(uname -sm)"

case "$platform" in
    "Darwin Arm64" | "Darwin aarch64")
        # Not currently supported platform (error code 164)
        exit 164
        ;;
    "Darwin x86_64")
        platform="macOS-x86_64"
        ;;
    "Linux aarch64")
        platform="Linux-aarch64"
        ;;
    "Linux x86_64")
        platform="Linux-x86_64"
        ;;
    *)
        # Unsupported platform; no support planned (error code 132)
        exit 132
        ;;
esac

prebuilt_bin_url="https://github.com/$repo/releases/download/$tag/boop-$platform"
set -e # exit if curl fails
curl -Lso "$install_target" "$prebuilt_bin_url"
chmod u+x "$install_target"
