#!/bin/sh

cd "$(dirname $0)/.."
cargo install --path . --root . --force
