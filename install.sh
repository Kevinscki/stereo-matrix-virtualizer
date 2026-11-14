#!/usr/bin/env bash
set -euo pipefail

readonly ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
readonly CONFIG_DIR="${HOME}/.config/stereo-upmix-manager"
readonly DATA_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/stereo-matrix-virtualizer"

missing=()
for command in python3 pw-loopback pw-dump pw-link pw-cli pw-metadata wpctl pactl systemctl; do
    command -v "$command" >/dev/null 2>&1 || missing+=("$command")
done
if ((${#missing[@]})); then
    printf 'Missing required commands: %s\n' "${missing[*]}" >&2
    printf 'Install PipeWire tools, WirePlumber and PulseAudio utilities, then retry.\n' >&2
    exit 1
fi
if ! python3 -c 'import PySide6.QtWidgets' >/dev/null 2>&1; then
    printf 'Missing Python Qt binding: PySide6.QtWidgets\n' >&2
    exit 1
fi
find_ladspa_plugin() {
    local directory
    for directory in /usr/lib /usr/lib64; do
        [[ -d "$directory" ]] || continue
        [[ -n "$(find "$directory" -type f -name "$1" -print -quit 2>/dev/null)" ]] && return 0
    done
    return 1
}
if ! find_ladspa_plugin amp_1181.so || ! find_ladspa_plugin fast_lookahead_limiter_1913.so; then
    printf 'Missing LADSPA SWH plugins (amp_1181 and fast lookahead limiter).\n' >&2
    exit 1
fi
if [[ "${1:-}" == "--check" ]]; then
    printf 'All required commands, Python modules and LADSPA plugins were found.\n'
    exit 0
elif (($#)); then
    printf 'Usage: %s [--check]\n' "$0" >&2
    exit 2
fi

install -Dm755 "$ROOT_DIR/bin/stereo-upmix-engine" "$HOME/.local/libexec/stereo-upmix-engine"
install -Dm755 "$ROOT_DIR/bin/stereo-active-engine" "$HOME/.local/libexec/stereo-active-engine"
install -Dm755 "$ROOT_DIR/bin/stereo-upmix-build-filter" "$HOME/.local/libexec/stereo-upmix-build-filter"
install -Dm755 "$ROOT_DIR/bin/stereo-upmix-router" "$HOME/.local/libexec/stereo-upmix-router"
install -Dm755 "$ROOT_DIR/bin/stereo-upmix-manager" "$HOME/.local/bin/stereo-upmix-manager"
install -Dm644 "$ROOT_DIR/systemd/stereo-upmix-manager.service" "$HOME/.config/systemd/user/stereo-upmix-manager.service"
install -Dm644 "$ROOT_DIR/systemd/stereo-active-decoder.service" "$HOME/.config/systemd/user/stereo-active-decoder.service"
install -Dm644 "$ROOT_DIR/systemd/stereo-ffmpeg-upmix.service" "$HOME/.config/systemd/user/stereo-ffmpeg-upmix.service"
install -Dm644 "$ROOT_DIR/systemd/stereo-upmix-router.service" "$HOME/.config/systemd/user/stereo-upmix-router.service"
install -Dm644 "$ROOT_DIR/systemd/virtual-surround-manager.service" "$HOME/.config/systemd/user/virtual-surround-manager.service"
install -Dm644 "$ROOT_DIR/desktop/stereo-upmix-manager.desktop" "$HOME/.local/share/applications/stereo-upmix-manager.desktop"
mkdir -p "$CONFIG_DIR" "$DATA_DIR/hrir"
install -Dm755 "$ROOT_DIR/active/build-active-decoder" "$DATA_DIR/active/build-active-decoder"
install -Dm644 "$ROOT_DIR/active/stereo-active-decoder.cpp" "$DATA_DIR/active/stereo-active-decoder.cpp"
install -Dm644 "$ROOT_DIR/active/README.md" "$DATA_DIR/active/README.md"

if [[ ! -x "$HOME/.local/libexec/stereo-active-decoder" ]]; then
    if command -v cc >/dev/null 2>&1 && command -v c++ >/dev/null 2>&1 && command -v git >/dev/null 2>&1; then
        if ! "$ROOT_DIR/active/build-active-decoder"; then
            printf 'Warning: optional FreeSurround active decoder could not be built.\n' >&2
            printf 'Passive matrix and HRIR modes are installed and unaffected.\n' >&2
        fi
    else
        printf 'Optional active decoder not built (cc, c++ and git are required).\n' >&2
    fi
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
    printf 'Optional FFmpeg surround engine unavailable until ffmpeg is installed.\n' >&2
fi

systemctl --user daemon-reload
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

printf 'Installed Stereo Matrix Virtualizer.\n'
printf 'Place compatible HRIR WAV files in: %s\n' "$DATA_DIR/hrir"
printf 'Active decoder builder: %s\n' "$DATA_DIR/active/build-active-decoder"
printf 'Launch from the application menu or run: %s\n' "$HOME/.local/bin/stereo-upmix-manager"
