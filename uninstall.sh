#!/usr/bin/env bash
set -euo pipefail

systemctl --user disable --now stereo-upmix-manager.service 2>/dev/null || true
systemctl --user disable --now stereo-upmix-router.service 2>/dev/null || true
systemctl --user disable --now virtual-surround-manager.service 2>/dev/null || true

rm -f -- \
    "$HOME/.local/libexec/stereo-upmix-engine" \
    "$HOME/.local/libexec/stereo-upmix-build-filter" \
    "$HOME/.local/libexec/stereo-upmix-router" \
    "$HOME/.local/bin/stereo-upmix-manager" \
    "$HOME/.config/systemd/user/stereo-upmix-manager.service" \
    "$HOME/.config/systemd/user/stereo-upmix-router.service" \
    "$HOME/.config/systemd/user/virtual-surround-manager.service" \
    "$HOME/.local/share/applications/stereo-upmix-manager.desktop"

systemctl --user daemon-reload
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
printf 'Removed Stereo Matrix Virtualizer. User configuration and HRIR files were preserved.\n'
