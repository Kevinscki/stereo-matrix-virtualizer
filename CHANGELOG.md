# Changelog

## 0.2.0 - 2026-10-25

- Add an optional FreeSurround active decoder built from pinned RetroSurround source.
- Add Active only and Active + HRIR routing modes.
- Add an FFmpeg `surround` filter upmixer as its own PipeWire path, with
  FFmpeg only and FFmpeg + HRIR routing modes.
- Add an FFmpeg surround settings panel with presets, sliders and an Apply
  that reloads only the decoder while applications stay connected.
- Load HRIR profiles only from `~/.local/share/stereo-matrix-virtualizer/hrir/`;
  the Virtual Surround Manager Flatpak `hrir_wav` folder is no longer searched.
- Make the manager window freely resizable: content scrolls instead of the
  window growing, and the FFmpeg panel can be collapsed.
- Scroll the page when the mouse wheel passes over unfocused sliders,
  dropdowns and spin boxes instead of changing their values.
- Gather periodic status off the GUI thread and dump PipeWire once per
  refresh, removing a ~0.4 s freeze every 2.5 s.
- Keep all passive Matrix, HRIR and combined paths unchanged and independently usable.
- Keep the GPL active helper isolated from the MIT-licensed controller.

## 0.1.0 - 2026-10-25

- Initial source release.
- Global physical-default routing with Matrix, HRIR and combined modes.
- Make-before-break PipeWire link transitions.
- Native 7.1-to-stereo HRIR convolution.
- Optional 16-band EQ and limiter.
- Per-user installer and desktop integration.
