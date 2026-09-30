import sys, os, re
from PIL import Image, ImageDraw, ImageFilter
SP = sys.argv[1]
full = Image.open(f"{SP}/icon_1024.png").convert("RGB")
bg = Image.open(f"{SP}/bg_1024.png").convert("RGBA")
fg = Image.open(f"{SP}/fg_1024.png").convert("RGBA")

def rs(im, n): return im.resize((n, n), Image.LANCZOS)

def rounded(im, n, inset_frac=0.0, radius_frac=0.225, shadow=False):
    k = 4; N = n * k
    inner = int(round(N * (1 - 2 * inset_frac))); off = (N - inner) // 2
    mask = Image.new("L", (N, N), 0)
    ImageDraw.Draw(mask).rounded_rectangle([off, off, off + inner - 1, off + inner - 1], radius=int(inner * radius_frac), fill=255)
    out = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    if shadow:
        sh = mask.filter(ImageFilter.GaussianBlur(N * 0.012)).point(lambda p: int(p * 0.35))
        out.paste(Image.new("RGBA", (N, N), (0, 0, 0, 255)), (0, int(N * 0.01)), sh)
    layer = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    layer.paste(im.convert("RGBA").resize((inner, inner), Image.LANCZOS), (off, off))
    out = Image.alpha_composite(out, Image.composite(layer, Image.new("RGBA", (N, N), (0, 0, 0, 0)), mask))
    return out.resize((n, n), Image.LANCZOS)

def scaled_fg(scale):
    box = fg.getbbox(); c = fg.crop(box)
    c = c.resize((int(c.width * scale), int(c.height * scale)), Image.LANCZOS)
    out = Image.new("RGBA", fg.size, (0, 0, 0, 0))
    out.paste(c, ((1024 - c.width) // 2, (1024 - c.height) // 2), c)
    return out

ios = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
for f in os.listdir(ios):
    m = re.fullmatch(r"Icon-App-([\d.]+)x[\d.]+@(\d)x\.png", f)
    if m: rs(full, round(float(m[1]) * int(m[2]))).save(f"{ios}/{f}")

mac = "macos/Runner/Assets.xcassets/AppIcon.appiconset"
mac_master = rounded(full, 1024, inset_frac=100 / 1024, radius_frac=0.2237, shadow=True)
for n in (16, 32, 64, 128, 256, 512, 1024):
    rs(mac_master, n).save(f"{mac}/app_icon_{n}.png")

res = "android/app/src/main/res"
for d, n in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
    rounded(full, n, inset_frac=0.04, radius_frac=0.2).save(f"{res}/mipmap-{d}/ic_launcher.png")
afg = scaled_fg(0.7)
for d, n in {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}.items():
    rs(afg, n).save(f"{res}/mipmap-{d}/ic_launcher_foreground.png")
    rs(bg.convert("RGB"), n).save(f"{res}/mipmap-{d}/ic_launcher_background.png")
os.makedirs(f"{res}/mipmap-anydpi-v26", exist_ok=True)
open(f"{res}/mipmap-anydpi-v26/ic_launcher.xml", "w").write('''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
''')

rounded(full, 16, radius_frac=0.2).save("web/favicon.png")
for n in (192, 512):
    rounded(full, n, radius_frac=0.2).save(f"web/icons/Icon-{n}.png")
    Image.alpha_composite(bg, scaled_fg(0.8)).convert("RGB").resize((n, n), Image.LANCZOS).save(f"web/icons/Icon-maskable-{n}.png")

os.makedirs("assets/icon", exist_ok=True)
full.save("assets/icon/app_icon_1024.png")
afg.save("assets/icon/adaptive_foreground_1024.png")
bg.convert("RGB").save("assets/icon/adaptive_background_1024.png")

sheet = Image.new("RGB", (1400, 480), (236, 239, 244))
sheet.paste(rs(full, 400), (30, 40))
circ = Image.new("L", (400, 400), 0); ImageDraw.Draw(circ).ellipse([0, 0, 399, 399], fill=255)
sheet.paste(rs(Image.alpha_composite(bg, afg).convert("RGB"), 400), (480, 40), circ)
m4 = rs(mac_master, 400); sheet.paste(m4, (930, 40), m4)
for i, n in enumerate((60, 40, 29)):
    t = rs(full, n); sheet.paste(t, (1340 - n, 40 + i * 80))
sheet.save(f"{SP}/preview.png")
print("done")
