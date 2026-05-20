#!/bin/bash
# Copy every klassy* artifact from the live ISO into the target. Klassy is
# built from source by customize_airootfs.sh and only lands in the live
# ISO's /usr/lib/qt6/plugins/ et al. Without this script the installed
# system has no klassy plugin and KWin silently falls back to Breeze
# (square corners).
#
# Called from shellprocess@copy_genesi (dontChroot: true). Calamares passes
# the target rootMountPoint as $ROOT.
#
# Tracked future work: ship a proper genesi-klassy PKGBUILD so this isn't
# needed.
set -u
ROOT="${ROOT:-/mnt}"

count=0
find /usr/lib/qt6/plugins \
     /usr/lib/plugins \
     /usr/lib/kf6/krunner \
     /usr/bin \
     /usr/share/applications \
     /usr/share/icons/hicolor \
     /usr/share/kglobalaccel \
     /usr/share/kconf_update \
     /usr/share/dbus-1/services \
     -iname '*klassy*' 2>/dev/null \
| while read -r src; do
    dest="$ROOT$src"
    mkdir -p "$(dirname "$dest")"
    cp -rf "$src" "$dest" 2>/dev/null && count=$((count+1)) || true
done

# Also copy the libklassycommon library (used at runtime by the plugin).
find /usr/lib -maxdepth 2 -iname 'libklassycommon*' 2>/dev/null \
| while read -r src; do
    dest="$ROOT$src"
    mkdir -p "$(dirname "$dest")"
    cp -rf "$src" "$dest" 2>/dev/null || true
done

echo "[copy-klassy] artifacts copied (if any existed on live ISO)"
exit 0
