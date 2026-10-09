# Scorched Everitt — native Windows port

A source-derived C++17 / Win32 port of the 2001 UIUC ECE291 artillery game. Windows x64 machine code, GDI display, WIC PNG decoding and waveOut audio; no DOS emulator, Electron, or browser runtime.

**Preview, not a certified 1:1 port.** Original artwork is preserved byte-for-byte. Original source quirks are deliberately retained. See [parity notes](docs/PARITY.md) and [rights notice](NOTICE.md). Native Windows CI is not a Windows 11 interactive parity test.

## Play
Download the ZIP from [Releases](https://github.com/ericargyle/ScorchedEverittWin11/releases), extract the entire folder, and run **ScorchedEveritt.exe**. Keep picts beside the executable. No installation or administrator access required. The binary is unsigned.

- Menus: arrows and Enter. Select a tank, then enter a lowercase name (10 characters maximum).
- Play: Up/Down changes angle; Left/Right changes power; Enter fires.
- F1: original help screen. Q: quit confirmation; Y/N, then M for menu or Q to exit.
- Options: arrows, then Enter on Save Changes. Q discards changes.
- Two local human players; 1/3/5/7/9 rounds, six tank models, original sequential terrain atlas, scores and gun upgrades.
- Sound and wind default off, as in source. The original wind routine is disabled; enabling wind displays zero and retains its firing-sound fall-through.

## Build
Windows 11 with Visual Studio 2022 C++ tools and CMake:

```powershell
cmake -S . -B build -A x64
cmake --build build --config Release
ctest --test-dir build -C Release --output-on-failure
```

Portable core/renderer tests also build on macOS/Linux. Python 3 runs tests/assets_test.py. Windows-only --smoke-test exercises native PNG loading/rendering and a shot without opening an interactive window; it writes BMP evidence and smoke-result.txt.

## Original work
Suneil Hosmane, Terrence B. Janas, Yajur Parikh — UIUC ECE291, Fall 2001. Full original assembly and PDF are included for audit. See NOTICE.md: upstream has no explicit license; this repository does not relicense its assets.
