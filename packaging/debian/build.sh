#!/bin/bash
# Build script for alarm-notify Debian package
# Can be run on Debian/Ubuntu or with dpkg-deb available

set -e

VERSION="1.2.2"
PKGNAME="alarm-notify"

# Navigate to repository root (two levels up from packaging/debian/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/../.."
cd "${REPO_ROOT}"

BUILDDIR="packaging/debian/build-deb"
PKGDIR="${BUILDDIR}/${PKGNAME}_${VERSION}-1_all"

# Clean previous build
rm -rf "${BUILDDIR}"
mkdir -p "${PKGDIR}/DEBIAN"
mkdir -p "${PKGDIR}/usr/bin"
mkdir -p "${PKGDIR}/usr/share/alarm-notify"
mkdir -p "${PKGDIR}/usr/share/doc/alarm-notify"

# Install files
install -m755 alarm-notify-linux "${PKGDIR}/usr/bin/alarm-notify"
install -m644 alarm-notify.png "${PKGDIR}/usr/share/alarm-notify/"
install -m644 alarm-notify.wav "${PKGDIR}/usr/share/alarm-notify/"
install -m644 README.md "${PKGDIR}/usr/share/doc/alarm-notify/"
gzip -9 -n -c README.md > "${PKGDIR}/usr/share/doc/alarm-notify/README.md.gz" || true

# Create DEBIAN/control
cat > "${PKGDIR}/DEBIAN/control" << EOF
Package: alarm-notify
Version: ${VERSION}-1
Section: utils
Priority: optional
Architecture: all
Depends: bash, libnotify-bin, alsa-utils
Suggests: gnome-terminal | alacritty | konsole | xfce4-terminal | xterm
Maintainer: Nika Tsutskiridze <nikaakin@users.noreply.github.com>
Homepage: https://github.com/nikaakin/alarm-notify
Description: Simple timer notifications with sound and custom messages
 A simple timer script that shows a desktop notification when the time is up.
 .
 Features:
  - Minute-based timer with optional message
  - Terminal countdown display
  - External terminal mode (-e) and silent background mode (-n)
  - Desktop notification with optional sound alert
EOF

# Create DEBIAN/copyright
cat > "${PKGDIR}/DEBIAN/copyright" << 'EOF'
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: alarm-notify
Source: https://github.com/nikaakin/alarm-notify

Files: *
Copyright: 2025-present Nika Tsutskiridze
License: MIT
EOF

# Build the package
if command -v dpkg-deb &> /dev/null; then
    dpkg-deb --build --root-owner-group "${PKGDIR}"
    echo ""
    echo "✓ Package built: ${BUILDDIR}/${PKGNAME}_${VERSION}-1_all.deb"
    echo ""
    echo "To install: sudo dpkg -i ${BUILDDIR}/${PKGNAME}_${VERSION}-1_all.deb"
    echo "            sudo apt-get install -f  # to resolve dependencies"
else
    echo "Error: dpkg-deb not found. Install dpkg or run this on Debian/Ubuntu."
    echo "On Arch: sudo pacman -S dpkg"
    exit 1
fi
