# AUR-Packages Best Practices

This document defines the professional, opinionated, and secure standards used across all packages in this hub.  
New packages and retrofits must follow these rules.

## 1. Philosophy
- **Professional** — Clean code, clear comments, no bloat.
- **Opinionated where it helps the user** — Fix upstream desktop files, Wayland support, launch behavior, udev guidance, and security issues when they cause real pain.
- **Safer & more secure** — Strong `check()` with `ldd`, proper sandbox permissions, RPATH fixes, minimal attack surface in published files.
- **Better for the user** — Reliable Wayland/X11 support, correct notifications, easy hardware setup, consistent UX.
- **Better for the server (GitHub + AUR)** — Minimal files published to real AUR repos, clean git history, robust CI verification.

## 2. Required Files in Every Package Directory (Hub)
- `PKGBUILD`
- `.SRCINFO`
- `test-package.sh` (standardized, never published to AUR)
- Supporting files only when necessary: `*.desktop`, `*.install`, `*.service`, launchers

## 3. Files Published to Real AUR Repos (Strict)
Only the following are ever rsynced to `ssh://aur@aur.archlinux.org/...`:
- `PKGBUILD`
- `.SRCINFO`
- `*.desktop`
- `*.service`
- `*.install`
- Required launcher scripts (e.g. `bleachbit-tui-launcher.sh`)

Never publish: `test-package.sh`, build logs, `.git`, hub-only scripts.

## 4. PKGBUILD Standards
- Header must contain:
  ```bash
  # Maintainer: jeryd leuck <jerydleuck@gmail.com>
  # Part of https://github.com/UberMetroid/AUR-Packages (clean chroot + ldd verified)
  # Follows BEST_PRACTICES.md
  ```
- `pkgdesc` must clearly signal quality (include “client-bin, verified...” where applicable).
- Every package **must** have a `check()` function that runs `ldd` and fails on “not found”.
- Use `prepare()` for extraction and patching.
- Use `package()` for installation, permission fixes, wrappers, and desktop integration.
- Provide `provides`/`conflicts` thoughtfully.
- Add `optdepends` for GPU, audio, tray, portal, udev, etc.
- For Electron/AppImage packages: set chrome-sandbox permissions, use Ozone/Wayland flags where safe and beneficial.

## 5. Desktop Integration (Opinionated)
- Prefer clean, short desktop file names (`equibop.desktop`, `ledger-live.desktop`) over long upstream names when the upstream name breaks notifications/icons on Plasma, Hyprland, etc.
- Always ship a professional `*.desktop` with:
  - Proper `Categories`
  - `StartupWMClass`
  - `MimeType` where relevant
  - Good `Comment`
- Fix icon registration when upstream ships broken names.

## 6. `.install` Scripts
- Use `.install` for packages that need post-install actions (desktop database, services, udev reminders).
- Messages must be **strictly application-focused**, professional, and concise.
- Examples of good messages:
  - “To enable background sync, run: systemctl --user enable --now synology-drive”
  - “To use your Ledger device, install udev rules: sudo pacman -S ledger-udev”
- **Never** mention the hub, GitHub issues, or maintenance meta inside `.install`.

## 7. Wayland / X11 / Multi-DE Support
- Enable `ozone-platform-hint=auto` + relevant Wayland features for Electron apps.
- Provide a small professional wrapper when upstream launch is broken.
- Test and document support for Hyprland, Plasma, GNOME, Sway, and X11 fallbacks in PKGBUILD comments when relevant.

## 8. Hardware & udev
- For packages that talk to hardware (Ledger, etc.), the `.install` must contain a clear, application-only reminder to install the appropriate udev package.

## 9. Testing & CI
- Every package must pass `./test-package.sh` locally before pushing.
- CI runs: namcap → clean chroot build (`extra-x86_64-build`) → post-build namcap + ldd.
- All packages must be added to `.github/workflows/ci.yml`, `nvchecker.toml`, and `scripts/update-packages.sh` (when applicable).

## 10. Git & Publication Hygiene
- Keep commits focused and professional.
- Use the existing rsync exclude pattern to keep real AUR repos minimal and clean.
- Update `README.md` when adding new packages.

## 11. Future Packages Checklist
- [ ] Follows naming convention (`*-client-bin` for binary repacks where appropriate)
- [ ] Proper header + BEST_PRACTICES reference
- [ ] Strong `check()` with ldd
- [ ] Opinionated desktop file (if GUI)
- [ ] `.install` if post-install actions are needed (app-focused only)
- [ ] Wayland-aware launcher/wrapper where beneficial
- [ ] Added to CI, nvchecker, update script, README
- [ ] Full local test with `test-package.sh`

Following these rules ensures every package in the hub is professional, reliable, and a clear improvement for users while remaining maintainable and safe for the AUR infrastructure.
