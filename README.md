# AUR Packages Hub

![Verify AUR Packages](https://github.com/UberMetroid/AUR-Packages/actions/workflows/ci.yml/badge.svg)

This repository serves as a centralized management hub and CI/CD pipeline for AUR packages maintained by [UberMetroid](https://github.com/UberMetroid).

## 🚀 Managed Packages

| Package | Description | AUR Link |
| :--- | :--- | :--- |
| [**synology-drive-client-bin**](https://aur.archlinux.org/packages/synology-drive-client-bin) | Official Synology Drive Client desktop application | [AUR](https://aur.archlinux.org/packages/synology-drive-client-bin) |
| [**synology-chat-client-bin**](https://aur.archlinux.org/packages/synology-chat-client-bin) | Desktop client for Synology Chat | [AUR](https://aur.archlinux.org/packages/synology-chat-client-bin) |
| [**msty-studio**](https://aur.archlinux.org/packages/msty-studio) | Desktop AI workflow application (Local/Private) | [AUR](https://aur.archlinux.org/packages/msty-studio) |
| [**msty-claw**](https://aur.archlinux.org/packages/msty-claw) | Autonomous AI agent for complex task orchestration | [AUR](https://aur.archlinux.org/packages/msty-claw) |
| [**mono-tracker-git**](https://aur.archlinux.org/packages/mono-tracker-git) | Privacy-first screen time tracking application | [AUR](https://aur.archlinux.org/packages/mono-tracker-git) |

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

---
*Maintained by jeryd leuck ([UberMetroid](https://github.com/UberMetroid))*
