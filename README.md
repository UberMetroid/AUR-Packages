# AUR Packages Hub

![Verify AUR Packages](https://github.com/UberMetroid/AUR-Packages/actions/workflows/ci.yml/badge.svg)

This repository serves as a centralized management hub and CI/CD pipeline for AUR packages maintained by [UberMetroid](https://github.com/UberMetroid).

## 🚀 Managed Packages

| Package | Description | AUR Link |
| :--- | :--- | :--- |
| [**synology-drive-client-bin**](https://aur.archlinux.org/packages/synology-drive-client-bin) | Official Synology Drive Client desktop application | [AUR](https://aur.archlinux.org/packages/synology-drive-client-bin) |
| [**synology-chat-client-bin**](https://aur.archlinux.org/packages/synology-chat-client-bin) | Desktop client for Synology Chat | [AUR](https://aur.archlinux.org/packages/synology-chat-client-bin) |
| [**equibop-client-bin**](https://aur.archlinux.org/packages/equibop-client-bin) | Equicord-enabled Discord client (client-bin) | [AUR](https://aur.archlinux.org/packages/equibop-client-bin) |
| [**ledger-live-client-bin**](https://aur.archlinux.org/packages/ledger-live-client-bin) | Official Ledger Wallet desktop application (client-bin) | [AUR](https://aur.archlinux.org/packages/ledger-live-client-bin) |
| [**msty-studio-bin**](https://aur.archlinux.org/packages/msty-studio-bin) | Desktop AI workflow application (Local/Private) | [AUR](https://aur.archlinux.org/packages/msty-studio-bin) |
| [**msty-claw-bin**](https://aur.archlinux.org/packages/msty-claw-bin) | Autonomous AI agent for complex task orchestration | [AUR](https://aur.archlinux.org/packages/msty-claw-bin) |
| [**mono-tracker-git**](https://aur.archlinux.org/packages/mono-tracker-git) | Privacy-first screen time tracking application | [AUR](https://aur.archlinux.org/packages/mono-tracker-git) |
| [**bleachbit-tui-git**](https://aur.archlinux.org/packages/bleachbit-tui-git) | Free space and maintain privacy (Experimental TUI branch) | [AUR](https://aur.archlinux.org/packages/bleachbit-tui-git) |

## 🛠 Automation & Testing

Every package in this repository is automatically tested on every push and via a nightly schedule. The testing pipeline ensures:

1.  **Static Analysis:** `namcap` linting for packaging standards.
2.  **Clean Chroot Build:** Building in a fresh Arch Linux environment via `devtools`.
3.  **Library Integrity:** Automated `ldd` checks to ensure no broken library links ("not found").

### Local Testing
To run the full test suite locally, navigate to a package directory and run:
```bash
./test-package.sh
```

## 📜 Maintenance
This hub is the single source of truth for these packages. Updates are first verified here before being pushed to the Arch User Repository.

All packages follow the standards defined in [BEST_PRACTICES.md](BEST_PRACTICES.md). New packages and retrofits must adhere to these rules for consistency, security, and user experience.

### Maintenance Flow

1. Edit any `PKGBUILD` (and supporting files) in this repository.
2. Push to GitHub (`master` branch).
3. GitHub Actions runs `verify` job:
   - `namcap` on `PKGBUILD`
   - Full clean chroot build (`extra-x86_64-build`)
   - `namcap` + `ldd` integrity check on the resulting package
4. On success, the changes are ready.
5. Nightly (or manual dispatch) the `update` job:
   - `nvchecker` detects new upstream versions
   - `PKGBUILD`s are automatically updated, checksums refreshed, `.SRCINFO` regenerated
   - Updated packages are built and pushed to the corresponding real AUR repositories via SSH
6. The real AUR repos (`ssh://aur@aur.archlinux.org/<pkgname>.git`) always contain only the minimal professional files.

Only the following files are ever synced to the real AUR:
- `PKGBUILD`
- `.SRCINFO`
- `*.desktop`, `*.service`, `*.install`
- Required launcher scripts (e.g. `bleachbit-tui-launcher.sh`)

`test-package.sh`, build artifacts, and hub-only scripts are never published to the AUR.
