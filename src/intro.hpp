#pragma once

#include <cmath>
#include <cstdint>
#include <string>
#include <vector>

namespace scorch {

struct IntroFrame {
    std::string asset;
    int sx, sy, w, h, x, y;
};

// Paths are relative to the original picts directory. All 24 animation PNGs
// are opaque, 640x480 grayscale images: motion/composition is baked into them.
// _Intro (main.asm 6466-6592) deliberately starts at 2.png, NOT 1.png;
// logo_text.png is not separately drawn by the source.
inline constexpr std::uint32_t introBackgroundARGB = 0xff000000u;
inline constexpr double introTimerHz = 1193182.0 / 65536.0;
inline constexpr double introPauseSeconds = 15.0 / introTimerHz;
// Source has NO delay between PNG loads or between fade passes. These rates
// are explicit portability choices, not timings claimed from the assembly.
inline constexpr double introFramesPerSecond = 12.0;
inline constexpr double introFadePassesPerSecond = 60.0;
inline constexpr int introImageCount = 24;
inline constexpr int introFadePassCount = 40;
inline constexpr double introAnimationSeconds = introImageCount / introFramesPerSecond;
inline constexpr double introFadeSeconds = introFadePassCount / introFadePassesPerSecond;
inline constexpr double introDuration = 2.0 * introPauseSeconds
                                     + introAnimationSeconds + introFadeSeconds;
inline constexpr double introDurationSeconds = introDuration;

// A reserved asset command, not a filename. Apply one full-rectangle black
// overlay with source alpha 0x10 using the original /256 MMX arithmetic.
// Standard /255 source-over is close, but NOT bit-identical: the original
// rounds each RGB channel, each pass, and bottoms out at intensity 7.
inline constexpr const char* introFadeCommand = "@intro:black-alpha16";
inline constexpr unsigned introFadeAlpha = 16;
inline constexpr std::uint8_t introFadeChannel(std::uint8_t value) noexcept {
    return static_cast<std::uint8_t>(value - ((unsigned(value) * 16u + 128u) >> 8));
}
// Optional compositor helper for the command. Display output stays opaque;
// the original mutated framebuffer alpha too, but VGA displayed only RGB.
inline constexpr std::uint32_t introFadePixel(std::uint32_t argb) noexcept {
    return 0xff000000u
         | (std::uint32_t(introFadeChannel(std::uint8_t(argb >> 16))) << 16)
         | (std::uint32_t(introFadeChannel(std::uint8_t(argb >> 8))) << 8)
         | std::uint32_t(introFadeChannel(std::uint8_t(argb)));
}

// Render contract: clear to introBackgroundARGB, then execute these commands
// IN ORDER on every draw (stateless; no accumulated fade between calls).
// Normal asset: unscaled source rectangle -> destination (x,y).
// introFadeCommand: transform the already drawn RGB rectangle using
// introFadePixel, once per command. There are at most 41 commands.
// Empty means black, including out-of-range timestamps. Stop showing the
// intro at introDuration and enter the menu; the final pause intentionally
// retains the 40-pass faded image, rather than inserting a new black clear.
// _Intro calls no sound routine: the intro is silent. _BattleHymn and other
// speaker routines belong elsewhere and must not be scheduled here.
inline std::vector<IntroFrame> introFrames(double seconds) {
    if (!std::isfinite(seconds) || seconds < introPauseSeconds
        || seconds >= introDuration) {
        return {};
    }
    const double elapsed = seconds - introPauseSeconds;
    constexpr char sequence[] = "23456789ABCDEFGHIJKLMNOP";
    int image = introImageCount - 1;
    int fadePasses = 0;
    if (elapsed < introAnimationSeconds) {
        image = static_cast<int>(elapsed * introFramesPerSecond);
        // Guard floating-point rounding at the last boundary.
        if (image >= introImageCount) image = introImageCount - 1;
    } else {
        const double fadeElapsed = elapsed - introAnimationSeconds;
        if (fadeElapsed >= introFadeSeconds) {
            fadePasses = introFadePassCount;
        } else {
            // The source displays the result AFTER each composition.
            fadePasses = 1 + static_cast<int>(fadeElapsed * introFadePassesPerSecond);
            if (fadePasses > introFadePassCount) fadePasses = introFadePassCount;
        }
    }
    std::vector<IntroFrame> frames;
    frames.reserve(static_cast<std::size_t>(1 + fadePasses));
    frames.push_back({std::string("intro/") + sequence[image] + ".png",
                      0, 0, 640, 480, 0, 0});
    for (int i = 0; i < fadePasses; ++i) {
        frames.push_back({introFadeCommand, 0, 0, 640, 480, 0, 0});
    }
    return frames;
}

} // namespace scorch
