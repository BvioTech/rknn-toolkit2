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
mkdir -p \
    "${PKG_DIR}/usr/bin" \
    "${PKG_DIR}/usr/lib" \
    "${PKG_DIR}/usr/lib/systemd/system" \
    "${PKG_DIR}/usr/include"

# Headers
cp -a "${SCRIPT_DIR}/librknn_api/include"/*.h "${PKG_DIR}/usr/include/"

# Prebuilt runtime library
cp -a "${SCRIPT_DIR}/librknn_api/${LIB_DIR}"/*.so "${PKG_DIR}/usr/lib/"

# rknn_server binary
install -m 0755 \
    "${SCRIPT_DIR}/rknn_server/${LIB_DIR}/usr/bin/rknn_server" \
    "${PKG_DIR}/usr/bin/rknn_server"

# systemd service unit
install -m 0644 \
    "${SCRIPT_DIR}/rknn_server/rknn-server.service" \
    "${PKG_DIR}/usr/lib/systemd/system/rknn-server.service"

# Ensure DEBIAN maintainer scripts are executable
chmod 0755 "${PKG_DIR}/DEBIAN/postinst" "${PKG_DIR}/DEBIAN/prerm" "${PKG_DIR}/DEBIAN/postrm"

# Patch architecture in control file
sed -i "s/^Architecture: .*/Architecture: ${DEB_ARCH}/" "${PKG_DIR}/DEBIAN/control"

VERSION=$(grep -oP '^Version: \K.*' "${PKG_DIR}/DEBIAN/control")
DEB_FILE="${SCRIPT_DIR}/${PKG_NAME}_${VERSION}_${DEB_ARCH}.deb"

dpkg-deb --build --root-owner-group "${PKG_DIR}" "${DEB_FILE}"

echo "Package created: ${DEB_FILE}"
