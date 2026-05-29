#!/usr/bin/env bash
# Build a .deb package for Hovuz from a Flutter Linux release bundle.
# Usage: ./packaging/deb/build_deb.sh [version]
set -euo pipefail

cd "$(dirname "$0")/../.."

VERSION="${1:-1.0.0}"
ARCH="$(dpkg --print-architecture 2>/dev/null || echo amd64)"
PKG="hovuz_${VERSION}_${ARCH}"
STAGE="build/deb/${PKG}"
LOGO_SRC="images/logo.png"

echo "==> Flutter release bundle build"
flutter build linux --release

rm -rf "${STAGE}"
mkdir -p "${STAGE}/DEBIAN" \
         "${STAGE}/opt/hovuz" \
         "${STAGE}/usr/bin" \
         "${STAGE}/usr/share/applications" \
         "${STAGE}/usr/share/pixmaps"

# hicolor icon directories
for size in 16 32 48 64 128 256 512; do
  mkdir -p "${STAGE}/usr/share/icons/hicolor/${size}x${size}/apps"
done

echo "==> Stage bundle"
cp -r build/linux/x64/release/bundle/. "${STAGE}/opt/hovuz/"
chmod 755 "${STAGE}/opt/hovuz/hovuz"

ln -sf /opt/hovuz/hovuz "${STAGE}/usr/bin/hovuz"

if [ ! -f "${LOGO_SRC}" ]; then
  echo "WARN: ${LOGO_SRC} not found, skipping icon install."
else
  if command -v convert >/dev/null 2>&1; then
    echo "==> Generating icons from ${LOGO_SRC}"
    for size in 16 32 48 64 128 256 512; do
      convert "${LOGO_SRC}" \
        -resize "${size}x${size}" \
        -background none -gravity center \
        -extent "${size}x${size}" \
        -strip \
        "${STAGE}/usr/share/icons/hicolor/${size}x${size}/apps/hovuz.png"
    done
    # /usr/share/pixmaps fallback (older systems)
    cp "${STAGE}/usr/share/icons/hicolor/256x256/apps/hovuz.png" \
       "${STAGE}/usr/share/pixmaps/hovuz.png"
    # also bundle into /opt for absolute-path fallback
    cp "${STAGE}/usr/share/icons/hicolor/512x512/apps/hovuz.png" \
       "${STAGE}/opt/hovuz/hovuz-icon.png"
  else
    echo "WARN: imagemagick (convert) not found — installing raw logo."
    cp "${LOGO_SRC}" "${STAGE}/usr/share/icons/hicolor/256x256/apps/hovuz.png"
    cp "${LOGO_SRC}" "${STAGE}/usr/share/pixmaps/hovuz.png"
    cp "${LOGO_SRC}" "${STAGE}/opt/hovuz/hovuz-icon.png"
  fi
fi

cat > "${STAGE}/usr/share/applications/hovuz.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Hovuz
GenericName=Crypto Transaction Inspector
Comment=Kripto tranzaksiya va kashelek tekshiruvi
Exec=/opt/hovuz/hovuz
Icon=hovuz
Terminal=false
Categories=Utility;Finance;Network;
StartupWMClass=hovuz
Keywords=crypto;bitcoin;ethereum;tron;solana;blockchain;wallet;
EOF

INSTALLED_SIZE=$(du -sk "${STAGE}/opt" | cut -f1)

cat > "${STAGE}/DEBIAN/control" <<EOF
Package: hovuz
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Depends: libgtk-3-0, libblkid1, liblzma5
Installed-Size: ${INSTALLED_SIZE}
Maintainer: Qodirov Elyorbek <elyorbek-13@mail.ru>
Description: Hovuz - Crypto Transaction Inspector
 Hovuz is a cross-platform desktop application for inspecting
 cryptocurrency transactions and wallet addresses across Bitcoin,
 Ethereum, TRON, BNB Chain and Solana. It reveals fund flow,
 exchange routing, and detailed balance information.
EOF

cat > "${STAGE}/DEBIAN/postinst" <<'EOF'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -f /usr/share/icons/hicolor || true
fi
if command -v xdg-icon-resource >/dev/null 2>&1; then
  for size in 48 128 256; do
    xdg-icon-resource forceupdate --theme hicolor --size $size >/dev/null 2>&1 || true
  done
fi
exit 0
EOF
chmod 755 "${STAGE}/DEBIAN/postinst"

cat > "${STAGE}/DEBIAN/postrm" <<'EOF'
#!/bin/sh
set -e
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -f /usr/share/icons/hicolor || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
exit 0
EOF
chmod 755 "${STAGE}/DEBIAN/postrm"

echo "==> dpkg-deb --build"
mkdir -p dist
dpkg-deb --root-owner-group --build "${STAGE}" "dist/${PKG}.deb"

echo ""
echo "✅  dist/${PKG}.deb tayyor"
echo "    O'rnatish: sudo dpkg -i dist/${PKG}.deb"
echo "    Ishga tushirish: hovuz"
