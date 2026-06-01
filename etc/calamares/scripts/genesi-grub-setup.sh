#!/bin/bash
# Genesi OS - authoritative GRUB finalization.
#
# Runs LAST in the install (after the bootloader + grubcfg modules) with
# dontChroot:true; Calamares passes the target mount point as $ROOT.
#
# Why this exists: the 2026-06-01 install reproduced a GRUB menu titled
# "Arch Linux" on a black background, even though /etc/default/grub already
# had GRUB_DISTRIBUTOR='Genesi OS'. Two root causes:
#   * grub.cfg was generated before GRUB_DISTRIBUTOR was applied and never
#     regenerated, so the menu titles stayed "Arch Linux".
#   * GRUB_THEME pointed at a cachyos theme that doesn't exist -> black menu.
# Rather than depend on the (clearly unreliable) module ordering, this script
# rewrites /etc/default/grub deterministically and regenerates grub.cfg inside
# the target chroot. Idempotent and best-effort: it must never abort the install.

set +e
exec 2>&1
trap 'exit 0' EXIT

ROOT="${ROOT:-/mnt}"
GD="$ROOT/etc/default/grub"

echo "==> Genesi OS: finalizing GRUB (distributor + background + regen) in $ROOT"
mkdir -p "$ROOT/etc/default"
[ -f "$GD" ] || : > "$GD"

set_kv() {
    # set_kv KEY VALUE  -> ensures `KEY=VALUE` (uncommented) exists in $GD
    local key="$1" val="$2"
    if grep -q "^[#[:space:]]*${key}=" "$GD"; then
        sed -i "s|^[#[:space:]]*${key}=.*|${key}=${val}|" "$GD"
    else
        printf '%s=%s\n' "$key" "$val" >> "$GD"
    fi
}

set_kv GRUB_DISTRIBUTOR '"Genesi OS"'

# Drop any GRUB_THEME (the old cachyos path doesn't exist). Use a branded
# background image + colors instead — these render reliably with gfxterm and
# GRUB's built-in font, no theme engine / generated .pf2 required.
sed -i '/^[#[:space:]]*GRUB_THEME=/d' "$GD"

if [ -f "$ROOT/usr/share/grub/themes/genesi/background.png" ]; then
    set_kv GRUB_BACKGROUND '"/usr/share/grub/themes/genesi/background.png"'
    echo "==> Using Genesi GRUB background"
else
    echo "==> WARNING: genesi-grub-theme background not found; using colors only"
fi

set_kv GRUB_COLOR_NORMAL    '"light-gray/black"'
set_kv GRUB_COLOR_HIGHLIGHT '"black/green"'
set_kv GRUB_TERMINAL_OUTPUT '"gfxterm"'
set_kv GRUB_GFXMODE         '"auto"'

# Regenerate grub.cfg so the menu titles use GRUB_DISTRIBUTOR and the
# background/colors apply. Prefer arch-chroot; fall back to chroot.
if [ -x "$ROOT/usr/bin/grub-mkconfig" ]; then
    if command -v arch-chroot >/dev/null 2>&1; then
        arch-chroot "$ROOT" grub-mkconfig -o /boot/grub/grub.cfg 2>&1 | sed 's/^/[grub] /'
    else
        chroot "$ROOT" grub-mkconfig -o /boot/grub/grub.cfg 2>&1 | sed 's/^/[grub] /'
    fi
else
    echo "==> WARNING: grub-mkconfig not present in target; skipping regen"
fi

echo "==> Genesi OS: GRUB finalized"
exit 0
