# Stereo Matrix Virtualizer

Stereo Matrix Virtualizer is a native PipeWire controller for passive or
FreeSurround active upmixing from stereo to 7.1, rendering native or upmixed
surround through an HRIR, and applying an optional 16-band headphone-output
EQ and limiter.

The physical speaker, headphone or HDMI device remains the system default.
The persistent router assigns application streams to the selected processing
path without presenting a virtual processor as hardware.

## Signal paths

- **Passive + HRIR:** stereo application → PSD matrix upmix → 7.1 HRIR → headphones
- **Passive only:** stereo application → PSD matrix upmix → physical 7.1 output
- **Active + HRIR:** stereo application → FreeSurround decode → 7.1 HRIR → headphones
- **Active only:** stereo application → FreeSurround decode → physical 7.1 output
- **FFmpeg + HRIR:** stereo application → FFmpeg `surround` upmix → 7.1 HRIR → headphones
- **FFmpeg only:** stereo application → FFmpeg `surround` upmix → physical 7.1 output
- **HRIR only:** multichannel application → 7.1 HRIR → headphones
- **Off:** application → selected physical output

Modes are selected manually. Automatic channel detection is intentionally
avoided because applications frequently advertise misleading layouts.

## Screenshots

![Main Interface](screenshots/main_ui.png)

## Requirements

- Linux with PipeWire and WirePlumberrePlumber
- `pw-loopback`, `pw-dump`, `pw-link`, `pw-cli`, `pw-metadata`, `wpctl` and `pactl`
- Python 3 and PySide6 QtWidgets
- SWH LADSPA plugins (`amp_1181` and `fast_lookahead_limiter_1913`)
- A compatible multichannel HRIR WAV file
- A systemd user session

The optional active decoder additionally requires `pw-record`, `pw-play`, a C
and C++ compiler, and Git while it is first built. If its pinned RetroSurround
source cannot be fetched or compiled, installation continues with every
passive and HRIR mode available.

The optional FFmpeg engine requires `ffmpeg` with the `surround` filter. When
an FFmpeg mode is selected, the manager shows an **FFmpeg surround settings**
panel with presets (Neutral, Matrix (PL2 / Neo), Movies, Music (wide)),
sliders for focus, angle, smoothness and centre/surround/LFE levels, the LFE
crossover, and the analysis window (quality versus latency). Settings are
stored in `~/.config/stereo-upmix-manager/ffmpeg-surround.json`. Applying them
reloads only the decoder pipeline; the input sink stays up, so applications
stay connected through a brief gap. The presets are starting points to be
tuned by ear.

For filter options the panel does not expose, put a complete option string in
`~/.config/stereo-upmix-manager/ffmpeg-surround.env`, for example
`STEREO_FFMPEG_SURROUND=win_size=4096:focus=0.2:smooth=0.3`, and restart
`stereo-ffmpeg-upmix.service`. This overrides the panel's settings entirely.

On Debian-family distributions the packages are typically named `pipewire`,
`pipewire-bin`, `wireplumber`, `pulseaudio-utils`, `swh-plugins`,
`libpyside6-py3-6.11` (name varies by release), and `desktop-file-utils`.

## HRIR profiles

No impulse-response files are redistributed with this project. Put compatible
WAV files in:

```text
~/.local/share/stereo-matrix-virtualizer/hrir/
```

Only this folder is used. To reuse an existing Virtual Surround Manager
collection, copy its WAV files here.

Profiles must use the 14-channel layout expected by Virtual Surround Manager's
7.1 renderer. The file supplies left/right binaural impulses for the surround
positions; LFE reuses the center impulse pair.

## Install

```bash
./install.sh
```

To run dependency checks without installing anything:

```bash
./install.sh --check
```

Launch **Stereo Matrix Upmix** from the application menu, or run:

```bash
~/.local/bin/stereo-upmix-manager
```

The installer is per-user and does not require root. Processing services are
enabled only when the processing switch is turned on.

## Remove

```bash
./uninstall.sh
```

Uninstalling preserves user EQ settings, route state and HRIR files.

## Create a release archive

```bash
./make-release.sh
```

The release archive has normalized ownership, timestamps and ordering, so the
same source tree and version produce the same checksum.

## Implementation notes
- Developed and tested on Wayland.

- Matrix upmixing uses PipeWire's `channelmix.upmix-method = psd`.
- Active decoding uses the FreeSurround DSP from RetroSurround in an isolated
  helper process with a 1024-sample analysis window.
- FFmpeg upmixing uses the `surround` filter in a separate `ffmpeg` process
  with its own PipeWire sink, so both active engines can be compared without
  restarting either.
- HRIR convolution and EQ run in a native PipeWire filter-chain.
- The router is the sole owner of live application routing.
- Mode changes use make-before-break link replacement.
- The GUI may close without changing the active routing state.
- No normal operation restarts PipeWire or WirePlumber.

## Naming and trademarks

This is an independent matrix-surround and binaural-rendering project. It is
not affiliated with, endorsed by, or an implementation licensed by Dolby
Laboratories or DTS, Inc. Dolby and DTS names that may appear in user-supplied
HRIR filenames remain the property of their respective owners.

## Active decoder licensing

The optional active decoder adapter is GPL-2.0-only and builds against
[RetroSurround](https://github.com/codanric/RetroSurround), pinned to commit
`4a25352be3b22d6a6e89a1b034a1698ecfff82c9`. RetroSurround incorporates the
GPLv2 FreeSurround decoder by Christian Kothe. This GPL component is a separate
program connected to the MIT-licensed controller through audio pipes and
PipeWire; it is not linked into the controller.

## Bug Reporting

If you encounter any issues, please:
- Open a GitHub Issue in the [Issues tab](https://github.com/Kevinscki/stereo-matrix-virtualizer/issues).
- Or send a detailed report to [kelvinrutatina@gmail.com](mailto:kelvinrutatina@gmail.com).

Please include your system logs and the specific PipeWire version you are using.

## License

MIT. See [LICENSE](LICENSE).
