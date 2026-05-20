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
nvchecker -c nvchecker.toml --logger json 2>&1 | grep '"event": "updated"' > updates.json || true

# Process updates
while read -r update; do
    [ -z "$update" ] && continue
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
    (
        cd "$REPO_DIR/$pkgname"
        current_pkgver=$(grep "^pkgver=" PKGBUILD | cut -d= -f2)
        
        # Check if up to date
        is_up_to_date=false
        if [ "$current_pkgver" = "$new_pkgver" ]; then
            is_up_to_date=true
        elif [[ "$pkgname" == *-git ]]; then
            # For git packages, check if current_pkgver starts with new_pkgver (ignoring 'v' prefix)
            clean_current=$(echo "$current_pkgver" | sed 's/^v//')
            clean_new=$(echo "$new_pkgver" | sed 's/^v//')
            if [[ "$clean_current" == "$clean_new"* ]]; then
                is_up_to_date=true
            fi
        fi
        
        if [ "$is_up_to_date" = false ]; then
            echo "Updating $pkgname to $new_pkgver"
            
            # Update pkgver in PKGBUILD
            sed -i "s/^pkgver=.*/pkgver=$new_pkgver/" PKGBUILD
            
            # Reset pkgrel to 1
            sed -i "s/^pkgrel=.*/pkgrel=1/" PKGBUILD
            
            # Handle special Synology variables
            if [[ "$pkgname" == synology-* ]]; then
                if grep -q "^_pkgrel=" PKGBUILD; then
                     _pkgver=$(echo "$new_ver" | cut -d- -f1)
                     _pkgrel=$(echo "$new_ver" | cut -d- -f2)
                     sed -i "s/^_pkgver=.*/_pkgver=$_pkgver/" PKGBUILD
                     sed -i "s/^_pkgrel=.*/_pkgrel=$_pkgrel/" PKGBUILD
                else
                     sed -i "s/^_pkgver=.*/_pkgver=$new_ver/" PKGBUILD
                fi
            fi

            # Update checksums
            updpkgsums
            
            # Regenerate .SRCINFO
            makepkg --printsrcinfo > .SRCINFO
            
            # Commit changes
            git add PKGBUILD .SRCINFO
            git commit -m "Auto-update $pkgname to $new_pkgver"
        else
            echo "$pkgname is already up to date ($current_pkgver)"
        fi
    )
done < updates.json

# Cleanup
rm updates.json
echo "Update check complete."
