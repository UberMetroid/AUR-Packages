#!/bin/bash
set -euo pipefail

# AUR Packages Hub - Automated Update Script
# Uses nvchecker to detect upstream changes and updates the corresponding PKGBUILDs.

REPO_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")
cd "$REPO_DIR"

if ! command -v nvchecker &>/dev/null; then
  echo "Installing required tools..."
  sudo pacman -Syu --noconfirm nvchecker jq pacman-contrib
fi

echo "=== Running nvchecker ==="
# Capture only "updated" events in a clean JSON array
nvchecker -c nvchecker.toml --logger json 2>&1 | \
  jq -s 'map(select(.event == "updated"))' > updates.json || true

update_count=$(jq length updates.json)
echo "Found $update_count updates."

jq -c '.[]' updates.json | while read -r update; do
  pkgname=$(echo "$update" | jq -r '.name')
  new_ver=$(echo "$update" | jq -r '.version')

  echo "--- Processing $pkgname -> $new_ver ---"

  pkgdir="$REPO_DIR/$pkgname"
  [[ ! -d "$pkgdir" ]] && { echo "  Skipping (no directory)"; continue; }

  (
    cd "$pkgdir"

    current_pkgver=$(grep -m1 '^pkgver=' PKGBUILD | cut -d= -f2 || echo "")

    is_up_to_date=false
    if [[ "$current_pkgver" == "$new_ver" ]]; then
      is_up_to_date=true
    elif [[ "$pkgname" == *-git ]]; then
      clean_current=${current_pkgver#v}
      clean_new=${new_ver#v}
      [[ "$clean_current" == "$clean_new"* ]] && is_up_to_date=true
    fi

    if [[ "$is_up_to_date" == false ]]; then
      echo "  Updating $pkgname from $current_pkgver to $new_ver"

      # Handle Synology special versioning
      if [[ "$pkgname" == synology-* ]]; then
        new_pkgver=${new_ver//-/_}
        sed -i "s/^pkgver=.*/pkgver=$new_pkgver/" PKGBUILD

        if grep -q '^_pkgrel=' PKGBUILD; then
          _pkgver=$(cut -d- -f1 <<< "$new_ver")
          _pkgrel=$(cut -d- -f2 <<< "$new_ver")
          sed -i "s/^_pkgver=.*/_pkgver=$_pkgver/" PKGBUILD
          sed -i "s/^_pkgrel=.*/_pkgrel=$_pkgrel/" PKGBUILD
        fi
      else
        sed -i "s/^pkgver=.*/pkgver=$new_ver/" PKGBUILD
      fi

      sed -i "s/^pkgrel=.*/pkgrel=1/" PKGBUILD

      updpkgsums
      makepkg --printsrcinfo > .SRCINFO

      git add PKGBUILD .SRCINFO
      git commit -m "Auto-update $pkgname to $new_ver"
    else
      echo "  $pkgname is already up to date"
    fi
  )
done

rm -f updates.json
echo "=== Update check complete ==="
