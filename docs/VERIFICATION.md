# Verification evidence

- Initial native build: https://github.com/ericargyle/ScorchedEverittWin11/actions/runs/37868153287 (MSVC x64, Windows runner): all three CTest tests pass.
- core_tests: 86 source-derived numerical, raster collision, coordinates, state, scoring and edge-case assertions.
- render_tests: nine composition, flood-fill and intro-sequence assertions.
- Native executable --smoke-test loads all 58 PNGs through WIC, renders original menu/terrain/tanks/font, and executes a shot to termination. Expanded coverage renders all ten terrains and six tank selections, simulates round-award transitions through a full five-round match, displays final scoring and restarts.
- SHA256 and dimensions of every PNG match the upstream asset manifest. All 53 original assembly runtime filenames equal the 53 strings extracted from the DOS executable. This is resource equivalence, not proof that the assembly matches every binary instruction.
- Downloaded initial executable was inspected as PE signature with AMD64 machine 0x8664; 370688 bytes. It is not the 448803-byte DOS original.
- Native-generated menu, initial gameplay and shot BMPs were visually inspected: artwork, sprite placement, original HUD and bitmap text are rendered. BMPs and test logs are available in workflow artifacts.
- Local Clang portable core and renderer tests also pass. Core worker additionally ran ASan/UBSan successfully.

## Not verified
No actual Windows 11 human playthrough, hardware audio listening test, or side-by-side original DOS framebuffer/movie comparison. No blanket 1:1 parity assertion. Signed installer/Authenticode and ARM64-native builds are not supplied.
