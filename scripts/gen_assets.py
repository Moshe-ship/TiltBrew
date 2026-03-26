#!/usr/bin/env python3
"""Generate TiltBrew cover, thumbnail, OG image, and app icon."""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os, math, random

OUT = os.path.join(os.path.dirname(__file__), '..', 'assets')
os.makedirs(OUT, exist_ok=True)

# Colors
BG = (8, 8, 16)
COFFEE = (200, 149, 108)
COFFEE_DARK = (90, 58, 32)
WARM = (232, 169, 108)
CREAM = (240, 236, 228)
CHOC = (70, 36, 20)
PALE = (245, 230, 210)

def try_font(size):
    """Try to load a good font, fallback to default."""
    paths = [
        "/System/Library/Fonts/SFCompact.ttf",
        "/System/Library/Fonts/Supplemental/SF-Compact-Display-Black.otf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/SF-Pro-Display-Black.otf",
        "/System/Library/Fonts/SFNS.ttf",
    ]
    for p in paths:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except:
                pass
    return ImageFont.load_default()


def draw_mug(draw, cx, cy, scale=1.0):
    """Draw a stylized coffee mug."""
    s = scale
    mw, mh = int(120*s), int(140*s)
    mx, my = cx - mw//2, cy - mh//2 + int(10*s)

    # Mug body
    draw.rounded_rectangle(
        [mx, my, mx+mw, my+mh],
        radius=int(20*s),
        fill=COFFEE
    )

    # Inner dark
    inset = int(8*s)
    draw.rounded_rectangle(
        [mx+inset, my+inset, mx+mw-inset, my+mh-inset],
        radius=int(14*s),
        fill=CHOC
    )

    # Liquid
    liq_top = my + int(45*s)
    draw.rounded_rectangle(
        [mx+inset+2, liq_top, mx+mw-inset-2, my+mh-inset],
        radius=int(12*s),
        fill=COFFEE_DARK
    )

    # Foam highlight
    draw.rounded_rectangle(
        [mx+inset+2, liq_top, mx+mw-inset-2, liq_top+int(12*s)],
        radius=int(6*s),
        fill=(210, 170, 120)
    )

    # Handle
    hx = mx + mw
    hy = my + int(35*s)
    hw, hh = int(30*s), int(50*s)
    draw.arc([hx-int(5*s), hy, hx+hw, hy+hh], -90, 90, fill=COFFEE, width=int(8*s))

    # Drops
    for i in range(5):
        dx = cx + random.randint(int(-60*s), int(60*s))
        dy = cy - random.randint(int(60*s), int(100*s))
        dr = random.randint(int(3*s), int(7*s))
        alpha = random.randint(100, 200)
        draw.ellipse([dx-dr, dy-dr, dx+dr, dy+dr+int(2*s)], fill=(*COFFEE, alpha))


def draw_glow(img, cx, cy, radius, color, alpha=30):
    """Draw a soft radial glow."""
    glow = Image.new('RGBA', img.size, (0,0,0,0))
    gd = ImageDraw.Draw(glow)
    for r in range(radius, 0, -2):
        a = int(alpha * (r / radius))
        gd.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(*color, a))
    glow = glow.filter(ImageFilter.GaussianBlur(radius=radius//3))
    img.paste(Image.alpha_composite(Image.new('RGBA', img.size, (0,0,0,0)), glow), (0,0), glow)


def make_cover(w, h, filename):
    """Main cover/thumbnail generator."""
    img = Image.new('RGBA', (w, h), BG)
    draw = ImageDraw.Draw(img)

    # Grid lines
    for x in range(0, w, 60):
        draw.line([(x, 0), (x, h)], fill=(255,255,255,6), width=1)
    for y in range(0, h, 60):
        draw.line([(0, y), (w, y)], fill=(255,255,255,6), width=1)

    # Ambient glows
    draw_glow(img, int(w*0.7), int(h*0.3), int(min(w,h)*0.4), COFFEE, alpha=15)
    draw_glow(img, int(w*0.3), int(h*0.7), int(min(w,h)*0.3), COFFEE, alpha=10)

    draw = ImageDraw.Draw(img)

    # Mug
    mug_cy = int(h * 0.48)
    scale = min(w, h) / 500
    draw_mug(draw, w//2, mug_cy, scale=scale)

    # Title
    title_font = try_font(int(72 * scale))
    sub_font = try_font(int(22 * scale))
    tag_font = try_font(int(16 * scale))

    # "TiltBrew" title
    title = "TiltBrew"
    bbox = draw.textbbox((0,0), title, font=title_font)
    tw = bbox[2] - bbox[0]
    tx = (w - tw) // 2
    ty = int(h * 0.08)
    # Gradient-ish effect: draw twice with offset
    draw.text((tx+1, ty+1), title, fill=(60,40,20), font=title_font)
    draw.text((tx, ty), title, fill=CREAM, font=title_font)

    # Tagline
    tag = "Tilt your MacBook. Spill the coffee."
    bbox = draw.textbbox((0,0), tag, font=sub_font)
    tw = bbox[2] - bbox[0]
    draw.text(((w-tw)//2, ty + int(85*scale)), tag, fill=(*CREAM, 170), font=sub_font)

    # Bottom text
    bottom = "100% for Gaza's children  |  $1.49"
    bbox = draw.textbbox((0,0), bottom, font=tag_font)
    tw = bbox[2] - bbox[0]
    by = int(h * 0.88)

    # Palestine flag stripe behind text
    stripe_h = int(30 * scale)
    draw.rectangle([0, by - int(5*scale), w, by + stripe_h], fill=(0, 80, 50, 40))
    draw.text(((w-tw)//2, by), bottom, fill=CREAM, font=tag_font)

    # Price badge
    badge_font = try_font(int(14 * scale))
    badge = "LAUNCH 50% OFF"
    bbox = draw.textbbox((0,0), badge, font=badge_font)
    bw = bbox[2] - bbox[0] + int(20*scale)
    bh = bbox[3] - bbox[1] + int(12*scale)
    bx = w - bw - int(16*scale)
    by2 = int(12*scale)
    draw.rounded_rectangle([bx, by2, bx+bw, by2+bh], radius=int(12*scale), fill=(232, 93, 93))
    draw.text((bx + int(10*scale), by2 + int(4*scale)), badge, fill=(255,255,255), font=badge_font)

    # Emoji face on mug
    emoji_font = try_font(int(36 * scale))
    draw.text((w//2 - int(14*scale), mug_cy - int(12*scale)), "😩", font=emoji_font)

    img = img.convert('RGB')
    img.save(os.path.join(OUT, filename), quality=95)
    print(f"  Created: {filename} ({w}x{h})")
    return img


def make_app_icon():
    """Generate macOS app icon (1024x1024)."""
    s = 1024
    img = Image.new('RGBA', (s, s), (0,0,0,0))
    draw = ImageDraw.Draw(img)

    # Rounded square background
    draw.rounded_rectangle([0, 0, s, s], radius=220, fill=BG)

    # Subtle grid
    for x in range(0, s, 80):
        draw.line([(x, 0), (x, s)], fill=(255,255,255,8), width=1)
    for y in range(0, s, 80):
        draw.line([(0, y), (s, y)], fill=(255,255,255,8), width=1)

    # Glow
    draw_glow(img, s//2, s//2, 350, COFFEE, alpha=20)
    draw = ImageDraw.Draw(img)

    # Mug (centered, big)
    draw_mug(draw, s//2, int(s*0.52), scale=2.8)

    # Emoji
    emoji_font = try_font(100)
    draw.text((s//2 - 40, int(s*0.44)), "😩", font=emoji_font)

    # Title at bottom
    title_font = try_font(80)
    title = "TiltBrew"
    bbox = draw.textbbox((0,0), title, font=title_font)
    tw = bbox[2] - bbox[0]
    draw.text(((s-tw)//2, int(s*0.82)), title, fill=CREAM, font=title_font)

    img.save(os.path.join(OUT, 'icon_1024.png'), quality=95)
    print(f"  Created: icon_1024.png (1024x1024)")

    # Generate smaller sizes
    for size in [512, 256, 128, 64, 32, 16]:
        small = img.resize((size, size), Image.LANCZOS)
        small.save(os.path.join(OUT, f'icon_{size}.png'), quality=95)
        print(f"  Created: icon_{size}.png ({size}x{size})")


print("Generating TiltBrew assets...\n")

# Gumroad/Lemon Squeezy cover (1280x720)
make_cover(1280, 720, 'cover_1280x720.png')

# Thumbnail (600x600)
make_cover(600, 600, 'thumb_600x600.png')

# OG image for social sharing (1200x630)
make_cover(1200, 630, 'og-image.png')

# Twitter card (1200x600)
make_cover(1200, 600, 'twitter-card.png')

# App icon
make_app_icon()

# Copy OG image to landing/docs for GitHub Pages
import shutil
for dest in ['landing', 'docs']:
    dest_path = os.path.join(os.path.dirname(__file__), '..', dest)
    if os.path.isdir(dest_path):
        shutil.copy(os.path.join(OUT, 'og-image.png'), dest_path)
        print(f"\n  Copied og-image.png to {dest}/")

print("\nAll assets generated in assets/")
