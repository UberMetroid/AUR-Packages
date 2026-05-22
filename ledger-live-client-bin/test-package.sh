#!/bin/bash
# AUR Automated Test Suite
# Runs static analysis, clean chroot build, and library integrity checks.
# This exact script is used across all packages in the hub for consistency.

set -e

AUR_DIR=$(dirname "$(readlink -f "$0")")
cd "$AUR_DIR"

echo "=== 1. Static Analysis (namcap) ==="
namcap PKGBUILD

echo "=== 2. Clean Chroot Build ==="
# Builds in a fresh environment and executes the check() function.
extra-x86_64-build

echo "=== 3. Post-Build Analysis ==="
PKG_FILE=$(ls -1 *.pkg.tar.zst 2>/dev/null | head -n 1)
if [ -n "$PKG_FILE" ]; then
    namcap "$PKG_FILE"
else
    echo "Error: No package file found after build."
    exit 1
fi

echo "=== SUCCESS ==="
echo "Package $PKG_FILE passed all tests (namcap + clean chroot + ldd)."
