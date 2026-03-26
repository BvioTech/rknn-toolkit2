#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PKG_DIR="${SCRIPT_DIR}/package"
PKG_NAME="violoop-rknn"

usage() {
    echo "Usage: $0 <arch>"
    echo "  arch: arm | arm64 | aarch64"
    exit 1
}

[ $# -ne 1 ] && usage

ARCH="$1"

case "${ARCH}" in
    arm)
        DEB_ARCH="armhf"
        LIB_DIR="armhf"
        ;;
    arm64|aarch64)
        DEB_ARCH="arm64"
        LIB_DIR="aarch64"
        ;;
    *)
        echo "Error: unsupported arch '${ARCH}'"
        usage
        ;;
esac

# Stage files into package directory
rm -rf "${PKG_DIR}/usr"
mkdir -p "${PKG_DIR}/usr/lib" "${PKG_DIR}/usr/include"

# Headers
cp -a "${SCRIPT_DIR}/include"/*.h "${PKG_DIR}/usr/include/"

# Prebuilt libraries
cp -a "${SCRIPT_DIR}/${LIB_DIR}"/*.so "${PKG_DIR}/usr/lib/"

# Patch architecture in control file
sed -i "s/^Architecture: .*/Architecture: ${DEB_ARCH}/" "${PKG_DIR}/DEBIAN/control"

VERSION=$(grep -oP '^Version: \K.*' "${PKG_DIR}/DEBIAN/control")
DEB_FILE="${SCRIPT_DIR}/${PKG_NAME}_${VERSION}_${DEB_ARCH}.deb"

dpkg-deb --build --root-owner-group "${PKG_DIR}" "${DEB_FILE}"

echo "Package created: ${DEB_FILE}"
