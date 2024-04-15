#!/bin/sh

repo="gmvi/Boop.nvim"
tag="v0.1.0-alpha.3"
platform="$(uname -sm)"

if [ "$platform" = "Darwin aarch64" ]; then
    #not currently a supported release platform, error out to fallback to build
    exit 64
elif [ "$platform" = "Darwin x86_64" ]; then
    platform="macOS-x86_64"
elif [ "$platform" = "Linux aarch64" ]; then
    platform="Linux-aarch64"
elif [ "$platform" = "Linux x86_64" ]; then
    platform="Linux-x86_64"
else
    echo "$platform"
    exit 32
fi

curl -Lso bin/boop "https://github.com/$repo/releases/download/$tag/boop-$platform"
chmod u+x bin/boop
