# Optional FreeSurround active decoder

The active decoder is a separate GPL-2.0-only program built against the
FreeSurround DSP carried by
[RetroSurround](https://github.com/codanric/RetroSurround). The rest of Stereo
Matrix Virtualizer remains under its existing MIT license; the programs
communicate only through raw audio pipes and PipeWire.

The build script pins RetroSurround commit
`4a25352be3b22d6a6e89a1b034a1698ecfff82c9`. It can fetch that revision or
build from an already available checkout:

```bash
./active/build-active-decoder
./active/build-active-decoder --source /path/to/RetroSurround
```

The helper consumes 48 kHz stereo interleaved `float32` on standard input and
emits standard-order 7.1 interleaved `float32` on standard output. Its default
parameters match RetroSurround's defaults. Bass redirection and the optional
rear-coherence transform are disabled.
