#!/bin/sh

cd "$(dirname $0)/.."
git submodule update --init --recursive
cargo install --path . --root . --force
