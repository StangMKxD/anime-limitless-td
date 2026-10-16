#!/usr/bin/env python3
"""High-Detail Masterpiece Roblox Model XML (.rbxmx) Asset Builder for One Piece Limitless TD.
Generates 19 unmistakable, multi-layered One Piece 3D models (12 Heroes, 4 Enemies, 3 Map Structures)
using Block, Ball, Cylinder, Wedge, and CornerWedge primitives with true 3D orientation matrices.
All asset geometry is anchored/no-collision, with unique names and zero executable instances.
"""
from __future__ import annotations
import json
import math
import pathlib
import xml.etree.ElementTree as ET

ROOT = pathlib.Path(__file__).parent

SKIN = (242, 192, 150)
LIGHT_SKIN = (255, 214, 178)
TAN_SKIN = (218, 162, 118)
DARK_SKIN = (178, 126, 88)
BLACK = (24, 25, 32)
CHARCOAL = (38, 40, 50)
RED = (210, 38, 48)
CRIMSON = (155, 22, 32)
WHITE = (248, 248, 252)
IVORY = (242, 235, 215)
GOLD = (248, 192, 52)
BRASS = (198, 145, 42)
BLUE = (42, 98, 182)
NAVY = (26, 45, 92)
CYAN = (55, 215, 255)
GREEN = (42, 138, 78)
EMERALD = (55, 235, 115)
PURPLE = (155, 55, 235)
ORANGE = (248, 118, 28)
PINK = (238, 108, 155)
WOOD = (108, 68, 42)
STEEL = (215, 224, 235)
DARK_STEEL = (95, 104, 118)

CHARACTERS = [
    'Luffy', 'Zoro', 'Nami', 'Usopp', 'Sanji', 'Chopper',
    'Robin', 'Shanks', 'Whitebeard', 'Ace', 'Law', 'Kizaru'
]
ENEMIES = ['PirateGrunt', 'SoruAssassin', 'HakiBrute', 'YonkoBoss']
SCENERY = ['AnimeBaseCrystal', 'EnemySpawnGate', 'PlacementPadTemplate']


def euler_to_matrix(rot: tuple[float, float, float]) -> list[list[float]]:
    rx, ry, rz = [math.radians(t) for t in rot]
    cx, sx = math.cos(rx), math.sin(rx)
    cy, sy = math.cos(ry), math.sin(ry)
    cz, sz = math.cos(rz), math.sin(rz)
    return [
        [cz * cy, cz * sy * sx - sz * cx, cz * sy * cx + sz * sx],
        [sz * cy, sz * sy * sx + cz * cx, sz * sy * cx - cz * sx],
        [-sy, cy * sx, cy * cx],
    ]


def align_y_matrix(p1: tuple[float, float, float], p2: tuple[float, float, float]) -> list[list[float]]:
    """Construct an orthonormal 3x3 rotation matrix whose local Y axis points from p1 to p2."""
    dx, dy, dz = p2[0] - p1[0], p2[1] - p1[1], p2[2] - p1[2]
    length = math.sqrt(dx * dx + dy * dy + dz * dz)
    if length < 1e-6:
        return [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]]
    uy = (dx / length, dy / length, dz / length)
    ref = (0.0, 0.0, 1.0) if abs(uy[2]) < 0.9 else (1.0, 0.0, 0.0)
    # ux = uy x ref
    ux = (
        uy[1] * ref[2] - uy[2] * ref[1],
        uy[2] * ref[0] - uy[0] * ref[2],
        uy[0] * ref[1] - uy[1] * ref[0],
    )
    ux_len = math.sqrt(ux[0] ** 2 + ux[1] ** 2 + ux[2] ** 2)
    ux = (ux[0] / ux_len, ux[1] / ux_len, ux[2] / ux_len)
    # uz = ux x uy
    uz = (
        ux[1] * uy[2] - ux[2] * uy[1],
        ux[2] * uy[0] - ux[0] * uy[2],
        ux[0] * uy[1] - ux[1] * uy[0],
    )
    return [
        [ux[0], uy[0], uz[0]],
        [ux[1], uy[1], uz[1]],
        [ux[2], uy[2], uz[2]],
    ]


class Asset:
    def __init__(self, name: str):
        self.name = name
        self.parts: list[dict] = []
        self.used: set[str] = set()

    def add(
        self,
        name: str,
        xyz: tuple[float, float, float],
        sz: tuple[float, float, float],
        col: tuple[int, int, int],
        kind: str = 'Block',
        rot: tuple[float, float, float] = (0, 0, 0),
        material: str = 'SmoothPlastic',
        opacity: float = 1.0,
        mat3: list[list[float]] | None = None,
    ) -> str:
        n = name
        count = 2
        while n in self.used:
            n = f'{name}_{count}'
            count += 1
        self.used.add(n)
        self.parts.append({
            'name': n,
            'pos': tuple(float(x) for x in xyz),
            'size': tuple(max(0.04, float(x)) for x in sz),
            'color': tuple(int(c) for c in col),
            'kind': kind,
            'rot': rot,
            'mat3': mat3,
            'material': material,
            'trans': round(1.0 - opacity, 3),
        })
        return n

    def box(self, n, p, s, c, rot=(0, 0, 0), **kw):
        return self.add(n, p, s, c, kind='Block', rot=rot, **kw)

    def wedge(self, n, p, s, c, rot=(0, 0, 0), **kw):
        return self.add(n, p, s, c, kind='Wedge', rot=rot, **kw)

    def corner_wedge(self, n, p, s, c, rot=(0, 0, 0), **kw):
        return self.add(n, p, s, c, kind='CornerWedge', rot=rot, **kw)

    def ball(self, n, p, s, c, rot=(0, 0, 0), **kw):
        return self.add(n, p, s, c, kind='Ball', rot=rot, **kw)

    def disc(self, n, p, diam, thick, c, rot=(0, 0, 90), **kw):
        return self.add(n, p, (thick, diam, diam), c, kind='Cylinder', rot=rot, **kw)

    def cyl(self, n, p, diam, height, c, rot=(0, 0, 90), **kw):
        return self.add(n, p, (height, diam, diam), c, kind='Cylinder', rot=rot, **kw)

    def rod(self, n, p1, p2, width, col, **kw):
        dx, dy, dz = p2[0] - p1[0], p2[1] - p1[1], p2[2] - p1[2]
        length = max(0.05, math.sqrt(dx * dx + dy * dy + dz * dz))
        mid = ((p1[0] + p2[0]) / 2.0, (p1[1] + p2[1]) / 2.0, (p1[2] + p2[2]) / 2.0)
        mat3 = align_y_matrix(p1, p2)
        return self.add(n, mid, (width, length, width), col, kind='Block', mat3=mat3, **kw)

    def taper_rod(self, n, p1, p2, w_start, w_end, col, segments=3, **kw):
        for i in range(segments):
            t0 = i / segments
            t1 = (i + 1) / segments
            tm = (t0 + t1) / 2.0
            q0 = tuple(p1[k] + (p2[k] - p1[k]) * t0 for k in range(3))
            q1 = tuple(p1[k] + (p2[k] - p1[k]) * t1 for k in range(3))
            w = w_start + (w_end - w_start) * tm
            self.rod(f'{n}_Seg{i+1}', q0, q1, w, col, **kw)


def add_detailed_face(
    a: Asset,
    skin=SKIN,
    expr='grin',
    eye_color=BLACK,
    brow_color=BLACK,
    head_y=1.92,
    scale=1.0,
):
    z_front = -0.76 * scale
    # Sculpted nose bridge & tip
    a.wedge('NoseBridge', (0, head_y + 0.02 * scale, z_front - 0.04 * scale), (0.14 * scale, 0.24 * scale, 0.14 * scale), skin, rot=(0, 180, 0))
    a.ball('NoseTip', (0, head_y - 0.06 * scale, z_front - 0.08 * scale), (0.16 * scale, 0.14 * scale, 0.15 * scale), skin)
    # Ears
    for side in (-1, 1):
        a.ball('Ear', (side * 0.80 * scale, head_y - 0.02 * scale, -0.05 * scale), (0.16 * scale, 0.34 * scale, 0.24 * scale), skin)

    # Eyes & Eyebrows
    for side in (-1, 1):
        ex = side * 0.34 * scale
        ey = head_y + 0.12 * scale
        a.ball('EyeSclera', (ex, ey, z_front), (0.34 * scale, 0.28 * scale, 0.12 * scale), WHITE)
        a.ball('EyeIris', (ex, ey, z_front - 0.05 * scale), (0.18 * scale, 0.20 * scale, 0.10 * scale), eye_color)
        a.ball('EyeCatchlight', (ex + side * 0.04 * scale, ey + 0.05 * scale, z_front - 0.09 * scale), (0.07 * scale, 0.07 * scale, 0.07 * scale), WHITE, material='Neon')
        a.box('UpperEyelid', (ex, ey + 0.12 * scale, z_front - 0.04 * scale), (0.36 * scale, 0.05 * scale, 0.12 * scale), BLACK, rot=(0, 0, -side * 6))
        a.box('Eyebrow', (ex, ey + 0.22 * scale, z_front - 0.05 * scale), (0.40 * scale, 0.07 * scale, 0.12 * scale), brow_color, rot=(0, 0, -side * (12 if expr in ('stern', 'fierce') else 5)))

    # Mouth expressions
    my = head_y - 0.30 * scale
    if expr == 'grin':
        a.box('MouthCavity', (0, my, z_front - 0.02 * scale), (0.58 * scale, 0.18 * scale, 0.08 * scale), (70, 28, 35))
        a.box('UpperTeeth', (0, my + 0.04 * scale, z_front - 0.05 * scale), (0.52 * scale, 0.07 * scale, 0.07 * scale), WHITE)
        a.box('LowerTeeth', (0, my - 0.04 * scale, z_front - 0.05 * scale), (0.48 * scale, 0.06 * scale, 0.07 * scale), WHITE)
        for side in (-1, 1):
            a.box('SmileCorner', (side * 0.30 * scale, my + 0.03 * scale, z_front - 0.04 * scale), (0.10 * scale, 0.12 * scale, 0.06 * scale), BLACK, rot=(0, 0, side * 20))
    elif expr == 'smirk':
        a.box('SmirkLine', (0.05 * scale, my, z_front - 0.04 * scale), (0.44 * scale, 0.05 * scale, 0.06 * scale), BLACK, rot=(0, 0, -8))
        a.box('SmirkTeeth', (0.12 * scale, my + 0.03 * scale, z_front - 0.05 * scale), (0.24 * scale, 0.06 * scale, 0.06 * scale), WHITE, rot=(0, 0, -8))
    elif expr == 'stern':
        a.box('SternMouth', (0, my, z_front - 0.04 * scale), (0.40 * scale, 0.05 * scale, 0.06 * scale), BLACK)
        a.box('ChinShadow', (0, my - 0.10 * scale, z_front - 0.03 * scale), (0.22 * scale, 0.04 * scale, 0.06 * scale), (185, 135, 102))
    elif expr == 'fierce':
        a.box('RoarMouth', (0, my, z_front - 0.03 * scale), (0.62 * scale, 0.24 * scale, 0.10 * scale), (60, 20, 25))
        for side in (-1, 1):
            a.wedge('FangTop', (side * 0.20 * scale, my + 0.05 * scale, z_front - 0.07 * scale), (0.09 * scale, 0.12 * scale, 0.08 * scale), WHITE, rot=(180, 0, 0))
            a.wedge('FangBot', (side * 0.20 * scale, my - 0.05 * scale, z_front - 0.07 * scale), (0.09 * scale, 0.12 * scale, 0.08 * scale), WHITE)


def add_sculpted_hair(a: Asset, color=BLACK, style='spiky', head_y=1.92, scale=1.0):
    # Cranium hair cap
    a.ball('HairDome', (0, head_y + 0.26 * scale, 0.08 * scale), (1.72 * scale, 1.42 * scale, 1.74 * scale), color)
    a.box('HairCrown', (0, head_y + 0.62 * scale, 0.02 * scale), (1.58 * scale, 0.36 * scale, 1.58 * scale), color)

    if style == 'spiky':
        spikes = [
            (-0.68, 0.55, -0.55, (25, 20, 32)),
            (-0.35, 0.65, -0.68, (32, 8, 15)),
            (0.0, 0.68, -0.72, (35, 0, 0)),
            (0.35, 0.65, -0.68, (32, -8, -15)),
            (0.68, 0.55, -0.55, (25, -20, -32)),
            (-0.78, 0.35, -0.15, (10, 45, 42)),
            (0.78, 0.35, -0.15, (10, -45, -42)),
            (-0.55, 0.60, 0.55, (-28, -20, 25)),
            (0.0, 0.66, 0.65, (-32, 0, 0)),
            (0.55, 0.60, 0.55, (-28, 20, -25)),
        ]
        for idx, (ox, oy, oz, rot) in enumerate(spikes):
            a.wedge(f'HairSpike_{idx+1}', (ox * scale, head_y + oy * scale, oz * scale), (0.34 * scale, 0.52 * scale, 0.44 * scale), color, rot=rot)
    elif style == 'zoro':
        for idx in range(12):
            ang = idx * (2 * math.pi / 12)
            rx = math.cos(ang) * 0.62 * scale
            rz = math.sin(ang) * 0.62 * scale
            a.wedge(f'ZoroSpike_{idx+1}', (rx, head_y + 0.68 * scale, rz), (0.34 * scale, 0.52 * scale, 0.38 * scale), color, rot=(math.degrees(math.sin(ang) * 0.5), math.degrees(ang), math.degrees(-math.cos(ang) * 0.5)))
    elif style == 'sanji':
        # Swooping blonde bangs covering the left eye (-X side)
        a.wedge('SanjiSweep_1', (-0.38 * scale, head_y + 0.25 * scale, -0.74 * scale), (0.68 * scale, 0.78 * scale, 0.28 * scale), color, rot=(12, 15, 22))
        a.wedge('SanjiSweep_2', (-0.56 * scale, head_y + 0.14 * scale, -0.68 * scale), (0.48 * scale, 0.72 * scale, 0.26 * scale), color, rot=(15, 25, 32))
        a.wedge('SanjiRightBang', (0.52 * scale, head_y + 0.36 * scale, -0.64 * scale), (0.42 * scale, 0.50 * scale, 0.24 * scale), color, rot=(10, -15, -18))
    elif style == 'shanks':
        # Middle-parted crimson curtains
        for side in (-1, 1):
            a.wedge('ShanksCurtainFront', (side * 0.54 * scale, head_y + 0.18 * scale, -0.62 * scale), (0.46 * scale, 0.88 * scale, 0.34 * scale), color, rot=(12, -side * 18, -side * 22))
            a.wedge('ShanksCurtainSide', (side * 0.78 * scale, head_y + 0.08 * scale, -0.18 * scale), (0.34 * scale, 0.92 * scale, 0.56 * scale), color, rot=(0, 0, -side * 16))
        a.box('ShanksNapeHair', (0, head_y - 0.12 * scale, 0.68 * scale), (1.52 * scale, 0.76 * scale, 0.42 * scale), color)
    elif style == 'long_wave':
        a.box('LongHairBack', (0, head_y - 0.42 * scale, 0.66 * scale), (1.62 * scale, 2.35 * scale, 0.55 * scale), color)
        for side in (-1, 1):
            a.box('ShoulderLock', (side * 0.68 * scale, head_y - 0.28 * scale, -0.32 * scale), (0.36 * scale, 1.85 * scale, 0.42 * scale), color, rot=(8, 0, side * 8))
            a.ball('HairWaveCurl', (side * 0.72 * scale, head_y - 1.12 * scale, -0.36 * scale), (0.44 * scale, 0.44 * scale, 0.44 * scale), color)
    elif style == 'afro':
        a.ball('AfroMain', (0, head_y + 0.55 * scale, 0.12 * scale), (2.35 * scale, 2.15 * scale, 2.35 * scale), color)
        for ox, oy, oz in [(-0.75, 0.55, 0.1), (0.75, 0.55, 0.1), (0, 0.95, 0.15), (0, 0.45, 0.85), (-0.55, 0.25, 0.65), (0.55, 0.25, 0.65)]:
            a.ball('AfroPuff', (ox * scale, head_y + oy * scale, oz * scale), (1.15 * scale, 1.15 * scale, 1.15 * scale), color)


def make_base_body(
    name: str,
    skin=SKIN,
    top=BLUE,
    bottom=CHARCOAL,
    shoe=BLACK,
    scale=1.0,
    woman=False,
    left_arm_present=True,
    right_arm_present=True,
    bare_chest=False,
) -> Asset:
    a = Asset(name)
    # PrimaryPart MUST be RBX0 named HumanoidRootPart
    a.box('HumanoidRootPart', (0, 0, 0), (1.8 * scale, 2.0 * scale, 1.0 * scale), WHITE, opacity=0)

    torso_w = (1.88 if woman else 2.10) * scale
    torso_h = 2.08 * scale
    torso_d = 1.04 * scale
    a.box('Torso', (0, 0.12 * scale, 0), (torso_w, torso_h, torso_d), skin if bare_chest else top)
    a.cyl('Neck', (0, 1.28 * scale, 0), 0.52 * scale, 0.40 * scale, skin, rot=(0, 0, 90))
    a.box('Head', (0, 1.92 * scale, 0), (1.56 * scale, 1.54 * scale, 1.52 * scale), skin)
    a.ball('HeadTopBevel', (0, 2.52 * scale, 0), (1.52 * scale, 0.45 * scale, 1.48 * scale), skin)
    a.ball('JawBevel', (0, 1.28 * scale, -0.05 * scale), (1.44 * scale, 0.42 * scale, 1.42 * scale), skin)

    if bare_chest and not woman:
        # Sculpted pectoral & abdominal muscles
        for side in (-1, 1):
            a.box('PectoralMuscle', (side * 0.44 * scale, 0.62 * scale, -0.50 * scale), (0.78 * scale, 0.58 * scale, 0.16 * scale), skin)
            for row in range(3):
                a.box(f'AbPack_{row+1}', (side * 0.24 * scale, 0.14 * scale - row * 0.28 * scale, -0.50 * scale), (0.38 * scale, 0.22 * scale, 0.14 * scale), skin)
    elif woman:
        a.box('WaistTaper', (0, -0.35 * scale, 0), (1.66 * scale, 0.85 * scale, 0.96 * scale), top)

    # Arms
    for side in (-1, 1):
        if (side == -1 and not left_arm_present) or (side == 1 and not right_arm_present):
            # Empty pinned sleeve (e.g., Shanks's left arm)
            a.box('EmptySleeveShoulder', (side * (torso_w * 0.5 + 0.26 * scale), 0.72 * scale, 0), (0.58 * scale, 0.75 * scale, 0.86 * scale), top, rot=(0, 0, side * 8))
            a.box('EmptySleeveFold', (side * (torso_w * 0.5 + 0.22 * scale), 0.05 * scale, 0.04 * scale), (0.46 * scale, 0.82 * scale, 0.62 * scale), top, rot=(6, 0, side * 14))
            continue

        ax = side * (torso_w * 0.5 + 0.38 * scale)
        a.ball('ShoulderCap', (ax, 0.86 * scale, 0), (0.82 * scale, 0.78 * scale, 0.88 * scale), skin if bare_chest else top)
        a.box('UpperArm', (ax, 0.42 * scale, 0), (0.74 * scale, 0.92 * scale, 0.76 * scale), skin if bare_chest else top)
        a.box('Forearm', (ax, -0.34 * scale, -0.06 * scale), (0.68 * scale, 0.90 * scale, 0.70 * scale), skin)
        a.ball('Fist', (ax, -0.92 * scale, -0.10 * scale), (0.74 * scale, 0.56 * scale, 0.76 * scale), skin)
        for f in range(4):
            a.box(f'FingerKnuckle_{f+1}', (ax + (-0.21 + f * 0.14) * scale, -1.08 * scale, -0.26 * scale), (0.12 * scale, 0.22 * scale, 0.24 * scale), skin)

    # Hip & Legs
    a.box('PelvisBeltBase', (0, -0.94 * scale, 0), (torso_w * 0.98, 0.34 * scale, torso_d * 1.02), bottom)
    for side in (-1, 1):
        lx = side * 0.52 * scale
        a.box('Thigh', (lx, -1.38 * scale, 0), (0.88 * scale, 0.98 * scale, 0.92 * scale), bottom)
        a.box('Shin', (lx, -1.98 * scale, 0.02 * scale), (0.82 * scale, 0.86 * scale, 0.86 * scale), bottom)
        a.box('Boot', (lx, -2.34 * scale, -0.18 * scale), (0.90 * scale, 0.42 * scale, 1.36 * scale), shoe)
        a.ball('BootToe', (lx, -2.36 * scale, -0.78 * scale), (0.86 * scale, 0.38 * scale, 0.52 * scale), shoe)

    return a


def add_katana(
    a: Asset,
    prefix: str,
    hand_pos: tuple[float, float, float],
    tip_pos: tuple[float, float, float],
    hilt_color=BLACK,
    guard_color=GOLD,
    blade_color=STEEL,
    haki_flame_color: tuple[int, int, int] | None = None,
):
    dx, dy, dz = tip_pos[0] - hand_pos[0], tip_pos[1] - hand_pos[1], tip_pos[2] - hand_pos[2]
    L = max(0.1, math.sqrt(dx * dx + dy * dy + dz * dz))
    ux, uy, uz = dx / L, dy / L, dz / L
    pommel = (hand_pos[0] - ux * 0.85, hand_pos[1] - uy * 0.85, hand_pos[2] - uz * 0.85)
    guard = (hand_pos[0] + ux * 0.18, hand_pos[1] + uy * 0.18, hand_pos[2] + uz * 0.18)

    a.rod(prefix + '_Hilt', pommel, guard, 0.20, hilt_color)
    # Diamond wrap rings on hilt
    for i in range(4):
        t = (i + 0.5) / 4.0
        hp = (pommel[0] + (guard[0] - pommel[0]) * t, pommel[1] + (guard[1] - pommel[1]) * t, pommel[2] + (guard[2] - pommel[2]) * t)
        a.ball(f'{prefix}_HiltWrap_{i+1}', hp, (0.24, 0.12, 0.24), GOLD)
    a.ball(prefix + '_Pommel', pommel, (0.26, 0.26, 0.26), guard_color, material='Metal')
    a.box(prefix + '_TsubaGuard', guard, (0.58, 0.12, 0.58), guard_color, material='Metal')
    a.taper_rod(prefix + '_Blade', guard, tip_pos, 0.18, 0.08, blade_color, segments=4, material='Metal')

    if haki_flame_color:
        for i in range(5):
            t = (i + 1) / 6.0
            fp = (
                guard[0] + (tip_pos[0] - guard[0]) * t + math.sin(i * 2.1) * 0.14,
                guard[1] + (tip_pos[1] - guard[1]) * t + 0.12,
                guard[2] + (tip_pos[2] - guard[2]) * t + math.cos(i * 2.1) * 0.14,
            )
            a.wedge(f'{prefix}_HakiFlame_{i+1}', fp, (0.28, 0.54, 0.28), haki_flame_color, rot=(i * 35, i * 50, 25), material='Neon', opacity=0.78)


def add_haki_ground_aura(a: Asset, primary_col, secondary_col, radius=2.4, y=-2.50, lightning=True):
    a.disc('HakiGroundRingOuter', (0, y, 0), radius * 2.0, 0.07, primary_col, material='Neon', opacity=0.55)
    a.disc('HakiGroundRingInner', (0, y + 0.03, 0), radius * 1.35, 0.09, secondary_col, material='Neon', opacity=0.72)
    for i in range(8):
        ang = i * (2 * math.pi / 8)
        ox = math.cos(ang) * radius * 0.82
        oz = math.sin(ang) * radius * 0.82
        a.wedge(f'AuraBurstShard_{i+1}', (ox, y + 0.28, oz), (0.22, 0.58, 0.32), primary_col if i % 2 == 0 else secondary_col, rot=(22, math.degrees(-ang), 0), material='Neon', opacity=0.82)
        if lightning and i % 2 == 0:
            p1 = (ox * 0.7, y + 0.2, oz * 0.7)
            p2 = (ox * 1.05, y + 1.45, oz * 1.05 + 0.2)
            p3 = (ox * 0.85, y + 2.65, oz * 0.85 - 0.2)
            a.rod(f'HakiLightningA_{i+1}', p1, p2, 0.11, primary_col, material='Neon')
            a.rod(f'HakiLightningB_{i+1}', p2, p3, 0.08, secondary_col, material='Neon')


def make_character(name: str) -> Asset:
    if name == 'Luffy':
        a = make_base_body(name, skin=SKIN, top=RED, bottom=BLUE, shoe=(185, 145, 78), bare_chest=False)
        add_detailed_face(a, skin=SKIN, expr='grin', eye_color=RED)
        # Iconic Left Eye Scar (2 stitches)
        a.box('UnderEyeScar', (-0.36, 1.82, -0.79), (0.30, 0.04, 0.05), CRIMSON, rot=(0, 0, 15))
        a.box('ScarStitch1', (-0.42, 1.82, -0.80), (0.04, 0.11, 0.05), CRIMSON, rot=(0, 0, 15))
        a.box('ScarStitch2', (-0.30, 1.82, -0.80), (0.04, 0.11, 0.05), CRIMSON, rot=(0, 0, 15))
        add_sculpted_hair(a, BLACK, 'spiky')

        # Open red vest revealing bare chest & Akainu's X-Scar
        a.box('BareChestCenter', (0, 0.22, -0.49), (1.02, 1.78, 0.14), SKIN)
        a.box('ChestScarX_1', (0, 0.34, -0.56), (0.72, 0.14, 0.06), (172, 72, 75), rot=(0, 0, 38))
        a.box('ChestScarX_2', (0, 0.34, -0.56), (0.72, 0.14, 0.06), (172, 72, 75), rot=(0, 0, -38))
        for side in (-1, 1):
            a.box('RedVestFlap', (side * 0.72, 0.18, -0.48), (0.58, 1.92, 0.18), RED)
        for y in (-0.28, 0.15, 0.58):
            a.ball('VestGoldButton', (0.68, y, -0.57), (0.14, 0.14, 0.10), GOLD, material='Metal')

        # Yellow waist sash + white fluffy shorts cuffs
        a.box('YellowWaistSash', (0, -0.88, -0.02), (2.22, 0.42, 1.18), GOLD, material='Fabric')
        a.wedge('SashTailA', (0.85, -1.42, -0.48), (0.38, 0.95, 0.22), GOLD, rot=(12, 0, -16), material='Fabric')
        a.wedge('SashTailB', (1.05, -1.35, -0.38), (0.32, 0.82, 0.20), GOLD, rot=(18, 0, -28), material='Fabric')
        for side in (-1, 1):
            a.cyl('WhiteShortsCuff', (side * 0.52, -1.82, 0), 0.98, 0.28, WHITE, rot=(0, 0, 90), material='Fabric')

        # Iconic Straw Hat (Mugiwara) with woven brim + red ribbon
        a.disc('StrawHatBrim', (0, 2.86, 0.04), 2.88, 0.14, (238, 198, 92), rot=(8, 0, 90), material='Fabric')
        a.ball('StrawHatDome', (0, 3.12, 0.06), (1.76, 1.12, 1.76), (238, 198, 92), material='Fabric')
        a.disc('StrawHatRedBand', (0, 2.98, 0.05), 1.80, 0.22, RED, rot=(8, 0, 90), material='Fabric')
        for i in range(12):
            ang = i * (2 * math.pi / 12)
            a.box(f'StrawWeave_{i+1}', (math.cos(ang) * 1.12, 2.92, 0.04 + math.sin(ang) * 1.12), (0.28, 0.06, 0.12), (218, 172, 68), rot=(0, math.degrees(ang), 0))

        # Gear 5 Nika Awakening Hagoromo Steam Cloud Scarf floating around shoulders!
        cloud_pts = [
            (-1.35, 0.45, 0.35, 0.58), (-1.55, 1.15, 0.42, 0.66), (-1.25, 1.85, 0.50, 0.72),
            (-0.65, 2.35, 0.58, 0.78), (0.0, 2.52, 0.62, 0.84), (0.65, 2.35, 0.58, 0.78),
            (1.25, 1.85, 0.50, 0.72), (1.55, 1.15, 0.42, 0.66), (1.35, 0.45, 0.35, 0.58),
        ]
        for idx, (cx, cy, cz, csz) in enumerate(cloud_pts):
            a.ball(f'Gear5SteamCloud_{idx+1}', (cx, cy, cz), (csz, csz, csz), WHITE, material='Neon', opacity=0.88)

        # Conqueror's Haki Armament Right Fist
        a.ball('HakiBusoFist', (1.43, -0.92, -0.15), (0.96, 0.88, 0.96), (25, 12, 18))
        a.ball('HakiCrimsonGlow', (1.43, -0.92, -0.15), (1.12, 1.04, 1.12), RED, material='Neon', opacity=0.45)
        add_haki_ground_aura(a, RED, WHITE, radius=2.45)
        return a

    elif name == 'Zoro':
        a = make_base_body(name, skin=SKIN, top=GREEN, bottom=CHARCOAL, shoe=BLACK)
        add_detailed_face(a, skin=SKIN, expr='smirk', eye_color=CRIMSON, brow_color=(28, 118, 58))
        # Closed Left Eye & Vertical Scar (+X is character's left side facing -Z)
        a.box('ClosedLeftEyeCover', (0.34, 2.04, -0.78), (0.38, 0.30, 0.14), SKIN)
        a.box('ClosedEyeLine', (0.34, 2.04, -0.85), (0.36, 0.05, 0.06), BLACK)
        a.box('LeftEyeVerticalScar', (0.36, 2.02, -0.86), (0.05, 0.68, 0.06), (155, 62, 65), rot=(0, 0, -6))
        # 3 Gold Earrings on Left Ear
        for i in range(3):
            a.cyl(f'GoldEarring_{i+1}', (0.86, 1.72 - i * 0.09, -0.05 - i * 0.06), 0.07, 0.18, GOLD, rot=(0, 0, 20), material='Metal')

        add_sculpted_hair(a, (42, 178, 86), 'zoro')
        # Black Bandana tied on forehead
        a.cyl('BlackBandana', (0, 2.38, 0), 1.66, 0.34, BLACK, rot=(0, 0, 90), material='Fabric')
        a.wedge('BandanaTail1', (0.25, 2.32, 0.96), (0.28, 0.75, 0.20), BLACK, rot=(-35, 15, 20))
        a.wedge('BandanaTail2', (-0.15, 2.25, 0.98), (0.25, 0.68, 0.18), BLACK, rot=(-42, -12, -18))

        # Open Green Coat + Mihawk Diagonal Chest Scar + Red Haramaki Waistband
        a.box('BareChestDiagonal', (-0.18, 0.35, -0.49), (0.95, 1.45, 0.14), SKIN)
        a.box('MihawkChestScar', (-0.05, 0.32, -0.57), (0.10, 1.55, 0.06), (162, 68, 68), rot=(0, 0, -34))
        a.box('HaramakiWaistWrap', (0, -0.68, 0), (2.26, 0.62, 1.22), (175, 38, 55), material='Fabric')
        a.box('PurpleObiSash', (0, -0.92, -0.02), (2.32, 0.26, 1.26), (112, 42, 148), material='Fabric')
        a.box('GreenCoatSkirt', (0, -1.45, 0.08), (2.28, 1.05, 1.18), (28, 88, 56), material='Fabric')

        # 3 Scabbards on Right Hip (-X side)
        for s_idx in range(3):
            p1 = (-1.18, -0.78 - s_idx * 0.14, -0.45)
            p2 = (-1.35, -1.65 - s_idx * 0.14, 1.15)
            a.rod(f'HipScabbard_{s_idx+1}', p1, p2, 0.16, BLACK if s_idx != 1 else PURPLE)

        # Santoryu: 3 Katanas (Wado in Mouth, Enma in Right Hand, Sandai in Left Hand)
        add_katana(a, 'WadoIchimonji', (-0.35, 1.62, -0.88), (2.35, 1.72, -0.92), hilt_color=WHITE, guard_color=GOLD, blade_color=WHITE)
        add_katana(a, 'Enma', (-1.45, -0.92, -0.25), (-2.95, 1.85, -1.65), hilt_color=PURPLE, guard_color=GOLD, blade_color=BLACK, haki_flame_color=EMERALD)
        add_katana(a, 'SandaiKitetsu', (1.45, -0.92, -0.25), (2.95, 1.85, -1.65), hilt_color=RED, guard_color=GOLD, blade_color=BLACK, haki_flame_color=PURPLE)
        add_haki_ground_aura(a, EMERALD, PURPLE, radius=2.50)
        return a

    elif name == 'Sanji':
        a = make_base_body(name, skin=SKIN, top=BLACK, bottom=BLACK, shoe=BLACK)
        add_detailed_face(a, skin=SKIN, expr='smirk', eye_color=BLUE, brow_color=GOLD)
        # Signature Curly Eyebrow over Right Eye (-X side)
        for c_idx in range(5):
            ang = c_idx * 1.1
            a.ball(f'CurlyBrow_{c_idx+1}', (-0.48 + math.cos(ang) * 0.09, 2.28 + math.sin(ang) * 0.09, -0.82), (0.07, 0.07, 0.07), BLACK)
        # Goatee + Cigarette & Smoke
        a.wedge('BlondeGoatee', (0, 1.46, -0.80), (0.18, 0.24, 0.14), (215, 165, 45), rot=(180, 0, 0))
        a.rod('Cigarette', (0.18, 1.60, -0.80), (0.48, 1.54, -1.18), 0.06, WHITE)
        a.ball('CigaretteEmber', (0.50, 1.53, -1.20), (0.08, 0.08, 0.08), ORANGE, material='Neon')
        for s_idx in range(3):
            a.ball(f'CigSmoke_{s_idx+1}', (0.55 + s_idx * 0.08, 1.72 + s_idx * 0.22, -1.22), (0.14 + s_idx * 0.06, 0.14 + s_idx * 0.06, 0.14), (220, 225, 235), opacity=0.45)

        add_sculpted_hair(a, (248, 206, 68), 'sanji')

        # Double-Breasted Onigashima Suit + Burgundy Shirt & Gold Tie
        a.wedge('BurgundyShirtV', (0, 0.68, -0.50), (0.72, 0.85, 0.14), (138, 24, 38), rot=(180, 0, 0))
        a.box('GoldNecktie', (0, 0.48, -0.56), (0.18, 0.92, 0.08), GOLD)
        for side in (-1, 1):
            a.wedge('SuitLapel', (side * 0.36, 0.58, -0.52), (0.28, 0.95, 0.12), (35, 38, 48), rot=(0, 0, side * 16))
            for row in range(3):
                a.ball(f'SuitButton_{side}_{row}', (side * 0.32, 0.08 - row * 0.28, -0.56), (0.11, 0.11, 0.08), GOLD, material='Metal')

        # Blazing Ifrit Jambe Blue Plasma Flame + White Lightning around Right Leg (-X side)
        for i in range(10):
            t = i / 10.0
            ang = i * 1.35
            fx = -0.52 + math.cos(ang) * 0.46
            fy = -2.35 + t * 1.45
            fz = -0.05 + math.sin(ang) * 0.46
            col = CYAN if i % 2 == 0 else (210, 248, 255)
            a.wedge(f'IfritBlueFlame_{i+1}', (fx, fy, fz), (0.38, 0.62, 0.38), col, rot=(15, math.degrees(ang), -20), material='Neon', opacity=0.78)
        a.cyl('IfritPlasmaCore', (-0.52, -1.85, 0), 0.98, 1.35, (0, 175, 255), rot=(0, 0, 90), material='Neon', opacity=0.48)
        add_haki_ground_aura(a, CYAN, WHITE, radius=2.35)
        return a

    elif name == 'Shanks':
        # Authentic One-Armed Emperor (left_arm_present=False -> character's left side +X is empty sleeve!)
        a = make_base_body(name, skin=SKIN, top=WHITE, bottom=(128, 42, 45), shoe=(95, 62, 38), left_arm_present=True, right_arm_present=False)
        add_detailed_face(a, skin=SKIN, expr='stern', eye_color=BLACK, brow_color=(175, 28, 35))
        # Iconic Triple Scar over Left Eye (+X side)
        for i in range(3):
            a.box(f'BlackbeardScar_{i+1}', (0.24 + i * 0.11, 2.06, -0.80), (0.045, 0.56, 0.06), (145, 32, 42), rot=(0, 0, -14))
        # Stubble beard along jaw
        a.box('JawStubble', (0, 1.42, -0.76), (0.64, 0.08, 0.14), (95, 55, 55))

        add_sculpted_hair(a, (198, 32, 42), 'shanks')

        # Open White Captain Shirt + Red Sash + Patterned Pants
        a.box('ExposedChest', (0, 0.35, -0.49), (0.88, 1.42, 0.14), SKIN)
        a.box('CrimsonWaistSash', (0, -0.88, 0), (2.22, 0.38, 1.18), CRIMSON, material='Fabric')

        # Billowing High-Collar Emperor Black Cloak
        a.box('YonkoCapeMain', (0, -0.15, 0.68), (3.15, 3.35, 0.32), (20, 20, 28), material='Fabric')
        a.box('YonkoHighCollarBack', (0, 1.55, 0.48), (2.45, 0.68, 0.28), (20, 20, 28), material='Fabric')
        for side in (-1, 1):
            a.box('YonkoCollarSide', (side * 1.15, 1.42, 0.05), (0.28, 0.62, 1.05), (20, 20, 28), material='Fabric')
            a.wedge('CapeShoulderDrape', (side * 1.32, 0.85, 0.22), (0.65, 0.95, 1.15), (24, 24, 34), rot=(0, 0, -side * 18), material='Fabric')

        # Legendary Saber Gryphon in Right Hand (-X side) coated in Supreme King Haki!
        add_katana(a, 'Gryphon', (-1.45, -0.92, -0.25), (-2.65, 2.25, -2.15), hilt_color=(125, 32, 38), guard_color=GOLD, blade_color=BLACK, haki_flame_color=RED)
        add_haki_ground_aura(a, RED, BLACK, radius=2.65)
        return a

    elif name == 'Whitebeard':
        scale = 1.32
        a = make_base_body(name, skin=TAN_SKIN, top=WHITE, bottom=(75, 58, 98), shoe=BLACK, scale=scale, bare_chest=True)
        add_detailed_face(a, skin=TAN_SKIN, expr='stern', eye_color=BLACK, brow_color=WHITE, scale=scale)
        # Black Captain Bandana
        a.ball('WhitebeardBandana', (0, 2.22 * scale, 0.08 * scale), (1.62 * scale, 1.15 * scale, 1.64 * scale), BLACK)
        # Iconic Giant Crescent Moon White Mustache!
        a.cyl('MustacheCenter', (0, 1.66 * scale, -0.84 * scale), 0.28 * scale, 1.45 * scale, WHITE, rot=(0, 90, 0))
        for side in (-1, 1):
            p1 = (side * 0.65 * scale, 1.68 * scale, -0.84 * scale)
            p2 = (side * 1.35 * scale, 2.05 * scale, -0.76 * scale)
            p3 = (side * 1.78 * scale, 2.58 * scale, -0.68 * scale)
            a.taper_rod(f'CrescentMustache_{side}', p1, p2, 0.26 * scale, 0.18 * scale, WHITE, segments=2)
            a.taper_rod(f'CrescentMustacheTip_{side}', p2, p3, 0.18 * scale, 0.06 * scale, WHITE, segments=2)

        # Battle Scars on Muscular Chest
        a.box('BattleScar1', (0, 0.55 * scale, -0.58 * scale), (0.78 * scale, 0.08 * scale, 0.06 * scale), (165, 95, 78), rot=(0, 0, 14))
        a.box('BattleScar2', (-0.22 * scale, 0.12 * scale, -0.58 * scale), (0.55 * scale, 0.08 * scale, 0.06 * scale), (165, 95, 78), rot=(0, 0, -22))

        # Draped White Captain Coat with Gold Epaulets
        a.box('WhiteYonkoCoat', (0, -0.10 * scale, 0.72 * scale), (3.25 * scale, 3.45 * scale, 0.35 * scale), IVORY, material='Fabric')
        for side in (-1, 1):
            a.box('GoldEpaulet', (side * 1.38 * scale, 1.12 * scale, 0.18 * scale), (0.68 * scale, 0.24 * scale, 1.12 * scale), GOLD, material='Metal')

        # Supreme Grade Bisento: Murakumogiri in Right Hand (-X side)
        shaft_bot = (-1.58 * scale, -2.30 * scale, -0.35 * scale)
        shaft_top = (-1.68 * scale, 2.65 * scale, -0.45 * scale)
        a.rod('MurakumogiriShaft', shaft_bot, shaft_top, 0.22 * scale, (185, 42, 42))
        for r_idx in range(6):
            ry = -1.6 + r_idx * 0.72
            a.cyl(f'BisentoGoldRing_{r_idx+1}', (-1.63 * scale, ry * scale, -0.40 * scale), 0.28 * scale, 0.14 * scale, GOLD, rot=(0, 0, 90), material='Metal')
        a.cyl('BisentoCollar', shaft_top, 0.46 * scale, 0.32 * scale, GOLD, rot=(0, 0, 90), material='Metal')
        a.wedge('MurakumogiriBlade', (-1.68 * scale, 3.45 * scale, -0.48 * scale), (0.18 * scale, 1.45 * scale, 0.62 * scale), STEEL, rot=(0, 0, 0), material='Metal')

        # Gura Gura no Mi Quake Sphere on Left Fist (+X side)!
        fist_pos = (1.48 * scale, -0.88 * scale, -0.22 * scale)
        a.ball('GuraQuakeSphere', fist_pos, (1.55 * scale, 1.55 * scale, 1.55 * scale), CYAN, material='ForceField', opacity=0.65)
        for q_idx in range(6):
            ang = q_idx * 1.05
            q_end = (fist_pos[0] + math.cos(ang) * 1.1 * scale, fist_pos[1] + math.sin(ang) * 1.1 * scale, fist_pos[2] - 0.5 * scale)
            a.rod(f'SpatialCrack_{q_idx+1}', fist_pos, q_end, 0.08 * scale, WHITE, material='Neon')
        add_haki_ground_aura(a, CYAN, WHITE, radius=2.75)
        return a

    elif name == 'Ace':
        a = make_base_body(name, skin=TAN_SKIN, top=TAN_SKIN, bottom=CHARCOAL, shoe=BLACK, bare_chest=True)
        add_detailed_face(a, skin=TAN_SKIN, expr='grin', eye_color=BLACK)
        # Freckles on cheeks
        for side in (-1, 1):
            for fx, fy in [(-0.08, 0), (0, 0.05), (0.08, -0.02)]:
                a.ball('Freckle', ((side * 0.46) + fx, 1.82 + fy, -0.78), (0.045, 0.045, 0.045), (135, 75, 52))
        add_sculpted_hair(a, BLACK, 'spiky')

        # Red Bead Necklace around neck
        for i in range(14):
            ang = i * (2 * math.pi / 14)
            a.ball(f'RedNeckBead_{i+1}', (math.cos(ang) * 0.58, 1.14, math.sin(ang) * 0.52), (0.18, 0.18, 0.18), RED, material='SmoothPlastic')

        # Orange Cowboy Hat with Smiley/Sad blue badges
        a.disc('AceHatBrim', (0, 2.86, 0.04), 2.75, 0.14, ORANGE, rot=(6, 0, 90), material='Fabric')
        a.ball('AceHatCrown', (0, 3.10, 0.06), (1.72, 1.05, 1.72), ORANGE, material='Fabric')
        a.disc('AceHatBeadString', (0, 2.96, 0.05), 1.78, 0.16, RED, rot=(6, 0, 90))
        for side in (-1, 1):
            a.ball('HatSmileyBadge', (side * 0.28, 3.04, -0.78), (0.26, 0.26, 0.10), (75, 175, 245))

        # Left Elbow Guard + Log Pose + Orange Belt + Hip Dagger
        a.cyl('LeftElbowGuard', (1.43, 0.02, 0), 0.78, 0.38, ORANGE, rot=(0, 0, 90))
        a.cyl('LeftLogPose', (1.43, -0.58, -0.05), 0.74, 0.22, RED, rot=(0, 0, 90))
        a.box('AceBelt', (0, -0.92, 0), (2.18, 0.26, 1.14), ORANGE)
        a.box('BeltBuckleA', (0, -0.92, -0.58), (0.38, 0.32, 0.10), STEEL, material='Metal')
        a.rod('HipDagger', (1.15, -0.85, -0.25), (1.28, -1.55, 0.25), 0.18, GREEN)

        # Swirling Mera Mera Flame Entei Sun Orb over Right Hand (-X side)!
        sun_center = (-1.65, 1.45, -0.85)
        a.ball('EnteiSunCore', sun_center, (1.45, 1.45, 1.45), (255, 235, 95), material='Neon')
        a.ball('EnteiSunOuter', sun_center, (1.95, 1.95, 1.95), ORANGE, material='Neon', opacity=0.62)
        for i in range(8):
            ang = i * (2 * math.pi / 8)
            fx = math.cos(ang) * 1.35
            fz = math.sin(ang) * 1.35
            a.wedge(f'SwirlingFlame_{i+1}', (fx, -0.8 + i * 0.28, fz), (0.36, 0.68, 0.36), ORANGE if i % 2 == 0 else GOLD, rot=(20, math.degrees(ang), 15), material='Neon', opacity=0.8)
        add_haki_ground_aura(a, ORANGE, GOLD, radius=2.45)
        return a

    elif name == 'Law':
        a = make_base_body(name, skin=LIGHT_SKIN, top=(32, 36, 48), bottom=(42, 62, 98), shoe=BLACK)
        add_detailed_face(a, skin=LIGHT_SKIN, expr='smirk', eye_color=GOLD, brow_color=BLACK)
        # Law's Goatee & Sideburns
        a.box('LawGoatee', (0, 1.44, -0.78), (0.22, 0.18, 0.10), BLACK)
        for side in (-1, 1):
            a.box('LawSideburn', (side * 0.72, 1.92, -0.35), (0.12, 0.55, 0.24), BLACK)

        # Northern-Style Spotted White Fur Hat
        a.cyl('LawHatBase', (0, 2.75, 0), 1.82, 0.52, WHITE, rot=(0, 0, 90), material='Fabric')
        a.ball('LawHatDome', (0, 3.02, 0), (1.78, 0.98, 1.78), WHITE, material='Fabric')
        a.cyl('LawHatBrimFur', (0, 2.54, -0.06), 1.88, 0.24, IVORY, rot=(4, 0, 90), material='Fabric')
        for sx, sy, sz in [(-0.55, 2.88, -0.76), (0, 2.96, -0.84), (0.55, 2.88, -0.76), (-0.75, 2.85, -0.35), (0.75, 2.85, -0.35)]:
            a.ball('HatLeopardSpot', (sx, sy, sz), (0.22, 0.18, 0.12), BLACK)

        # Yellow & Black Hoodie + Feather Shoulder Mantle
        a.box('YellowHoodieChest', (0, 0.22, -0.50), (1.32, 1.65, 0.12), GOLD)
        a.ball('HeartPiratesCrest', (0, 0.38, -0.56), (0.64, 0.64, 0.08), BLACK)
        for side in (-1, 1):
            a.ball('FeatherCollar', (side * 0.95, 1.18, 0.15), (0.85, 0.48, 0.95), (28, 30, 42), material='Fabric')

        # Cursed Nodachi Kikoku resting over Right Shoulder (-X side)
        add_katana(a, 'Kikoku', (-1.45, -0.65, -0.20), (-0.85, 3.35, 1.25), hilt_color=RED, guard_color=WHITE, blade_color=STEEL, haki_flame_color=CYAN)
        # Floating K-ROOM Operating Sphere on Left Hand (+X side)!
        room_pos = (1.68, 0.15, -0.85)
        a.ball('OpeOpeRoomSphere', room_pos, (1.65, 1.65, 1.65), CYAN, material='ForceField', opacity=0.58)
        a.disc('RoomEquatorRing', room_pos, 1.85, 0.08, WHITE, rot=(25, 0, 90), material='Neon')
        add_haki_ground_aura(a, CYAN, PURPLE, radius=2.35)
        return a

    elif name == 'Kizaru':
        a = make_base_body(name, skin=TAN_SKIN, top=GOLD, bottom=GOLD, shoe=WHITE)
        add_detailed_face(a, skin=TAN_SKIN, expr='stern', eye_color=BLACK)
        add_sculpted_hair(a, BLACK, 'spiky')
        # Tinted Gold Aviator Sunglasses
        for side in (-1, 1):
            a.box('AviatorLens', (side * 0.34, 2.05, -0.82), (0.42, 0.28, 0.08), (245, 165, 35), material='Glass', opacity=0.65)
        a.box('AviatorBridge', (0, 2.12, -0.83), (0.85, 0.04, 0.06), GOLD, material='Metal')

        # Yellow Pinstriped Suit + Dark Green Shirt
        a.box('DarkGreenShirt', (0, 0.42, -0.50), (0.58, 1.35, 0.10), (24, 72, 45))
        for i in range(-3, 4):
            if i != 0:
                a.box(f'SuitStripe_{i}', (i * 0.26, 0.10, -0.53), (0.04, 1.95, 0.06), (175, 128, 18))

        # Draped White Marine Admiral Justice Coat + Gold Tassel Epaulets
        a.box('AdmiralJusticeCoat', (0, -0.12, 0.68), (3.15, 3.35, 0.32), WHITE, material='Fabric')
        a.box('AdmiralCollar', (0, 1.48, 0.45), (2.35, 0.55, 0.28), WHITE, material='Fabric')
        for side in (-1, 1):
            a.box('AdmiralEpaulet', (side * 1.32, 1.10, 0.12), (0.65, 0.24, 1.08), GOLD, material='Metal')

        # Ama no Murakumo Light Sword + 8 Sacred Jewel Orbs floating in an arc!
        a.taper_rod('AmaNoMurakumoLightSword', (-1.45, -1.05, -0.30), (-1.65, 2.85, -1.25), 0.28, 0.08, (255, 245, 95), segments=4, material='Neon')
        a.box('LightCrossHilt', (-1.48, -0.45, -0.45), (0.82, 0.18, 0.28), (255, 250, 160), material='Neon')
        for i in range(7):
            ang = math.radians(20 + i * 23)
            ox = math.cos(ang) * 2.15
            oy = 0.85 + math.sin(ang) * 2.15
            a.ball(f'YasakaniLightJewel_{i+1}', (ox, oy, 0.45), (0.34, 0.34, 0.34), (255, 245, 100), material='Neon')
        add_haki_ground_aura(a, (255, 240, 80), WHITE, radius=2.45)
        return a

    elif name == 'Nami':
        a = make_base_body(name, skin=LIGHT_SKIN, top=(38, 168, 195), bottom=BLUE, shoe=(195, 115, 45), woman=True)
        add_detailed_face(a, skin=LIGHT_SKIN, expr='grin', eye_color=(165, 92, 38), brow_color=ORANGE)
        add_sculpted_hair(a, ORANGE, 'long_wave')
        # Tangerine & Pinwheel Tattoo on Left Shoulder (+X side)
        a.disc('TangerineTattoo', (1.32, 0.65, -0.05), 0.38, 0.06, (45, 85, 185), rot=(0, 90, 0))
        # Gold Log Pose & Bracelets on Left Wrist + Gold Berry Belt
        a.cyl('GoldBracelet', (1.32, -0.58, -0.06), 0.72, 0.16, GOLD, rot=(0, 0, 90), material='Metal')
        a.box('GoldCoinBelt', (0, -0.88, 0), (1.92, 0.20, 1.06), GOLD, material='Metal')

        # Sorcery Clima-Tact in Right Hand (-X side)
        a.rod('SorceryClimaTact', (-1.38, -1.85, -0.38), (-1.52, 2.25, -0.55), 0.18, ORANGE)
        for c_y in (-0.8, 0.2, 1.2):
            a.ball('ClimaTactRing', (-1.45, c_y, -0.46), (0.30, 0.22, 0.30), CYAN, material='Neon')
        a.ball('WeatherEggTip', (-1.52, 2.35, -0.56), (0.52, 0.52, 0.52), CYAN, material='Neon')

        # Zeus Thundercloud Companion floating on Left Side (+X) with lightning bolt!
        zx, zy, zz = 1.95, 1.65, -0.35
        a.ball('ZeusMainBody', (zx, zy, zz), (1.35, 0.92, 1.05), WHITE)
        for ox, oy in [(-0.52, -0.05), (0.52, -0.05), (0, 0.32), (-0.35, 0.22), (0.35, 0.22)]:
            a.ball('ZeusCloudPuff', (zx + ox, zy + oy, zz), (0.72, 0.68, 0.78), WHITE)
        a.disc('ZeusCap', (zx, zy + 0.52, zz - 0.08), 0.85, 0.18, PINK, rot=(10, 0, 90))
        for side in (-1, 1):
            a.ball('ZeusEye', (zx + side * 0.22, zy + 0.08, zz - 0.50), (0.14, 0.18, 0.08), GOLD, material='Neon')
        a.rod('ZeusThunderbolt', (zx, zy - 0.35, zz), (zx + 0.15, -2.25, zz - 0.15), 0.22, GOLD, material='Neon')
        add_haki_ground_aura(a, CYAN, GOLD, radius=2.25)
        return a

    elif name == 'Usopp':
        a = make_base_body(name, skin=DARK_SKIN, top=DARK_SKIN, bottom=(178, 132, 52), shoe=(95, 62, 35), bare_chest=True)
        add_detailed_face(a, skin=DARK_SKIN, expr='grin', eye_color=BLACK)
        # Signature Long Nose!
        a.cyl('UsoppLongNose', (0, 1.88, -1.08), 0.22, 0.78, DARK_SKIN, rot=(0, 90, 0))
        a.ball('UsoppNoseTip', (0, 1.88, -1.46), (0.23, 0.23, 0.23), DARK_SKIN)
        add_sculpted_hair(a, BLACK, 'afro')

        # White Plumed Sniper Hat + Forehead Goggles + Yellow Headphones
        a.disc('UsoppHatBrim', (0, 2.86, 0), 2.55, 0.14, IVORY, rot=(0, 0, 90), material='Fabric')
        a.ball('UsoppHatDome', (0, 3.12, 0), (1.68, 0.95, 1.68), IVORY, material='Fabric')
        for side in (-1, 1):
            a.cyl('SniperGoggleLens', (side * 0.36, 2.48, -0.78), 0.38, 0.18, CYAN, rot=(0, 90, 0), material='Glass')
            a.cyl('YellowHeadphone', (side * 0.88, 1.92, 0), 0.48, 0.22, GOLD, rot=(0, 0, 90))

        # Green Satchel Strap & Bag
        a.rod('SatchelStrap', (-0.85, 1.05, -0.52), (0.95, -0.85, -0.52), 0.22, GREEN)
        a.box('PopGreenBag', (1.12, -0.95, -0.15), (0.48, 0.72, 0.78), GREEN, material='Fabric')

        # Giant 5-Pronged Black Slingshot: Kuro Kabuto!
        a.rod('KabutoMainStaff', (-1.45, -2.20, -0.45), (-1.52, 0.75, -0.55), 0.24, BLACK)
        fork_center = (-1.52, 0.75, -0.55)
        for f_idx in range(5):
            ang = math.radians(-50 + f_idx * 25)
            fx = fork_center[0] + math.sin(ang) * 0.95
            fy = fork_center[1] + math.cos(ang) * 0.95
            a.rod(f'KabutoProng_{f_idx+1}', fork_center, (fx, fy, -0.55), 0.16, (45, 22, 28))
        a.ball('PopGreenFirebird', (-1.52, 1.35, -0.55), (0.52, 0.52, 0.52), EMERALD, material='Neon')
        add_haki_ground_aura(a, EMERALD, GOLD, radius=2.25)
        return a

    elif name == 'Chopper':
        # Cute Compact Hybrid Proportions (scale=0.78) with Giant Antlers & Doctor Hat!
        scale = 0.78
        a = make_base_body(name, skin=(168, 112, 72), top=(228, 72, 108), bottom=(128, 42, 52), shoe=(65, 42, 32), scale=scale)
        # Oversized Cute Reindeer Head & Blue Nose
        a.ball('ChopperBigHead', (0, 2.05 * scale, 0), (2.15 * scale, 1.95 * scale, 2.05 * scale), (178, 120, 78))
        a.ball('ChopperMuzzle', (0, 1.78 * scale, -0.95 * scale), (0.88 * scale, 0.62 * scale, 0.65 * scale), (222, 168, 125))
        a.ball('ChopperBlueNose', (0, 1.92 * scale, -1.24 * scale), (0.38 * scale, 0.32 * scale, 0.34 * scale), (35, 135, 245))
        for side in (-1, 1):
            a.ball('CuteEye', (side * 0.45 * scale, 2.12 * scale, -0.92 * scale), (0.36 * scale, 0.38 * scale, 0.16 * scale), BLACK)
            a.ball('CuteEyeShine', (side * 0.42 * scale, 2.18 * scale, -0.98 * scale), (0.12 * scale, 0.12 * scale, 0.08 * scale), WHITE, material='Neon')

        # Iconic Pink Top-Hat inside Blue Helmet + White 'X' Cross
        a.disc('ChopperHatBrim', (0, 2.65 * scale, 0), 2.85 * scale, 0.18 * scale, PINK, rot=(0, 0, 90), material='Fabric')
        a.cyl('ChopperPinkCrown', (0, 3.25 * scale, 0), 2.05 * scale, 1.25 * scale, PINK, rot=(0, 0, 90), material='Fabric')
        a.ball('ChopperBlueHelmet', (0, 3.35 * scale, 0.05 * scale), (2.22 * scale, 1.15 * scale, 2.22 * scale), (85, 195, 242), material='Fabric')
        a.box('HatWhiteCrossA', (0, 3.25 * scale, -1.08 * scale), (0.65 * scale, 0.18 * scale, 0.10 * scale), WHITE, rot=(0, 0, 45))
        a.box('HatWhiteCrossB', (0, 3.25 * scale, -1.08 * scale), (0.65 * scale, 0.18 * scale, 0.10 * scale), WHITE, rot=(0, 0, -45))

        # Multi-Branched Reindeer Antlers
        for side in (-1, 1):
            b0 = (side * 0.95 * scale, 2.85 * scale, 0)
            b1 = (side * 1.85 * scale, 3.65 * scale, 0)
            a.rod(f'AntlerMain_{side}', b0, b1, 0.24 * scale, (135, 88, 48))
            for prong in range(3):
                p_start = (side * (1.15 + prong * 0.25) * scale, (3.05 + prong * 0.22) * scale, 0)
                p_end = (side * (1.25 + prong * 0.30) * scale, (3.65 + prong * 0.28) * scale, -0.15 * scale)
                a.rod(f'AntlerProng_{side}_{prong}', p_start, p_end, 0.16 * scale, (135, 88, 48))

        # Blue Medical Backpack + Floating Sakura Petals
        a.box('MedicalBackpack', (0, 0.18 * scale, 0.72 * scale), (1.45 * scale, 1.45 * scale, 0.65 * scale), (45, 95, 185))
        for i in range(6):
            ang = i * (2 * math.pi / 6)
            a.ball(f'SakuraPetal_{i+1}', (math.cos(ang) * 1.65, -0.5 + (i % 3) * 0.85, math.sin(ang) * 1.65), (0.28, 0.12, 0.22), PINK, material='Neon')
        add_haki_ground_aura(a, PINK, CYAN, radius=2.05, y=-2.50 * scale)
        return a

    elif name == 'Robin':
        a = make_base_body(name, skin=LIGHT_SKIN, top=(52, 38, 108), bottom=(195, 62, 118), shoe=BLACK, woman=True)
        add_detailed_face(a, skin=LIGHT_SKIN, expr='smirk', eye_color=BLUE)
        add_sculpted_hair(a, BLACK, 'long_wave')
        # Orange Sunglasses on Forehead
        for side in (-1, 1):
            a.box('ForeheadSunglass', (side * 0.34, 2.45, -0.78), (0.38, 0.20, 0.10), ORANGE, material='Glass')
        # Long Wrap Sarong Skirt + Poneglyph Book
        a.cyl('FloralSarongSkirt', (0, -1.55, 0), 1.92, 1.45, (215, 75, 132), rot=(0, 0, 90), material='Fabric')
        a.box('PoneglyphBook', (1.35, -0.45, -0.48), (0.55, 0.72, 0.18), GOLD)

        # Mil Fleur: 8 Blossoming Lotus Arms fanning behind her back like a Goddess Halo!
        for side in (-1, 1):
            for idx in range(4):
                ang_deg = 22 + idx * 24
                ang_rad = math.radians(ang_deg)
                p1 = (side * 0.65, 0.45 + idx * 0.18, 0.55)
                p2 = (side * (0.65 + math.sin(ang_rad) * 1.85), 0.45 + idx * 0.18 + math.cos(ang_rad) * 1.85, 0.62)
                a.taper_rod(f'HanaLotusArm_{side}_{idx+1}', p1, p2, 0.38, 0.28, LIGHT_SKIN, segments=2)
                a.ball(f'HanaLotusHand_{side}_{idx+1}', p2, (0.36, 0.36, 0.28), (235, 125, 215), material='Neon', opacity=0.85)
        add_haki_ground_aura(a, PURPLE, PINK, radius=2.45)
        return a

    return make_base_body(name)


def make_enemy(name: str) -> Asset:
    if name == 'PirateGrunt':
        a = make_base_body(name, skin=(118, 162, 122), top=(112, 78, 52), bottom=(58, 64, 72), shoe=(42, 36, 32))
        add_detailed_face(a, skin=(118, 162, 122), expr='fierce', eye_color=(255, 215, 60))
        # Thriller Bark Stitches across face & torso
        a.box('FaceStitchLine', (0, 1.82, -0.80), (0.85, 0.04, 0.05), BLACK, rot=(0, 0, -12))
        a.cyl('RedPirateBandana', (0, 2.42, 0), 1.66, 0.38, CRIMSON, rot=(0, 0, 90), material='Fabric')
        a.box('StripedPirateShirt', (0, 0.12, -0.50), (1.92, 1.82, 0.12), IVORY)
        for i in range(4):
            a.box(f'ShirtStripe_{i+1}', (0, -0.45 + i * 0.38, -0.54), (1.94, 0.14, 0.08), NAVY)
        # Pirate Cutlass in Right Hand + Skull Buckler Shield in Left Hand
        add_katana(a, 'PirateCutlass', (-1.45, -0.92, -0.25), (-1.75, 1.45, -1.55), hilt_color=BRASS, guard_color=GOLD, blade_color=STEEL)
        a.disc('SkullBucklerShield', (1.58, -0.35, -0.35), 1.45, 0.18, WOOD, rot=(0, 90, 0), material='Wood')
        a.disc('ShieldIronRim', (1.62, -0.35, -0.35), 1.52, 0.12, DARK_STEEL, rot=(0, 90, 0), material='Metal')
        return a

    elif name == 'SoruAssassin':
        a = make_base_body(name, skin=LIGHT_SKIN, top=WHITE, bottom=WHITE, shoe=BLACK)
        # CP0 Masked Agent with Gold Horns/Patterns & Glowing Red Eyes
        a.ball('CP0MaskFace', (0, 1.92, -0.45), (1.42, 1.52, 0.85), IVORY)
        for side in (-1, 1):
            a.ball('AssassinRedEye', (side * 0.34, 2.05, -0.86), (0.24, 0.16, 0.10), RED, material='Neon')
            a.wedge('MaskGoldCheek', (side * 0.38, 1.72, -0.84), (0.14, 0.42, 0.08), GOLD, rot=(0, 0, side * 15))
        a.disc('CP0TopHatBrim', (0, 2.68, 0), 2.15, 0.12, WHITE, rot=(0, 0, 90))
        a.cyl('CP0TopHatCrown', (0, 3.18, 0), 1.48, 0.95, WHITE, rot=(0, 0, 90))
        a.box('FlowingCP0Cloak', (0, -0.10, 0.65), (2.75, 3.15, 0.25), WHITE, material='Fabric')
        a.box('CrimsonScarf', (0, 1.15, -0.10), (2.25, 0.36, 1.28), CRIMSON, material='Fabric')
        # Dual Shigan Tempest Claws
        for side in (-1, 1):
            for c_i in (-1, 0, 1):
                p1 = (side * 1.42 + c_i * 0.12, -0.95, -0.20)
                p2 = (side * 1.52 + c_i * 0.16, -1.65, -1.25)
                a.taper_rod(f'ShiganClaw_{side}_{c_i}', p1, p2, 0.10, 0.03, CYAN, segments=2, material='Neon')
        add_haki_ground_aura(a, CYAN, WHITE, radius=2.15, lightning=False)
        return a

    elif name == 'HakiBrute':
        scale = 1.28
        a = make_base_body(name, skin=(145, 148, 162), top=(28, 30, 42), bottom=(24, 26, 36), shoe=BLACK, scale=scale)
        add_detailed_face(a, skin=(145, 148, 162), expr='stern', eye_color=RED, scale=scale)
        # Pacifista Cyborg Visor & Chest Laser Core
        a.box('CyborgLaserVisor', (0, 2.06 * scale, -0.78 * scale), (1.36 * scale, 0.24 * scale, 0.14 * scale), RED, material='Neon')
        a.box('Heavy ChestArmor', (0, 0.18 * scale, -0.45 * scale), (2.35 * scale, 1.95 * scale, 0.42 * scale), (38, 42, 58), material='Metal')
        a.cyl('PacifistaLaserCore', (0, 0.35 * scale, -0.62 * scale), 0.78 * scale, 0.22 * scale, GOLD, rot=(0, 90, 0), material='Neon')
        # Spiked Pauldrons & Full-Arm Busoshoku Haki Fists
        for side in (-1, 1):
            a.ball('SpikedPauldron', (side * 1.52 * scale, 0.98 * scale, 0), (1.15 * scale, 0.92 * scale, 1.22 * scale), (45, 48, 65), material='Metal')
            a.wedge('ShoulderSpike', (side * 1.85 * scale, 1.45 * scale, 0), (0.28 * scale, 0.62 * scale, 0.28 * scale), STEEL, rot=(0, 0, -side * 35), material='Metal')
            a.ball('GiantHakiFist', (side * 1.48 * scale, -0.95 * scale, -0.18 * scale), (1.12 * scale, 0.95 * scale, 1.12 * scale), (18, 15, 25), material='Metal')
            a.ball('HakiFistOutline', (side * 1.48 * scale, -0.95 * scale, -0.18 * scale), (1.22 * scale, 1.05 * scale, 1.22 * scale), PURPLE, material='Neon', opacity=0.42)
        add_haki_ground_aura(a, PURPLE, BLACK, radius=2.55, y=-2.50 * scale)
        return a

    elif name == 'YonkoBoss':
        # YONKO KAIDO [DRAGON EMPEROR] — Colossal 1.52x Scale Boss!
        scale = 1.52
        a = make_base_body(name, skin=(195, 132, 118), top=(45, 78, 148), bottom=(38, 42, 78), shoe=BLACK, scale=scale, bare_chest=True)
        add_detailed_face(a, skin=(195, 132, 118), expr='fierce', eye_color=GOLD, brow_color=BLACK, scale=scale)
        add_sculpted_hair(a, (22, 24, 35), 'long_wave', scale=scale)

        # Kaido's Giant Curved Dragon Horns + Long Fu Manchu Dragon Whiskers
        for side in (-1, 1):
            h0 = (side * 0.58 * scale, 2.42 * scale, -0.12 * scale)
            h1 = (side * 1.38 * scale, 3.15 * scale, -0.28 * scale)
            h2 = (side * 1.72 * scale, 4.12 * scale, -0.15 * scale)
            a.taper_rod(f'KaidoHornBase_{side}', h0, h1, 0.38 * scale, 0.26 * scale, IVORY, segments=2)
            a.taper_rod(f'KaidoHornTip_{side}', h1, h2, 0.26 * scale, 0.08 * scale, GOLD, segments=2)
            w0 = (side * 0.38 * scale, 1.68 * scale, -0.82 * scale)
            w1 = (side * 0.95 * scale, 0.65 * scale, -0.95 * scale)
            a.taper_rod(f'DragonWhisker_{side}', w0, w1, 0.12 * scale, 0.04 * scale, BLACK, segments=2)

        # Oden's Togen Totsuka X-Scar on Right Torso + Red Dragon Scales Tattoo on Left Arm
        a.box('OdenScarA', (-0.42 * scale, -0.18 * scale, -0.56 * scale), (0.68 * scale, 0.14 * scale, 0.06 * scale), (165, 48, 58), rot=(0, 0, 38))
        a.box('OdenScarB', (-0.42 * scale, -0.18 * scale, -0.56 * scale), (0.68 * scale, 0.14 * scale, 0.06 * scale), (165, 48, 58), rot=(0, 0, -38))
        a.cyl('DragonScaleTattooArm', (1.43 * scale, 0.42 * scale, 0), 0.80 * scale, 0.88 * scale, CRIMSON, rot=(0, 0, 90))

        # Feathered Purple Dragon-Emperor Mantle + Gold Chain & Shimenawa Rope Belt
        a.box('KaidoFeatheredMantle', (0, 0.05 * scale, 0.75 * scale), (3.45 * scale, 3.55 * scale, 0.45 * scale), (68, 42, 108), material='Fabric')
        for f_i in range(9):
            fx = (-1.4 + f_i * 0.35) * scale
            a.ball(f'MantleFeatherPuff_{f_i+1}', (fx, 1.52 * scale, 0.55 * scale), (0.68 * scale, 0.68 * scale, 0.68 * scale), (85, 52, 132), material='Fabric')
        a.cyl('ShimenawaRopeBelt', (0, -0.88 * scale, 0), 2.32 * scale, 0.38 * scale, IVORY, rot=(0, 0, 90), material='Fabric')

        # Colossal Spiked Kanabo: HASSAIKAI coated in Conqueror's Haki Lightning!
        k_bot = (-1.65 * scale, -2.10 * scale, -0.35 * scale)
        k_top = (-2.35 * scale, 2.85 * scale, -1.45 * scale)
        a.taper_rod('HassaikaiClub', k_bot, k_top, 0.28 * scale, 0.78 * scale, (32, 26, 42), segments=4, material='Metal')
        for s_i in range(8):
            t = 0.35 + (s_i / 8.0) * 0.60
            cx = k_bot[0] + (k_top[0] - k_bot[0]) * t
            cy = k_bot[1] + (k_top[1] - k_bot[1]) * t
            cz = k_bot[2] + (k_top[2] - k_bot[2]) * t
            for side in (-1, 1):
                a.cone if False else a.wedge(f'KanaboSpike_{s_i}_{side}', (cx + side * 0.38 * scale, cy, cz - 0.25 * scale), (0.24 * scale, 0.38 * scale, 0.24 * scale), GOLD, rot=(0, 0, -side * 75), material='Metal')
        add_haki_ground_aura(a, RED, PURPLE, radius=3.15, y=-2.50 * scale)
        return a

    return make_base_body(name)


def make_scene(name: str) -> Asset:
    a = Asset(name)
    a.box('HumanoidRootPart', (0, 0, 0), (0.4, 0.4, 0.4), WHITE, opacity=0)

    if name == 'AnimeBaseCrystal':
        # Grand Line Road Poneglyph Shrine & Thousand Sunny Golden Sun Figurehead
        a.disc('ShrineBaseTier1', (0, 0.30, 0), 9.2, 0.60, (38, 42, 56), material='Granite')
        a.disc('ShrineBaseTier2', (0, 0.78, 0), 7.4, 0.45, (52, 58, 76), material='Marble')
        a.disc('ShrineGoldRing', (0, 1.05, 0), 7.6, 0.14, GOLD, material='Metal')

        # 4 Corner Haki Pillars with Flame Braziers
        for sx in (-2.6, 2.6):
            for sz in (-2.6, 2.6):
                a.cyl('SanctuaryPillar', (sx, 2.65, sz), 0.78, 3.2, (228, 222, 205), rot=(0, 0, 90), material='Marble')
                a.cyl('PillarGoldCap', (sx, 4.35, sz), 0.96, 0.28, GOLD, rot=(0, 0, 90), material='Metal')
                a.ball('PillarSunFlame', (sx, 4.78, sz), (0.72, 0.88, 0.72), CYAN, material='Neon', opacity=0.85)

        # Crimson Road Poneglyph Monolith in Center with Glowing Ancient Runes
        a.box('RoadPoneglyphCube', (0, 3.25, 0), (3.8, 4.2, 3.8), (158, 22, 38), material='Slate')
        for face_z in (-1.92, 1.92):
            for row in range(4):
                a.box(f'PoneglyphRuneZ_{face_z}_{row}', (0, 2.0 + row * 0.75, face_z), (2.6, 0.12, 0.06), GOLD, material='Neon')

        # Floating Thousand Sunny Lion Sun Core & Celestial Halo Rings above Poneglyph
        a.ball('SunnyLionCore', (0, 7.25, 0), (2.45, 2.45, 2.45), GOLD, material='Neon')
        for petal in range(12):
            ang = petal * (2 * math.pi / 12)
            px = math.cos(ang) * 1.65
            py = 7.25 + math.sin(ang) * 1.65
            a.wedge(f'SunnyManePetal_{petal+1}', (px, py, 0), (0.42, 0.78, 0.36), ORANGE if petal % 2 == 0 else RED, rot=(0, 0, math.degrees(ang) - 90), material='Neon')
        a.disc('CelestialHalo1', (0, 7.25, 0), 5.6, 0.14, CYAN, rot=(25, 0, 90), material='Neon', opacity=0.65)
        a.disc('CelestialHalo2', (0, 7.25, 0), 5.6, 0.14, GOLD, rot=(-25, 0, 90), material='Neon', opacity=0.65)
        return a

    elif name == 'EnemySpawnGate':
        # Onigashima / Thriller Bark Demon Skull Torii Portal Gate
        a.box('GateFoundation', (0, 0.25, 0), (12.5, 0.50, 3.6), (35, 34, 48), material='Basalt')
        for side in (-1, 1):
            px = side * 4.4
            a.cyl('ToriiPillar', (px, 4.6, 0), 1.65, 8.6, (145, 22, 38), rot=(0, 0, 90), material='SmoothPlastic')
            a.cyl('PillarBaseRing', (px, 0.85, 0), 2.05, 0.75, (28, 28, 38), rot=(0, 0, 90), material='Metal')
            a.cyl('PillarGoldBand', (px, 4.5, 0), 1.78, 0.35, GOLD, rot=(0, 0, 90), material='Metal')
            # Giant Onigashima Curved Demon Horns on top of Gate!
            h0 = (side * 2.2, 8.8, -0.3)
            h1 = (side * 5.2, 10.6, -0.5)
            h2 = (side * 6.8, 12.8, -0.2)
            a.taper_rod(f'OnigashimaGateHornA_{side}', h0, h1, 0.95, 0.58, (185, 28, 45), segments=2)
            a.taper_rod(f'OnigashimaGateHornB_{side}', h1, h2, 0.58, 0.16, GOLD, segments=2)

        # Upper Torii Crossbeams & Demon Skull Emblem
        a.box('ToriiLowerBeam', (0, 7.4, 0), (10.8, 0.85, 1.85), (28, 26, 38))
        a.box('ToriiUpperKasagi', (0, 8.8, 0), (12.6, 1.15, 2.35), (155, 24, 42))
        a.ball('OnigashimaSkullDome', (0, 8.6, -1.15), (2.6, 2.4, 1.6), IVORY)
        for side in (-1, 1):
            a.ball('SkullEyeGlow', (side * 0.52, 8.75, -1.85), (0.52, 0.42, 0.22), PURPLE, material='Neon')

        # Swirling Dark Abyss Portal Vortex in center of Gate
        a.disc('AbyssPortalOuter', (0, 4.2, 0), 6.8, 0.22, PURPLE, rot=(0, 90, 0), material='Neon', opacity=0.45)
        a.disc('AbyssPortalInner', (0, 4.2, 0), 4.6, 0.28, (255, 35, 85), rot=(0, 90, 0), material='ForceField', opacity=0.68)
        return a

    elif name == 'PlacementPadTemplate':
        # Grand Line Log Pose Compass & Haki Summoning Pedestal
        a.disc('PedestalBaseStone', (0, -0.12, 0), 7.6, 0.38, (36, 42, 58), material='Marble')
        a.disc('GoldCompassRim', (0, 0.12, 0), 7.2, 0.16, GOLD, material='Metal')
        a.disc('InnerSanctumPlate', (0, 0.22, 0), 6.2, 0.14, (24, 34, 52), material='Granite')
        a.disc('HakiSummonCore', (0, 0.32, 0), 4.4, 0.08, CYAN, material='Neon', opacity=0.58)
        for i in range(8):
            ang = i * (2 * math.pi / 8)
            rx = math.cos(ang) * 2.95
            rz = math.sin(ang) * 2.95
            a.wedge(f'CompassPoint_{i+1}', (rx, 0.36, rz), (0.38, 0.18, 0.68), GOLD if i % 2 == 0 else CYAN, rot=(0, math.degrees(-ang), 0), material='Neon' if i % 2 else 'Metal')
        return a

    return a


def sub(parent, tag, attrib, text=None):
    c = ET.SubElement(parent, tag, attrib)
    if text is not None:
        c.text = str(text)
    return c


def fmt(x: float) -> str:
    v = float(x)
    if abs(v) < 1e-7:
        return '0'
    return ('%.7f' % v).rstrip('0').rstrip('.')


def vector(parent, name: str, val: tuple[float, float, float]):
    q = sub(parent, 'Vector3', {'name': name})
    for tag, num in zip('XYZ', val):
        sub(q, tag, {}, fmt(num))


def cf(parent, name: str, xyz: tuple[float, float, float], rot: tuple[float, float, float], mat3: list[list[float]] | None = None):
    q = sub(parent, 'CoordinateFrame', {'name': name})
    for tag, num in zip('XYZ', xyz):
        sub(q, tag, {}, fmt(num))
    R = mat3 if mat3 is not None else euler_to_matrix(rot)
    for i in range(3):
        for j in range(3):
            sub(q, f'R{i}{j}', {}, fmt(R[i][j]))


def xml_asset(a: Asset, path: pathlib.Path) -> int:
    roblox = ET.Element('roblox', {'version': '4'})
    sub(roblox, 'Meta', {'name': 'ExplicitAutoJoints'}, 'true')
    sub(roblox, 'External', {}, 'null')
    sub(roblox, 'External', {}, 'nil')
    model = sub(roblox, 'Item', {'class': 'Model', 'referent': 'RBXMODEL'})
    props = sub(model, 'Properties', {})
    sub(props, 'string', {'name': 'Name'}, a.name)
    sub(props, 'Ref', {'name': 'PrimaryPart'}, 'RBX0')
    assert a.parts[0]['name'] == 'HumanoidRootPart'

    MAT = {
        'SmoothPlastic': 272,
        'Neon': 288,
        'Wood': 512,
        'Marble': 784,
        'Basalt': 788,
        'Slate': 800,
        'Granite': 832,
        'Metal': 1088,
        'Fabric': 1312,
        'Glass': 1568,
        'ForceField': 1584,
    }
    SHAPE = {
        'Ball': 0,
        'Block': 1,
        'Cylinder': 2,
        'Wedge': 3,
        'CornerWedge': 4,
    }

    for i, p in enumerate(a.parts):
        it = sub(model, 'Item', {'class': 'Part', 'referent': f'RBX{i}'})
        pp = sub(it, 'Properties', {})
        sub(pp, 'string', {'name': 'Name'}, p['name'])
        vector(pp, 'Size', p['size'])
        cf(pp, 'CFrame', p['pos'], p['rot'], p.get('mat3'))
        color = sub(pp, 'Color3', {'name': 'Color'})
        for t, v in zip('RGB', p['color']):
            sub(color, t, {}, fmt(v / 255.0))
        sub(pp, 'token', {'name': 'Material'}, MAT.get(p['material'], 272))
        sub(pp, 'token', {'name': 'shape'}, SHAPE.get(p['kind'], 1))
        sub(pp, 'bool', {'name': 'Anchored'}, 'true')
        sub(pp, 'bool', {'name': 'CanCollide'}, 'false')
        sub(pp, 'bool', {'name': 'CanTouch'}, 'false')
        sub(pp, 'bool', {'name': 'CanQuery'}, 'false')
        sub(pp, 'float', {'name': 'Transparency'}, fmt(p['trans']))
        sub(pp, 'bool', {'name': 'CastShadow'}, 'false' if p['material'] in ('Neon', 'ForceField') else 'true')

    path.parent.mkdir(parents=True, exist_ok=True)
    data = ET.tostring(roblox, encoding='utf-8', xml_declaration=False)
    path.write_bytes(data)
    return len(a.parts)


if __name__ == '__main__':
    report = {'HeroModels': {}, 'EnemyModels': {}, 'MapModels': {}}
    for n in CHARACTERS:
        report['HeroModels'][n] = xml_asset(make_character(n), ROOT / 'assets/rojo/HeroModels' / f'{n}.rbxmx')
    for n in ENEMIES:
        report['EnemyModels'][n] = xml_asset(make_enemy(n), ROOT / 'assets/rojo/EnemyModels' / f'{n}.rbxmx')
    for n in SCENERY:
        report['MapModels'][n] = xml_asset(make_scene(n), ROOT / 'assets/rojo/MapModels' / f'{n}.rbxmx')

    total_parts = sum(sum(x.values()) for x in report.values())
    (ROOT / 'asset_manifest.json').write_text(
        json.dumps({
            'generator': 'build_assets.py (V2 High-Detail One Piece Masterpiece)',
            'models': report,
            'total': sum(len(x) for x in report.values()),
            'total_parts': total_parts,
            'note': '12 high-detail One Piece heroes, 4 elite/Yonko enemies, 3 Grand Line map structures',
        }, indent=2),
        encoding='utf-8',
    )
    print('Generated', sum(map(len, report.values())), 'models with', total_parts, 'sculpted parts')
