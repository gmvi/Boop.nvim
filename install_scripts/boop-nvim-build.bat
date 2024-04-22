@echo off

cd "%~dp0.."
git submodule update --init --recursive
cargo install --path . --root . --force
