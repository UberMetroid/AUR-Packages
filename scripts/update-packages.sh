#!/bin/bash
set -e

# Configuration
REPO_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")
cd "$REPO_DIR"

# Ensure we have nvchecker
if ! command -v nvchecker &> /dev/null; then
    echo "nvchecker not found. Installing..."
    sudo pacman -Syu --noconfirm nvchecker jq pacman-contrib
fi

# Run nvchecker
echo "Checking for updates..."
nvchecker -c nvchecker.toml --json > updates.json

# Process updates
jq -c '.[]' updates.json | while read -r update; do
    pkgname=$(echo "$update" | jq -r '.name')
    new_ver=$(echo "$update" | jq -r '.version')
    
    echo "Processing $pkgname..."
    
    # Handle Synology version format (4.0.3-17892 -> 4.0.3_17892)
    if [[ "$pkgname" == synology-* ]]; then
        new_pkgver=$(echo "$new_ver" | sed 's/-/_/')
    else
        new_pkgver="$new_ver"
    fi
    
    # Update PKGBUILD if needed
    cd "$REPO_DIR/$pkgname"
    current_pkgver=$(grep "^pkgver=" PKGBUILD | cut -d= -f2)
    
    if [ "$current_pkgver" != "$new_pkgver" ]; then
        echo "Updating $pkgname to $new_pkgver"
        
        # Update pkgver in PKGBUILD
        sed -i "s/^pkgver=.*/pkgver=$new_pkgver/" PKGBUILD
        
        # Reset pkgrel to 1
        sed -i "s/^pkgrel=.*/pkgrel=1/" PKGBUILD
        
        # Handle special Synology variables
        if [[ "$pkgname" == synology-* ]]; then
             _pkgver=$(echo "$new_ver" | cut -d- -f1)
             _pkgrel=$(echo "$new_ver" | cut -d- -f2)
             sed -i "s/^_pkgver=.*/_pkgver=$_pkgver/" PKGBUILD
             sed -i "s/^_pkgrel=.*/_pkgrel=$_pkgrel/" PKGBUILD
        fi

        # Update checksums
        updpkgsums
        
        # Commit changes
        git add PKGBUILD
        git commit -m "Auto-update $pkgname to $new_pkgver"
    else
        echo "$pkgname is already up to date ($current_pkgver)"
    fi
done

# Cleanup
rm updates.json
echo "Update check complete."
