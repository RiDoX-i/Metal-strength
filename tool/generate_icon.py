"""Generates the Metal Strength ("magnetiss") app icon.

A horseshoe magnet (brand blue->purple gradient) with metallic pole tips,
gripping a barbell laid across its legs. Renders at 4x supersampling for clean
anti-aliasing, then writes two PNGs consumed by flutter_launcher_icons:

  assets/icon/icon.png             - full square icon (iOS + legacy Android)
  assets/icon/icon_foreground.png  - transparent artwork for the Android
                                     adaptive-icon foreground layer

Run from the project root:  python tool/generate_icon.py
"""

from PIL import Image, ImageDraw, ImageChops, ImageFilter

SS = 4                      # supersample factor
BASE = 1024                 # logical icon size
S = BASE * SS               # working canvas size


def hex2rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def lerp(a, b, t):
    return a + (b - a) * t


# --- brand palette (from lib/theme/app_colors.dart) ---
ACCENT = hex2rgb("3D9BE9")    # blue
ACCENT2 = hex2rgb("9B6DFF")   # purple
BG_TOP = hex2rgb("141A28")    # icon background (subtle dark gradient)
BG_BOT = hex2rgb("0B0E14")    # app background colour
STEEL_HI = hex2rgb("EEF3FB")  # barbell / pole highlight
STEEL_LO = hex2rgb("9AA6BA")  # barbell / pole shadow


def u(v):
    """Scale a logical (1024-space) coordinate into the supersampled canvas."""
    return int(round(v * SS))


def linear_gradient(size, c1, c2, diagonal=True, res=96):
    """Smooth gradient, rendered small then upscaled for speed."""
    small = Image.new("RGB", (res, res))
    px = small.load()
    for y in range(res):
        for x in range(res):
            t = (x + y) / (2 * (res - 1)) if diagonal else y / (res - 1)
            px[x, y] = (
                int(lerp(c1[0], c2[0], t)),
                int(lerp(c1[1], c2[1], t)),
                int(lerp(c1[2], c2[2], t)),
            )
    return small.resize((size, size), Image.BILINEAR)


def rounded(draw, box, radius, corners=None, fill=255):
    try:
        draw.rounded_rectangle(box, radius=radius, corners=corners, fill=fill)
    except TypeError:
        draw.rounded_rectangle(box, radius=radius, fill=fill)


# --- geometry (logical 1024-space) ---
CX = BASE // 2              # 512
CYB = 560                   # bend centre y
RO = 225                    # outer radius of the bend
RI = 140                    # inner radius of the bend  (band thickness = 85)
Y_TOP = 250                 # top of the legs (pole ends)

LEFT_OUT, LEFT_IN = CX - RO, CX - RI      # 287 .. 372
RIGHT_IN, RIGHT_OUT = CX + RI, CX + RO    # 652 .. 737
LEFT_C = (LEFT_OUT + LEFT_IN) / 2         # ~329.5
RIGHT_C = (RIGHT_IN + RIGHT_OUT) / 2      # ~694.5


def magnet_mask():
    """White horseshoe (U opening up) on black."""
    mask = Image.new("L", (S, S), 0)
    d = ImageDraw.Draw(mask)

    # Bottom curve: lower half of an annulus (outer disc minus inner disc).
    ring = Image.new("L", (S, S), 0)
    dr = ImageDraw.Draw(ring)
    dr.ellipse([u(CX - RO), u(CYB - RO), u(CX + RO), u(CYB + RO)], fill=255)
    dr.ellipse([u(CX - RI), u(CYB - RI), u(CX + RI), u(CYB + RI)], fill=0)
    dr.rectangle([0, 0, S, u(CYB)], fill=0)          # keep only y >= CYB

    # Legs (rounded only at the top so they merge into the ring cleanly).
    rounded(d, [u(LEFT_OUT), u(Y_TOP), u(LEFT_IN), u(CYB + 40)],
            radius=u(42), corners=(True, True, False, False))
    rounded(d, [u(RIGHT_IN), u(Y_TOP), u(RIGHT_OUT), u(CYB + 40)],
            radius=u(42), corners=(True, True, False, False))

    return ImageChops.lighter(mask, ring)


def steel_caps_mask():
    """Metallic pole tips at the top of each leg."""
    m = Image.new("L", (S, S), 0)
    d = ImageDraw.Draw(m)
    rounded(d, [u(LEFT_OUT), u(Y_TOP), u(LEFT_IN), u(330)],
            radius=u(42), corners=(True, True, False, False))
    rounded(d, [u(RIGHT_IN), u(Y_TOP), u(RIGHT_OUT), u(330)],
            radius=u(42), corners=(True, True, False, False))
    return m


def barbell_mask():
    """Shaft + two plates per side, laid horizontally across the legs."""
    m = Image.new("L", (S, S), 0)
    d = ImageDraw.Draw(m)
    yc = 380
    # shaft
    rounded(d, [u(248), u(yc - 20), u(776), u(yc + 20)], radius=u(20))
    # plates: inner (tall) + outer (short) on each side
    def plate(xc, w, h):
        rounded(d, [u(xc - w / 2), u(yc - h / 2), u(xc + w / 2), u(yc + h / 2)],
                radius=u(14))
    plate(LEFT_C - 4, 42, 156)      # left inner
    plate(276, 34, 112)             # left outer
    plate(RIGHT_C + 4, 42, 156)     # right inner
    plate(748, 34, 112)             # right outer
    return m


def build_art():
    """Transparent RGBA with magnet + steel tips + barbell, centred."""
    art = Image.new("RGBA", (S, S), (0, 0, 0, 0))

    grad = linear_gradient(S, ACCENT, ACCENT2).convert("RGBA")
    steel = linear_gradient(S, STEEL_HI, STEEL_LO, diagonal=False).convert("RGBA")

    m_mask = magnet_mask()
    art.paste(grad, (0, 0), m_mask)
    art.paste(steel, (0, 0), steel_caps_mask())

    # subtle dark outline under the barbell so it reads on the gradient
    bar = barbell_mask()
    shadow = bar.filter(ImageFilter.GaussianBlur(u(4)))
    art.paste(Image.new("RGBA", (S, S), (0, 0, 0, 110)), (0, 0), shadow)
    art.paste(steel, (0, 0), bar)
    return art


def content_bbox(img):
    return img.split()[-1].getbbox()


def main():
    import os
    os.makedirs("assets/icon", exist_ok=True)

    art = build_art()

    # --- adaptive foreground: artwork sits in the inner ~62% safe zone ---
    fg = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    bbox = content_bbox(art)
    cropped = art.crop(bbox)
    target = int(S * 0.60)
    scale = target / max(cropped.width, cropped.height)
    arts = cropped.resize(
        (int(cropped.width * scale), int(cropped.height * scale)), Image.LANCZOS)
    fg.paste(arts, ((S - arts.width) // 2, (S - arts.height) // 2), arts)
    fg.resize((BASE, BASE), Image.LANCZOS).save("assets/icon/icon_foreground.png")

    # --- full square icon: dark gradient bg + soft drop shadow + artwork ~74% ---
    icon = linear_gradient(S, BG_TOP, BG_BOT, diagonal=False).convert("RGBA")
    target = int(S * 0.72)
    scale = target / max(cropped.width, cropped.height)
    artL = cropped.resize(
        (int(cropped.width * scale), int(cropped.height * scale)), Image.LANCZOS)
    ox, oy = (S - artL.width) // 2, (S - artL.height) // 2

    shadow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    sh_mask = artL.split()[-1].filter(ImageFilter.GaussianBlur(u(10)))
    sh_layer = Image.new("RGBA", artL.size, (0, 0, 0, 130))
    shadow.paste(sh_layer, (ox, oy + u(14)), sh_mask)
    icon = Image.alpha_composite(icon, shadow)
    icon.paste(artL, (ox, oy), artL)
    icon.convert("RGB").resize((BASE, BASE), Image.LANCZOS).save(
        "assets/icon/icon.png")

    print("wrote assets/icon/icon.png and assets/icon/icon_foreground.png")


if __name__ == "__main__":
    main()
