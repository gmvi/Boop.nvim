#!/bin/sh

project_root="$(dirname $(dirname $0))"
install_target="$1"
if [ -z "$install_target" ]; then
    install_target="$project_root/bin"
fi
install_target="$install_target/boop"
repo="gmvi/Boop.nvim"
tag="v0.1.0-alpha.3"
platform="$(uname -sm)"

if [ "$platform" = "Darwin Arm64"
    -o "$platform" = "Darwin aarch64" ]; then
    # Not currently supported platform (error code 164)
    exit 164
elif [ "$platform" = "Darwin x86_64" ]; then
    platform="macOS-x86_64"
elif [ "$platform" = "Linux aarch64" ]; then
    platform="Linux-aarch64"
elif [ "$platform" = "Linux x86_64" ]; then
    platform="Linux-x86_64"
else
    # Unsupported platform; no support planned (error code 132)
    exit 132
fi

prebuilt_bin_url="https://github.com/$repo/releases/download/$tag/boop-$platform"
set -e # exit if curl fails
curl -Lso "$install_target" "$prebuilt_bin_url"
chmod u+x "$install_target"
