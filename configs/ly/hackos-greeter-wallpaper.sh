#!/usr/bin/env bash
# hackOS :: elige un wallpaper al azar de /etc/hackos/theme/wallpapers/
# y actualiza el path en regreet.toml antes de iniciar el greeter.
set -euo pipefail
WALL_DIR="/etc/hackos/theme/wallpapers"
CONFIG="/etc/greetd/regreet.toml"

PICK=$(find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | shuf -n1)
[[ -n "$PICK" ]] || exit 0

sed -i "s#^path = .*#path = \"$PICK\"#" "$CONFIG"
