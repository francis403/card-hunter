#!/usr/bin/env python3
"""
Generates a professional 32x32 pixel-art crab monster sprite.
Style reference: Monster Hunter x Slay the Spire.

Usage (from project root):
    python3 generate_crab_sprite.py

Requires Pillow:
    pip install Pillow
"""

from PIL import Image

# ──────────────────────────────────────────────────────────
# CONFIGURATION
# ──────────────────────────────────────────────────────────
SIZE   = 32
OUTPUT = (
    "scenes/monsters/generic_monsters/"
    "crab_angler_monster_1/crab_monster_1.png"
)

# ──────────────────────────────────────────────────────────
# COLOUR PALETTE  (all RGBA tuples)
# ──────────────────────────────────────────────────────────
T   = (0, 0, 0, 0)           # transparent
OL  = (10, 5, 5, 255)        # dark outline

# Carapace – crimson → orange-gold gradient (8 shades)
SH = [
    (48,  10,  8,  255),     # S[0] darkest shadow
    (88,  20,  13, 255),     # S[1]
    (130, 36,  20, 255),     # S[2]
    (170, 56,  28, 255),     # S[3]
    (206, 84,  42, 255),     # S[4] base
    (238, 118, 60, 255),     # S[5]
    (255, 158, 84, 255),     # S[6]
    (255, 205, 125, 255),    # S[7] specular
]

# Claw – warm orange-brown (7 shades)
CL = [
    (58,  18,  8,  255),     # C[0] darkest
    (98,  30,  14, 255),     # C[1]
    (140, 48,  22, 255),     # C[2]
    (178, 70,  32, 255),     # C[3]
    (215, 102, 50, 255),     # C[4]
    (248, 142, 72, 255),     # C[5]
    (255, 182, 102, 255),    # C[6] bright tip
]

LG  = (70,  18, 10, 255)     # leg dark
LM  = (112, 33, 17, 255)     # leg mid
LLT = (150, 50, 25, 255)     # leg light highlight

EST = (86, 22, 12, 255)      # eye stalk

EBG = (18,  12,  6,  255)    # eye sclera / dark bg
EOR = (255, 152,  8, 255)    # eye orange iris ring
EYL = (255, 238, 30, 255)    # eye yellow pupil
ESH = (255, 255, 210, 255)   # eye specular shine

SPN = (255, 218, 72, 255)    # rostrum spine tip (gold)

# ──────────────────────────────────────────────────────────
# CANVAS + PIXEL HELPERS
# ──────────────────────────────────────────────────────────
img = Image.new("RGBA", (SIZE, SIZE), T)


def P(x: int, y: int, c: tuple) -> None:
    """Set pixel, silently clips to canvas bounds."""
    if 0 <= x < SIZE and 0 <= y < SIZE:
        img.putpixel((x, y), c)


def G(x: int, y: int) -> tuple:
    """Get pixel; returns transparent if out-of-bounds."""
    if 0 <= x < SIZE and 0 <= y < SIZE:
        return img.getpixel((x, y))
    return T


def bresenham(x0: int, y0: int, x1: int, y1: int):
    """Yield every (x, y) pixel on a Bresenham rasterised line."""
    dx, dy = abs(x1 - x0), abs(y1 - y0)
    sx = 1 if x1 > x0 else -1
    sy = 1 if y1 > y0 else -1
    err = dx - dy
    while True:
        yield x0, y0
        if x0 == x1 and y0 == y1:
            break
        e2 = 2 * err
        if e2 > -dy:
            err -= dy; x0 += sx
        if e2 < dx:
            err += dx; y0 += sy


def scanfill(verts: list, color_fn) -> None:
    """
    Scanline-fill a convex polygon.
    color_fn(x, y) -> RGBA tuple.
    Uses the half-open [top, bottom) convention to avoid double fills.
    """
    ys    = [v[1] for v in verts]
    min_y = max(0,       min(ys))
    max_y = min(SIZE - 1, max(ys))
    n     = len(verts)

    for y in range(min_y, max_y + 1):
        xs = []
        for i in range(n):
            x0, y0 = verts[i]
            x1, y1 = verts[(i + 1) % n]
            if y0 == y1:
                continue                         # skip horizontal edges
            lo, hi = (y0, y1) if y0 < y1 else (y1, y0)
            if lo <= y < hi:                     # half-open interval
                t = (y - y0) / (y1 - y0)
                xs.append(x0 + t * (x1 - x0))
        xs.sort()
        for j in range(0, len(xs) - 1, 2):
            for x in range(round(xs[j]), round(xs[j + 1]) + 1):
                if 0 <= x < SIZE:
                    P(x, y, color_fn(x, y))


def fill_ellipse(cx: float, cy: float,
                 rx: float, ry: float, color_fn) -> None:
    """
    Fill every pixel inside the ellipse.
    color_fn(nx, ny) -> RGBA, where nx/ny are normalised coords [-1, 1].
    """
    for y in range(max(0, round(cy - ry) - 1),
                   min(SIZE, round(cy + ry) + 2)):
        for x in range(max(0, round(cx - rx) - 1),
                       min(SIZE, round(cx + rx) + 2)):
            nx = (x - cx) / rx
            ny = (y - cy) / ry
            if nx * nx + ny * ny <= 1.0:
                P(x, y, color_fn(nx, ny))


def expand_outline() -> None:
    """
    Add a 1-pixel dark border around all opaque regions.
    Reads a frozen snapshot to avoid cascading neighbour checks.
    """
    snap = [img.getpixel((x, y))
            for y in range(SIZE) for x in range(SIZE)]
    new  = list(snap)
    DIRS = ((-1, 0), (1, 0), (0, -1), (0, 1))
    for y in range(SIZE):
        for x in range(SIZE):
            if snap[y * SIZE + x][3] == 0:          # transparent pixel
                for dx, dy in DIRS:
                    nx2, ny2 = x + dx, y + dy
                    if 0 <= nx2 < SIZE and 0 <= ny2 < SIZE:
                        if snap[ny2 * SIZE + nx2][3] > 0:
                            new[y * SIZE + x] = OL
                            break
    for y in range(SIZE):
        for x in range(SIZE):
            img.putpixel((x, y), new[y * SIZE + x])


def darken(c: tuple, by: int) -> tuple:
    """Darken an RGBA colour, preserving a warm red-shell tint."""
    return (max(0, c[0] - by),
            max(0, c[1] - by * 2 // 3),
            max(0, c[2] - by // 2),
            c[3])


# ══════════════════════════════════════════════════════════
# DRAWING – back to front (painter's algorithm)
# ══════════════════════════════════════════════════════════

# ──────────────────────────────────────────────────────────
# 1.  LEGS  (drawn first; body and claws paint over the roots)
# ──────────────────────────────────────────────────────────
# Each leg: (shoulder_x, shoulder_y, tip_x, tip_y)
LEFT_LEGS  = [(9, 20, 3, 26), (11, 21, 5, 28), (13, 22, 7, 30)]
RIGHT_LEGS = [(23, 20, 29, 26), (21, 21, 27, 28), (19, 22, 25, 30)]

for x0, y0, x1, y1 in LEFT_LEGS:
    for bx, by in bresenham(x0, y0, x1, y1):
        P(bx,     by,     LM)
        P(bx - 1, by - 1, LLT)         # highlight along upper-left edge
    # darker colour for the lower half (tip in shadow)
    mx, my = (x0 + x1) // 2, (y0 + y1) // 2
    for bx, by in bresenham(mx, my, x1, y1):
        P(bx, by, LG)

for x0, y0, x1, y1 in RIGHT_LEGS:
    for bx, by in bresenham(x0, y0, x1, y1):
        P(bx,     by,     LM)
        P(bx + 1, by - 1, LLT)         # highlight along upper-right edge
    mx, my = (x0 + x1) // 2, (y0 + y1) // 2
    for bx, by in bresenham(mx, my, x1, y1):
        P(bx, by, LG)

# ──────────────────────────────────────────────────────────
# 2.  CLAWS  (behind body; each side has arm + two pincer jaws)
# ──────────────────────────────────────────────────────────

def lclaw_shade(x: int, _y: int) -> tuple:
    """Left claw: brightest at tip (x=0), darkest at body (x=10)."""
    t   = 1.0 - max(0.0, min(1.0, x / 10.0))
    idx = round(t * (len(CL) - 2))
    return CL[idx + 1]


def rclaw_shade(x: int, _y: int) -> tuple:
    """Right claw: brightest at tip (x=31), darkest at body (x=21)."""
    t   = 1.0 - max(0.0, min(1.0, (31 - x) / 10.0))
    idx = round(t * (len(CL) - 2))
    return CL[idx + 1]


# Left arm block  (connects fingers to body)
scanfill([(10, 12), (10, 20), (7, 20), (7, 12)], lambda x, y: CL[2])
# Left upper jaw
scanfill([(0, 10), (8, 12), (8, 14), (0, 13)], lclaw_shade)
# Left lower jaw
scanfill([(0, 20), (8, 18), (8, 21), (0, 23)], lclaw_shade)
# Gold tips
for bx, by in [(0, 10), (0, 11), (0, 21), (0, 22)]:
    P(bx, by, CL[6])
# Dark inner gap (menacing pincer shadow)
for by in [13, 14, 18, 19, 20]:
    P(1, by, CL[0])

# Right arm block (mirror)
scanfill([(22, 12), (22, 20), (25, 20), (25, 12)], lambda x, y: CL[2])
# Right upper jaw
scanfill([(31, 10), (23, 12), (23, 14), (31, 13)], rclaw_shade)
# Right lower jaw
scanfill([(31, 20), (23, 18), (23, 21), (31, 23)], rclaw_shade)
for bx, by in [(31, 10), (31, 11), (31, 21), (31, 22)]:
    P(bx, by, CL[6])
for by in [13, 14, 18, 19, 20]:
    P(30, by, CL[0])

# ──────────────────────────────────────────────────────────
# 3.  BODY CARAPACE  (wide ellipse, top-lit with 8 shade stops)
#     Centre (16, 17) · radii 9.5 × 6.5
# ──────────────────────────────────────────────────────────

def shell_shade(nx: float, ny: float) -> tuple:
    """
    Directional light from above with slight left bias.
    ny = -1 → top of shell (bright); ny = +1 → bottom (dark).
    """
    light = -ny * 0.80 - nx * 0.22
    if   light >  0.60: return SH[7]
    elif light >  0.38: return SH[6]
    elif light >  0.16: return SH[5]
    elif light > -0.06: return SH[4]
    elif light > -0.26: return SH[3]
    elif light > -0.46: return SH[2]
    elif light > -0.66: return SH[1]
    else:               return SH[0]


fill_ellipse(16, 17, 9.5, 6.5, shell_shade)

# ── Armour segment grooves (Monster Hunter plate look) ──
for groove_y, strength in [(14, 40), (20, 30)]:
    for x in range(7, 26):
        nx = (x - 16) / 9.5
        ny = (groove_y - 17) / 6.5
        if nx * nx + ny * ny < 0.97:
            c = G(x, groove_y)
            if c[3] > 0:
                P(x, groove_y, darken(c, strength))
            # Rim-light pixel just below each groove
            c2 = G(x, groove_y + 1)
            if c2[3] > 0:
                P(x, groove_y + 1, (
                    min(255, c2[0] + 18),
                    min(255, c2[1] + 12),
                    min(255, c2[2] +  8),
                    255,
                ))

# Vertical centre groove (bilateral symmetry axis)
for y in range(12, 24):
    ny = (y - 17) / 6.5
    if ny * ny < 0.97:
        c = G(16, y)
        if c[3] > 0:
            P(16, y, darken(c, 25))

# ──────────────────────────────────────────────────────────
# 4.  EYE STALKS  (2-pixel-wide columns rising from carapace)
# ──────────────────────────────────────────────────────────
for y in range(10, 14):
    P(11, y, EST);  P(12, y, EST)   # left stalk
    P(20, y, EST);  P(21, y, EST)   # right stalk

# ──────────────────────────────────────────────────────────
# 5.  EYES  (3×3 iris, bright yellow pupil, specular shine)
# ──────────────────────────────────────────────────────────

def draw_eye(cx: int, cy: int) -> None:
    # Dark sclera background (3×3)
    for dx in range(-1, 2):
        for dy in range(-1, 2):
            P(cx + dx, cy + dy, EBG)
    # Orange iris ring (cross pattern)
    for bx, by in [(cx-1, cy), (cx+1, cy), (cx, cy-1), (cx, cy+1)]:
        P(bx, by, EOR)
    P(cx, cy, EYL)           # bright yellow pupil
    P(cx - 1, cy - 1, ESH)  # specular shine (top-left)


draw_eye(11, 9)   # left eye
draw_eye(20, 9)   # right eye

# ──────────────────────────────────────────────────────────
# 6.  CENTRAL ROSTRUM / SPINE
#     Small gold spine at the crown of the carapace.
# ──────────────────────────────────────────────────────────
P(15, 12, SH[5]);  P(16, 11, SH[6]);  P(17, 12, SH[5])
P(15, 11, SH[4]);  P(17, 11, SH[4])
P(16, 10, SPN)     # glowing golden tip

# ──────────────────────────────────────────────────────────
# 7.  OUTLINE PASS
#     Flood 1-pixel border around every opaque region with OL.
# ──────────────────────────────────────────────────────────
expand_outline()

# Manually ensure thin stalk columns get a clean outline
for y in range(9, 14):
    for ox in [10, 13, 19, 22]:
        if G(ox, y)[3] == 0:
            P(ox, y, OL)

# ──────────────────────────────────────────────────────────
# SAVE
# ──────────────────────────────────────────────────────────
img.save(OUTPUT)
print(f"Sprite saved -> {OUTPUT}")
print(f"Canvas: {img.size[0]}x{img.size[1]} px, mode: {img.mode}")