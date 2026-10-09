# Source audit and parity status

Authority: reference/main.asm, 6592 lines, upstream c2f02732b4c0cf58d0abfa130fd274d018ac7f85. Assembly SHA256 db90aaedc3204b184824070e5eaf4eec6bb4df62f910d7867ddd7b32cfe7a3d9. Original DOS main.exe SHA256 b1d6278b1efe1c70e1eb6f458df321aba2952dbbc3de9655a3e1c3bdcdaa20ec. The DOS binary is not run or shipped.

## Translation map
- Constants, all ten terrain coordinates and six muzzle tables (lines 30–430): core.hpp.
- Defaults, options, menus, player setup (704–1379, 3201–3887): main.cpp state machine, original PNG menus and bitmap font.
- Scores, upgrades, round/match flow (1380–1905): core.hpp Game/award plus main.cpp overlays.
- Projectile and collisions (1910–2533): core.hpp launch/sample/traceBullet/hitPlayer. Time doubles from .001; gravity is -5 rather than conventional half-gravity. Stateful angle frames, wrapped unsigned hitboxes, P2's P1-model typo, signed-byte score upgrade bug and loser-first rounds are retained.
- Aim controls (2534–2989): one-unit keyboard changes, power 0–100, angle 0–180, exact sprite transition thresholds.
- Allocation, pixel/line/circle/text/buffer/flood operations (2990–5600): safe C++ image buffers and render.hpp; original rounded /256 composition and original bitmap font alpha.
- Keyboard/timer hardware (5601–5877): Windows messages and timers replace DOS interrupts.
- Audio/RNG/intro (5878–6592): PIT-derived PCM via waveOut; intro.hpp 24 original full-screen frames plus forty alpha-16 fade passes.

## Important limits / deliberate differences
- No interactive Windows 11 versus DOS comparison has been performed. No 1:1 claim is made. CI runs on GitHub's Windows Server runner, not Windows 11.
- The source and DOS binary's runtime filename declarations are compared separately; matching declarations does not prove instruction-level binary/source equivalence.
- Original animation/fade/explosion loop timings depended on CPU and PNG loading speed. Intro uses 12 fps/60 fade passes per second. Windows timer cadence and nonblocking audio are modernized. DOS busy-wait timing is not reproduced exactly.
- Portable libm is not guaranteed bit-identical to x87 FSINCOS at pathological rounding boundaries. Binary32 stored values, ties-to-even integer rounding and source equations are covered by regressions.
- Out-of-range DOS memory corruption is prevented; a finite shot safety limit avoids hangs. Resize/DPI letterboxing and intro skipping are additions.
- Original options saved-copy fields are uninitialized on first entry; this port initializes them to the intended documented defaults instead of reproducing that defect.
- Explosions and crater rings use source midpoint/flood operations, but the original 600-radius death animation is being adapted; see release notes. UI redraw ordering and source rollover partial-screen offset quirks are not pixel-equivalence certified.
- Audio uses square-wave PCM on the default Windows output, not a physical PC speaker. Sound quality and scheduling differ.

## Evidence
86 portable source-derived core checks; nine renderer/intro checks; all 58 PNG hashes/dimensions and all 53 runtime resource declarations verified. Native Windows workflow builds x64 and runs these tests plus WIC image decoding and gameplay smoke rendering. Smoke BMPs are retained in Actions artifacts. These are regression/smoke checks, not a substitute for human playthrough and audiovisual A/B testing.
