# Timcker app icons

The approved icon combines a clock and a mint plus sign on a navy background.
The source artwork was created with the built-in image generation tool. Android
adaptive icons use a native vector rendition of the same design for clean,
transparent foreground edges and a monochrome themed version.

## Store uploads

- `app-store.png`: 1024 by 1024, RGB PNG with no alpha channel.
- `google-play.png`: 512 by 512, 32-bit RGBA PNG, fully opaque, embedded sRGB
  profile, below Google's 1024 KB limit.
- Both are full squares without baked-in rounded corners or outer shadows.

The iOS AppIcon asset catalog includes all existing iPhone and iPad sizes.
Android includes legacy density PNGs, adaptive foreground/background resources
for API 26+, and a monochrome resource for API 33+. The adaptive vector uses a
108 dp viewport, with the symbol inside the central 66 dp safe region.
Web PWA icons, the 32 by 32 favicon, and the 180 by 180 Apple touch icon use
the same artwork. The app, support, and privacy pages explicitly reference
the favicon and Apple touch icon using paths relative to their own pages,
which also supports deployments below a URL prefix.

## Re-export PNG assets

Install Pillow in a Python environment, then run from the repository root:

```sh
python3 scripts/export_icons.py
```

The script reads `assets/icon/timcker-source.png` and updates all PNG exports.
It does not change the Android vector rendition; update both foreground and
monochrome drawable files together when changing the symbol.

## Official specifications

- [Apple app icon configuration](https://developer.apple.com/documentation/xcode/configuring-your-app-icon)
- [Google Play icon specifications](https://developer.android.com/distribute/google-play/resources/icon-design-specifications)
- [Android adaptive icons](https://developer.android.com/develop/ui/compose/system/icon_design_adaptive)

## Generation prompts

### Initial generation

Use case: logo-brand. Asset type: production app icon foreground for Timcker, a minimal local clock and tap counter. Create exactly one crisp, flat, professionally designed symbol on a genuinely transparent 1024x1024 square canvas. Subject: a bold simple off-white circular clock outline with two off-white hands pointing near 10 and 2, and a small mint-teal plus sign at the lower right representing incrementing the counter. The clock ring has a deliberate opening around the plus so the plus is visually separate and legible. Rounded stroke ends, generous negative space, balanced optical centering. All artwork fits within a centered circle of diameter 560 pixels so it survives Android adaptive icon masks. Off-white #F5F8FF and mint #70E0CB only; designed to sit on dark navy #102B3A. Flat opaque strokes with antialiased edges, no gradients, no glow, no shading, no texture, no shadows. No enclosing app tile, no background, no frame, no words, no numbers, no letters, no watermark, no badge. Icon must remain recognizable at 32 pixels. Output only the transparent foreground image.

### Opaque production artwork

Use case: precise-object-edit. Edit target: provided Timcker clock and plus symbol. Produce final opaque app icon. Preserve its white circular clock with 10:10 hands and mint plus at lower right, but completely redraw it with mathematically smooth clean flat shapes. Fill the ENTIRE square canvas corner to corner with solid dark navy #102B3A, including every empty area inside the clock. The ring, hands and plus must be solid uniform color, no distress, no pale particles, no speckles. White #F5F8FF clock, mint #70E0CB plus. Centered symbol with even generous margins, symbol width about 62% of canvas. One single flat square icon image. Absolutely no transparency, no rounded tile corners, no shadow, no gradient, no border, no extra small particles. Smooth curves with rounded stroke caps. No text.

The transparent generated experiments were rejected because their edges contained
artifacts. Only the clean opaque production artwork is used in the project.
