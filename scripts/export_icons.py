"""Export platform and store PNGs from the approved Timcker icon artwork."""

import json
from pathlib import Path

from PIL import Image, ImageCms


ROOT = Path(__file__).resolve().parents[1]
ICON_DIR = ROOT / "assets/icon"
SOURCE = ICON_DIR / "timcker-source.png"
SRGB = ImageCms.ImageCmsProfile(ImageCms.createProfile("sRGB")).tobytes()


def export(image, path, size, mode="RGB"):
    path.parent.mkdir(parents=True, exist_ok=True)
    image.resize((size, size), Image.Resampling.LANCZOS).convert(mode).save(
        path, format="PNG", optimize=True, icc_profile=SRGB
    )


def main():
    with Image.open(SOURCE) as source:
        image = source.convert("RGB")
    if image.width != image.height:
        raise ValueError("The approved source artwork must be square.")

    export(image, ICON_DIR / "app-store.png", 1024)
    export(image, ICON_DIR / "google-play.png", 512, "RGBA")

    catalog = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    entries = json.loads((catalog / "Contents.json").read_text())["images"]
    for entry in entries:
        size = round(float(entry["size"].split("x")[0]) * float(entry["scale"][:-1]))
        export(image, catalog / entry["filename"], size)

    for density, size in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        export(image, ROOT / f"android/app/src/main/res/mipmap-{density}/ic_launcher.png", size)

    for size in (192, 512):
        export(image, ROOT / f"web/icons/Icon-{size}.png", size)
        export(image, ROOT / f"web/icons/Icon-maskable-{size}.png", size)
    export(image, ROOT / "web/favicon.png", 32)
    export(image, ROOT / "web/apple-touch-icon.png", 180)
    print("Exported iOS, Android, Web, and store icons.")


if __name__ == "__main__":
    main()
