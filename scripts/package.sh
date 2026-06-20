#!/bin/bash
# Build librknnrt + librknnrt-dev arm64 debs from the vendored RKNN runtime blob.
# No compilation; dh_shlibdeps is skipped (deps declared in control), but
# dh_makeshlibs reads the SONAME via the cross objdump.
#
# Intended to run inside `container: debian:bookworm`. Produces, at repo root:
#   librknnrt_<ver>_arm64.deb, librknnrt-dev_<ver>_arm64.deb (+ .sha256)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

if [ "${PACKAGE_INSTALL_DEPS:-1}" = "1" ]; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y --no-install-recommends \
    ca-certificates dpkg-dev build-essential debhelper fakeroot \
    binutils-aarch64-linux-gnu
fi

export DEB_BUILD_OPTIONS="noautodbgsym"
dpkg-buildpackage -a arm64 -b -uc -us

mv ../*.deb "$REPO_ROOT"/ 2>/dev/null || true
for f in "$REPO_ROOT"/*.deb; do
  ( cd "$REPO_ROOT" && sha256sum "$(basename "$f")" > "$(basename "$f").sha256" )
done

echo "== produced =="
ls -1 "$REPO_ROOT"/*.deb "$REPO_ROOT"/*.sha256
