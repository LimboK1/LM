extends Resource
class_name WASSettings

# ── General ───────────────────────────────────────────────────
var mod_enabled : bool = true
var debug       : bool = false

# ── Bandit — attachment chance % ──────────────────────────────
var bandit_scope    : int = 10
var bandit_silencer : int = 8
var bandit_laser    : int = 8

# ── Guard — attachment chance % ──────────────────────────────
var guard_scope    : int = 30
var guard_silencer : int = 15
var guard_laser    : int = 15

# ── Military / Punisher — attachment chance % ─────────────────
var military_scope    : int = 40
var military_silencer : int = 35
var military_laser    : int = 30

# ── Container Loot — Attachments ───────────────
var container_scope    : int = 15
var container_silencer : int = 6
var container_laser    : int = 7

# ── Container Loot — Magazine ─────────────────────────────────
var container_mag_chance   : int = 50
var container_mag_fill_min : int = 5
var container_mag_fill_max : int = 80

# ── Floor Loot — Attachments ────────────────────
var floor_scope    : int = 8
var floor_silencer : int = 5
var floor_laser    : int = 3

# ── Floor Loot — Magazine ─────────────────────────────────────
var floor_mag_chance   : int = 25
var floor_mag_fill_min : int = 5
var floor_mag_fill_max : int = 60

# ── Auto-Chamber System ───────────────────────────────────────
var chamber_mode     : int = 1   # 0=Disabled, 1=Auto on Equip, 2=Manual (press R)
var unchamber_chance : int = 30  # % chance world weapon spawns unchambered (when mode > 0)