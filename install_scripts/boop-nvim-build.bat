@echo off

cd "%~dp0.."
cargo install --path . --root . --force
