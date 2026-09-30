"""Hisap app icon: a workshop bill (receipt with a torn edge and a rupee total)
with an orange wrench badge, on the Nocturne night ground."""
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter

FONT = sys.argv[1]
OUT = sys.argv[2]
S = 4096  # supersampled canvas; downscaled to 1024

BG_TOP = (0x1F, 0x2A, 0x3D)
BG_BOT = (0x11, 0x18, 0x27)
PAPER = (0xF1, 0xF5, 0xF9)
RULE = (0xCB, 0xD5, 0xE1)
ACCENT = (0x25, 0x63, 0xEB)
ACCENT_LIGHT = (0x60, 0xA5, 0xFA)
HIGHLIGHT = (0xFB, 0x92, 0x3C)


def u(v):  # design units are 0..1024
    return int(round(v * S / 1024))


def background():
    bg = Image.new("RGB", (S, S))
    d = ImageDraw.Draw(bg)
    for y in range(S):
        t = y / (S - 1)
        d.line([(0, y), (S, y)], fill=tuple(int(a + (b - a) * t) for a, b in zip(BG_TOP, BG_BOT)))
    # soft blue glow behind the bill
    glow = Image.new("L", (S, S), 0)
    ImageDraw.Draw(glow).ellipse([u(212), u(170), u(812), u(770)], fill=90)
    glow = glow.filter(ImageFilter.GaussianBlur(u(120)))
    bg.paste(Image.new("RGB", (S, S), ACCENT), (0, 0), glow)
    return bg.convert("RGBA")


def receipt_mask(x0, y0, x1, y1, r, teeth):
    m = Image.new("L", (S, S), 0)
    d = ImageDraw.Draw(m)
    tooth_h = u(34)
    d.rounded_rectangle([x0, y0, x1, y1 - tooth_h], radius=r, fill=255)
    # square off bottom corners so the zigzag runs edge to edge
    d.rectangle([x0, y1 - tooth_h - r, x1, y1 - tooth_h], fill=255)
    w = (x1 - x0) / teeth
    pts = [(x0, y1 - tooth_h)]
    for i in range(teeth):
        pts.append((x0 + w * (i + 0.5), y1))
        pts.append((x0 + w * (i + 1), y1 - tooth_h))
    pts += [(x1, y1 - tooth_h - 1), (x0, y1 - tooth_h - 1)]
    d.polygon(pts, fill=255)
    return m


def wrench_layer(size):
    """A wrench drawn upright on its own layer, returned rotated 45 degrees."""
    L = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(L)
    c = size / 2
    hw = size * 0.1          # handle half-width
    R = size * 0.2            # open-end head radius
    top = size * 0.24
    bot = size * 0.86
    d.rounded_rectangle([c - hw, top, c + hw, bot], radius=hw, fill=255)
    d.ellipse([c - R, top - R, c + R, top + R], fill=255)
    # the jaw opening
    jw = R * 0.42
    d.rectangle([c - jw, top - R - 2, c + jw, top], fill=0)
    d.ellipse([c - jw, top - jw, c + jw, top + jw], fill=0)
    return L.rotate(-45, resample=Image.BICUBIC, center=(c, c))


def fill(layer, color, mask, offset=(0, 0)):
    solid = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    solid.paste(Image.new("RGBA", mask.size, color + (255,)), offset, mask)
    return Image.alpha_composite(layer, solid)


def foreground():
    """Everything but the ground, on transparency, centred in 1024 units."""
    fg = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    dx, dy = u(-62), u(-50)

    x0, y0, x1, y1 = u(292) + dx, u(196) + dy, u(732) + dx, u(812) + dy
    paper = receipt_mask(x0, y0, x1, y1, u(56), 8)
    shadow = paper.filter(ImageFilter.GaussianBlur(u(28))).point(lambda p: int(p * 0.55))
    fg = fill(fg, (0, 0, 0), shadow, (0, u(22)))
    fg = fill(fg, PAPER, paper)

    band = Image.new("L", (S, S), 0)
    ImageDraw.Draw(band).rectangle([x0, y0, x1, u(300) + dy], fill=255)
    fg = fill(fg, ACCENT, Image.composite(band, Image.new("L", (S, S), 0), paper))

    d = ImageDraw.Draw(fg)
    lh = u(22)
    for y, w in [(u(350), 0.62), (u(410), 0.46)]:
        y += dy
        d.rounded_rectangle([u(352) + dx, y, u(352) + dx + int((x1 - x0 - u(120)) * w), y + lh], radius=lh // 2, fill=RULE)
        d.rounded_rectangle([u(612) + dx, y, u(672) + dx, y + lh], radius=lh // 2, fill=RULE)

    font = ImageFont.truetype(FONT, u(290))
    d.text((u(512) + dx, u(600) + dy), "₹", font=font, fill=ACCENT, anchor="mm")

    cx, cy, br, gap = u(724) + dx, u(770) + dy, u(138), u(22)
    ring = Image.new("L", (S, S), 0)
    ImageDraw.Draw(ring).ellipse([cx - br - gap, cy - br - gap, cx + br + gap, cy + br + gap], fill=255)
    fg = fill(fg, BG_BOT, ring)
    ImageDraw.Draw(fg).ellipse([cx - br, cy - br, cx + br, cy + br], fill=HIGHLIGHT + (255,))
    ws = int(br * 1.75)
    fg = fill(fg, BG_BOT, wrench_layer(ws), (cx - ws // 2, cy - ws // 2))
    return fg


def main():
    fg = foreground()
    full = Image.alpha_composite(background(), fg)
    full.convert("RGB").resize((1024, 1024), Image.LANCZOS).save(OUT + "/icon_1024.png")
    background().convert("RGB").resize((1024, 1024), Image.LANCZOS).save(OUT + "/bg_1024.png")
    fg.resize((1024, 1024), Image.LANCZOS).save(OUT + "/fg_1024.png")


main()
