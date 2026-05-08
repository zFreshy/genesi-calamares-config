#!/bin/bash
# Fix pacman.conf repositories - remove bad mirrors and add good ones

# Clean live ISO pacman.conf
sed -i '/\[cachyos-desktop\]/,/^$/d' /etc/pacman.conf
sed -i '/\[cachyos\]/,/^$/d' /etc/pacman.conf

# Add cachyos repos with correct mirrors BEFORE [core]
sed -i '/^\[core\]/i \
[cachyos-desktop]\
Server = https://mirror.cachyos.org/repo/$arch/$repo\
Server = https://cdn-77.cachyos.org/repo/$arch/$repo\
Server = https://build.cachyos.org/repo/$arch/$repo\
\
[cachyos]\
Server = https://mirror.cachyos.org/repo/$arch/$repo\
Server = https://cdn-77.cachyos.org/repo/$arch/$repo\
Server = https://build.cachyos.org/repo/$arch/$repo\
' /etc/pacman.conf

# Clean target system pacman.conf if ROOT is set
if [ -n "$ROOT" ] && [ -f "$ROOT/etc/pacman.conf" ]; then
    sed -i '/\[cachyos-desktop\]/,/^$/d' "$ROOT/etc/pacman.conf"
    sed -i '/\[cachyos\]/,/^$/d' "$ROOT/etc/pacman.conf"
    
    sed -i '/^\[core\]/i \
[cachyos-desktop]\
Server = https://mirror.cachyos.org/repo/$arch/$repo\
Server = https://cdn-77.cachyos.org/repo/$arch/$repo\
Server = https://build.cachyos.org/repo/$arch/$repo\
\
[cachyos]\
Server = https://mirror.cachyos.org/repo/$arch/$repo\
Server = https://cdn-77.cachyos.org/repo/$arch/$repo\
Server = https://build.cachyos.org/repo/$arch/$repo\
' "$ROOT/etc/pacman.conf"
fi

echo "Pacman repos fixed successfully"
