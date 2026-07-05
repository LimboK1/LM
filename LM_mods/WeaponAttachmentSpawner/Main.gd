extends Node

var cfg = preload("res://LM_mods/WeaponAttachmentSpawner/Settings.tres")
var gameData = preload("res://Resources/GameData.tres")
const SESSION_SAVE_PATH = "user://MCM/WeaponAttachmentSpawner/sessions.ini"
var _session_count : int = 0

const SCOPE_KEYS    = ["optic","scope","sight","acog","eotech","kobra","trijicon",
                       "vudu","leopold","micro","leupold","hamr","mro","pro","magnif",
                       "red dot","holographic","reflex","exps","hmr"]
const SILENCER_KEYS = ["suppressor","silencer","muzzle","navy","monster","thor",
                       "socom","hybrid","ptn","pbs","rider"]
const LASER_KEYS    = ["laser","pointer","oz5","an/peq","peq","anpeq"]
const RAIL_NODE_NAMES = ["Mount", "Rail", "RailMount", "PicatinnyRail", "SideMount"]

func _ready() -> void:
    _increment_session()
    if not cfg.mod_enabled:
        push_warning("[WAS] Mod disabled.")
        return
    get_tree().node_added.connect(_on_node_added)
    print("[LM_WAS] v1.0.0 loaded — Session:", _session_count)

# ══════════════════════════════════════════════════════════════
# Node detection
# ══════════════════════════════════════════════════════════════

func _on_node_added(node: Node) -> void:
    if not cfg.mod_enabled: return
    if node is CharacterBody3D and node.get("weapons") != null:
        _wait_and_enhance_ai(node); return
    if node.get("containerName") != null:
        _wait_and_enhance_container(node); return
    if node.get("commonBucket") != null and node.get("containerName") == null:
        _wait_and_enhance_floor_loot(node)
    if node is WeaponRig:
        _check_auto_chamber_on_equip(node)

# ══════════════════════════════════════════════════════════════
# ① AI enemy weapons
# ══════════════════════════════════════════════════════════════

func _wait_and_enhance_ai(ai: Node) -> void:
    await get_tree().physics_frame
    await get_tree().physics_frame
    await get_tree().physics_frame
    if not is_instance_valid(ai): return
    var weapon = ai.get("weapon")
    var wd     = ai.get("weaponData")
    if weapon == null or wd == null: return
    var sd = weapon.get("slotData")
    if sd == null: return
    var faction := _get_ai_faction(ai)
    _log(["AI[", faction, "]", ai.name, "weapon:", wd.get("name") if wd.get("name") else "?"])
    if cfg.debug:
        var att = weapon.get_node_or_null("Attachments")
        if att:
            _log(["  Attachments:", att.get_children().map(func(c): return c.name)])
    _ai_add_attachments(ai, weapon, wd, sd, faction)

func _ai_add_attachments(ai: Node, weapon: Node, wd, sd, faction: String) -> void:
    var compatible = wd.get("compatible")
    if compatible == null or compatible.size() == 0: return
    _dedupe_nested(sd)
    var already : Dictionary = {}
    var nested = sd.get("nested")
    if nested:
        for item in nested:
            var cat := classify(item)
            if cat != "": already[cat] = true
    var pools := {"scope": [], "silencer": [], "laser": []}
    for item in compatible:
        var cat := classify(item)
        if cat in pools: pools[cat].append(item)
    _log(["  Candidates — scope:", pools["scope"].size(),
          " silencer:", pools["silencer"].size(),
          " laser:", pools["laser"].size()])
    for cat in pools:
        if pools[cat].is_empty(): continue
        if already.has(cat):
            _log(["  Skip (already has):", cat])
            continue
        var chance := _faction_chance(faction, cat)
        if not roll(chance):
            _log(["  Skip (chance):", cat, chance, "%"]); continue
        var chosen = pools[cat][randi() % pools[cat].size()]
        _attach_to_ai_weapon(weapon, sd, chosen)
        already[cat] = true
        _log(["  Attached:", chosen.get("name") if chosen.get("name") else cat, "(", chance, "%)"])

    # If AI ended up with a suppressor, swap its weaponData audio so its fire/tail
    # plays the suppressed variant. Uses Resource.duplicate() to avoid mutating
    # the shared WeaponData .tres.
    if _has_suppressor_in_nested(sd):
        _swap_ai_audio_for_suppressed(ai)

func _dedupe_nested(sd) -> void:
    if sd == null: return
    var nested = sd.get("nested")
    if nested == null: return
    var seen_categories : Dictionary = {}
    var to_remove : Array = []
    for i in range(nested.size()):
        var item = nested[i]
        var cat := classify(item)
        if cat == "" or cat == "magazine": continue
        if seen_categories.has(cat):
            to_remove.append(i)
            _log(["  Dedupe: removed duplicate", cat, "at index", i])
        else:
            seen_categories[cat] = true
    for i in range(to_remove.size() - 1, -1, -1):
        nested.remove_at(to_remove[i])

# ══════════════════════════════════════════════════════════════
# Suppressor audio swap (AI only)
# ══════════════════════════════════════════════════════════════

func _has_suppressor_in_nested(sd) -> bool:
    if sd == null: return false
    var nested = sd.get("nested")
    if nested == null: return false
    for item in nested:
        if item == null: continue
        if classify(item) == "silencer": return true
    return false

func _swap_ai_audio_for_suppressed(ai: Node) -> void:
    if ai == null or not is_instance_valid(ai): return
    var wd = ai.get("weaponData")
    if wd == null: return
    var fire_supp = wd.get("fireSuppressed")
    if fire_supp == null:
        _log(["  Suppressor audio swap skipped: weapon has no fireSuppressed"])
        return
    var clone = wd.duplicate()
    clone.fireSemi = fire_supp
    clone.fireAuto = fire_supp
    var tail_supp = wd.get("tailOutdoorSuppressed")
    if tail_supp != null:
        clone.tailOutdoor = tail_supp
    ai.weaponData = clone
    _log(["  Suppressor audio swap applied (cloned WeaponData)"])

# ══════════════════════════════════════════════════════════════
# Auto-Chamber on Equip
# ══════════════════════════════════════════════════════════════

func _check_auto_chamber_on_equip(rig) -> void:
    if cfg.chamber_mode == 0: return
    await get_tree().physics_frame
    await get_tree().physics_frame
    if not is_instance_valid(rig): return
    var sd = rig.get("slotData")
    if sd == null: return
    if sd.chamber: return
    if int(sd.amount) <= 0: return
    var nested = sd.get("nested")
    if nested == null: return
    var has_mag : bool = false
    for item in nested:
        if item == null: continue
        if classify(item) == "magazine":
            has_mag = true
            break
    if not has_mag: return
    var data = rig.get("data")
    if data == null: return
    var action := str(data.get("weaponAction"))
    if action in ["Manual", "Single"]: return

    if cfg.chamber_mode == 1:
        # Auto mode: wait for Idle, then play charge automatically
        var max_iterations : int = 180
        var iteration : int = 0
        while iteration < max_iterations:
            if not is_instance_valid(rig): return
            if str(rig.get("currentState")) == "Idle": break
            await get_tree().physics_frame
            iteration += 1
        if iteration >= max_iterations:
            _log(["  Auto-chamber timeout: rig never reached Idle"])
            return
        if not is_instance_valid(rig): return
        if rig.get("slotData") != sd: return
        if sd.chamber: return
        _play_auto_charge(rig, sd)
        return

    if cfg.chamber_mode == 2:
        # Manual mode: poll for R press while equipped + idle + still unchambered
        _log(["  Manual chamber pending: press R to chamber a round"])
        _wait_for_manual_charge(rig, sd)
        return

func _wait_for_manual_charge(rig, sd) -> void:
    while is_instance_valid(rig):
        if rig.get("slotData") != sd: return
        if sd.chamber: return
        if int(sd.amount) <= 0: return
        if str(rig.get("currentState")) == "Idle":
            if not gameData.isReloading and not gameData.isOccupied and not gameData.isFiring and not gameData.isClearing and not gameData.isInserting:
                if Input.is_action_just_pressed("reload"):
                    # Wait one physics frame to let vanilla Reload() try first.
                    # If a fuller magazine exists in inventory, vanilla will swap
                    # mags (sets isReloading=true), and our charge should defer.
                    await get_tree().physics_frame
                    if not is_instance_valid(rig): return
                    if rig.get("slotData") != sd: return
                    if sd.chamber: return  # vanilla or another mod handled it
                    if gameData.isReloading or gameData.isOccupied or gameData.isClearing:
                        # Vanilla started a reload (probably mag swap). Skip and resume polling.
                        _log(["  Manual chamber: vanilla reload in progress, deferring"])
                        await get_tree().create_timer(0.5, false).timeout
                        continue
                    _log(["  Manual chamber: R pressed -> playing charge"])
                    _play_auto_charge(rig, sd)
                    return
        await get_tree().process_frame

func _play_auto_charge(rig, sd) -> void:
    var anim_length : float = 1.8  # safe fallback (Colt_1911 charge length)
    var ap = rig.get("animations")
    if ap != null and is_instance_valid(ap) and ap is AnimationPlayer:
        for anim_name in ap.get_animation_list():
            if str(anim_name).ends_with("_Charge"):
                var a = ap.get_animation(anim_name)
                if a != null:
                    anim_length = a.length
                break

    if rig.has_method("PlayCharge"):
        rig.PlayCharge()

    var animator = rig.get("animator")
    if animator != null and is_instance_valid(animator):
        animator["parameters/conditions/Charge"] = true
        await get_tree().create_timer(0.1, false).timeout
        if is_instance_valid(rig) and rig.get("animator") != null:
            rig.animator["parameters/conditions/Charge"] = false

    await get_tree().create_timer(maxf(anim_length - 0.1, 0.1), false).timeout
    if not is_instance_valid(rig): return
    if rig.get("slotData") != sd: return  # weapon swapped during animation

    sd.chamber = true
    sd.amount = int(sd.amount) - 1
    if int(sd.amount) < 0: sd.amount = 0

    var ws = rig.get("weaponSlot")
    if ws != null and is_instance_valid(ws) and ws.get_child_count() > 0:
        var weapon_item = ws.get_child(0)
        if weapon_item.has_method("UpdateDetails"): weapon_item.UpdateDetails()
        if weapon_item.has_method("UpdateSprite"):  weapon_item.UpdateSprite()

    if rig.has_method("SlideLock"):
        rig.SlideLock(false)
    _log(["  Auto-chamber complete: chamber=true, magazine_amount=", sd.amount])



# ══════════════════════════════════════════════════════════════
# ② Container Loot (boxes, crates, static containers)
# ══════════════════════════════════════════════════════════════

func _wait_and_enhance_container(container: Node) -> void:
    await get_tree().process_frame
    if not is_instance_valid(container): return
    var loot = container.get("loot")
    if loot == null or loot.size() == 0: return
    for slot_data in loot:
        var item = slot_data.get("itemData")
        if item == null or item.get("type") != "Weapon": continue
        _log(["Container weapon:", item.get("name") if item.get("name") else "?"])
        enhance_container_weapon(slot_data, item)

func enhance_container_weapon(weapon_slot, item_data, weapon_node = null) -> void:
    if not cfg.mod_enabled: return
    var compatible = item_data.get("compatible")
    if compatible == null: compatible = []
    
    # Magazine handling for containers
    if roll(cfg.container_mag_chance):
        var mag_size := int(item_data.get("magazineSize")) \
                        if item_data.get("magazineSize") != null else 0
        if mag_size > 0:
            var fill_min := float(cfg.container_mag_fill_min) / 100.0
            var fill_max := float(cfg.container_mag_fill_max) / 100.0
            weapon_slot.amount = max(1, int(mag_size * randf_range(fill_min, fill_max)))
            var mags : Array = compatible.filter(func(i): return classify(i) == "magazine")
            if not mags.is_empty():
                var n = weapon_slot.get("nested")
                if n != null:             
                    var already_has_mag : bool = false
                    for existing in n:
                        if classify(existing) == "magazine":
                            already_has_mag = true
                            break
                    if not already_has_mag:
                        var cm = mags[randi() % mags.size()]
                        n.append(cm)
                        if weapon_node != null: _show_attachment_nodes(weapon_node, cm)
                        _log(["  Container magazine:", weapon_slot.amount, "/", mag_size])
                    else:
                        _log(["  Container magazine skipped (already has one)"])
    
    # Attachments for containers
    var pools := {"scope": [], "silencer": [], "laser": []}
    for item in compatible:
        var cat := classify(item)
        if cat in pools: pools[cat].append(item)
    _log(["  Container candidates — scope:", pools["scope"].size(),
          " silencer:", pools["silencer"].size(),
          " laser:", pools["laser"].size()])
    
    var nested = weapon_slot.get("nested")
    for cat in pools:
        if pools[cat].is_empty(): continue
        var chance := _container_chance(cat)
        if not roll(chance): continue
        var chosen = pools[cat][randi() % pools[cat].size()]
        if nested != null:
            nested.append(chosen)
            if weapon_node != null: _show_attachment_nodes(weapon_node, chosen)
            _log(["  Container attachment:", cat, "(", chance, "%)"])


# ══════════════════════════════════════════════════════════════
# ③ Floor Loot (loose drops on ground)
# ══════════════════════════════════════════════════════════════

func _wait_and_enhance_floor_loot(sim: Node) -> void:
    await get_tree().process_frame
    if not is_instance_valid(sim): return
    for child in sim.get_children():
        var sd = child.get("slotData")
        if sd == null: continue
        var item = sd.get("itemData")
        if item == null or item.get("type") != "Weapon": continue
        _log(["Floor weapon:", item.get("name") if item.get("name") else "?"])
        enhance_floor_weapon(sd, item, child)

func enhance_floor_weapon(weapon_slot, item_data, weapon_node = null) -> void:
    if not cfg.mod_enabled: return
    var compatible = item_data.get("compatible")
    if compatible == null: compatible = []
    
    # Magazine handling for floor loot
    if roll(cfg.floor_mag_chance):
        var mag_size := int(item_data.get("magazineSize")) \
                        if item_data.get("magazineSize") != null else 0
        if mag_size > 0:
            var fill_min := float(cfg.floor_mag_fill_min) / 100.0
            var fill_max := float(cfg.floor_mag_fill_max) / 100.0
            weapon_slot.amount = max(1, int(mag_size * randf_range(fill_min, fill_max)))
            var mags : Array = compatible.filter(func(i): return classify(i) == "magazine")
            if not mags.is_empty():
                var n = weapon_slot.get("nested")
                if n != null:             
                    var already_has_mag : bool = false
                    for existing in n:
                        if classify(existing) == "magazine":
                            already_has_mag = true
                            break
                    if not already_has_mag:
                        var cm = mags[randi() % mags.size()]
                        n.append(cm)
                        if weapon_node != null: _show_attachment_nodes(weapon_node, cm)
                        _log(["  Floor magazine:", weapon_slot.amount, "/", mag_size])
                    else:
                        _log(["  Floor magazine skipped (already has one)"])
    
    # Attachments for floor loot
    var pools := {"scope": [], "silencer": [], "laser": []}
    for item in compatible:
        var cat := classify(item)
        if cat in pools: pools[cat].append(item)
    _log(["  Floor candidates — scope:", pools["scope"].size(),
          " silencer:", pools["silencer"].size(),
          " laser:", pools["laser"].size()])
    
    var nested = weapon_slot.get("nested")
    for cat in pools:
        if pools[cat].is_empty(): continue
        var chance := _floor_chance(cat)
        if not roll(chance): continue
        var chosen = pools[cat][randi() % pools[cat].size()]
        if nested != null:
            nested.append(chosen)
            if weapon_node != null: _show_attachment_nodes(weapon_node, chosen)
            _log(["  Floor attachment:", cat, "(", chance, "%)"])


# ══════════════════════════════════════════════════════════════
# Attachment 3D model display
# ══════════════════════════════════════════════════════════════

func _show_attachment_nodes(weapon_node: Node, item) -> void:
    var item_file : String = str(item.get("file")) if item.get("file") != null else ""
    if item_file.is_empty(): return
    var att = weapon_node.get_node_or_null("Attachments")
    if att == null:
        _log(["  WARNING: no Attachments node"]); return
    var found : int = 0
    var exact = att.get_node_or_null(item_file)
    if exact:
        _apply_lod_visibility(exact); found += 1
        _log(["  Show (exact):", exact.name])
    var item_lower := item_file.to_lower()
    for child in att.get_children():
        if child == exact: continue
        if child.name.to_lower().contains(item_lower):
            _apply_lod_visibility(child); found += 1
            _log(["  Show (fuzzy):", child.name])
    if classify(item) == "scope":
        for rail_name in RAIL_NODE_NAMES:
            var rail = att.get_node_or_null(rail_name)
            if rail:
                _apply_lod_visibility(rail)
                _log(["  Show (rail):", rail_name]); break
    if found == 0:
        _log(["  WARNING: node '", item_file, "' not found. Available:",
              att.get_children().map(func(c): return c.name)])

func _apply_lod_visibility(node: Node) -> void:
    node.show()
    var lod0 : MeshInstance3D = node.get_node_or_null("LOD0")
    var lod1 : MeshInstance3D = node.get_node_or_null("LOD1")
    if lod0 and lod1:
        lod0.visibility_range_end   = 10.0
        lod1.visibility_range_begin = 9.0
        lod1.visibility_range_end   = 200.0
    elif lod0:
        lod0.visibility_range_end = 200.0
    elif node is MeshInstance3D:
        node.visibility_range_end = 200.0

func _attach_to_ai_weapon(weapon: Node, sd, item) -> void:
    var nested = sd.get("nested")
    if nested == null: return
    nested.append(item)
    _show_attachment_nodes(weapon, item)

# ══════════════════════════════════════════════════════════════
# Classifier
# ══════════════════════════════════════════════════════════════

func classify(item) -> String:
    if item == null: return ""
    var st   := str(item.get("subtype")).to_lower() if item.get("subtype") != null else ""
    var name := str(item.get("name")).to_lower()    if item.get("name")    != null else ""
    var file := str(item.get("file")).to_lower()    if item.get("file")    != null else ""
    var combined := st + " " + name + " " + file
    if st == "magazine": return "magazine"
    if st == "optic" or st == "sight": return "scope"
    if st == "suppressor" or st == "silencer" or st == "muzzle": return "silencer"
    if st == "laser": return "laser"
    for kw in SCOPE_KEYS:    if combined.contains(kw): return "scope"
    for kw in SILENCER_KEYS: if combined.contains(kw): return "silencer"
    for kw in LASER_KEYS:    if combined.contains(kw): return "laser"
    if "magazine" in combined: return "magazine"
    return ""

# ══════════════════════════════════════════════════════════════
# Faction detection
# ══════════════════════════════════════════════════════════════

func _get_ai_faction(ai: Node) -> String:
    var path := ai.scene_file_path.to_lower()
    if not path.is_empty():
        if "punisher" in path: return "military"
        if "military"  in path: return "military"
        if "guard"     in path: return "guard"
        if "bandit"    in path: return "bandit"
    if ai.get("boss") != null and bool(ai.get("boss")): return "military"
    return "bandit"

# ══════════════════════════════════════════════════════════════
# Probability
# ══════════════════════════════════════════════════════════════

func _faction_chance(faction: String, cat: String) -> int:
    match faction:
        "bandit":
            match cat:
                "scope":    return cfg.bandit_scope
                "silencer": return cfg.bandit_silencer
                "laser":    return cfg.bandit_laser
        "guard":
            match cat:
                "scope":    return cfg.guard_scope
                "silencer": return cfg.guard_silencer
                "laser":    return cfg.guard_laser
        "military":
            match cat:
                "scope":    return cfg.military_scope
                "silencer": return cfg.military_silencer
                "laser":    return cfg.military_laser
    return 0

func _container_chance(cat: String) -> int:
    match cat:
        "scope":    return cfg.container_scope
        "silencer": return cfg.container_silencer
        "laser":    return cfg.container_laser
    return 0

func _floor_chance(cat: String) -> int:
    match cat:
        "scope":    return cfg.floor_scope
        "silencer": return cfg.floor_silencer
        "laser":    return cfg.floor_laser
    return 0

func roll(chance_pct: int) -> bool:
    if chance_pct <= 0: return false
    if chance_pct >= 100: return true
    return (randi() % 100) < chance_pct

# ══════════════════════════════════════════════════════════════
# Session / logging
# ══════════════════════════════════════════════════════════════

func _increment_session() -> void:
    DirAccess.open("user://").make_dir_recursive("user://MCM/WeaponAttachmentSpawner")
    var s := ConfigFile.new()
    if FileAccess.file_exists(SESSION_SAVE_PATH):
        s.load(SESSION_SAVE_PATH)
        _session_count = int(s.get_value("Progress", "sessions", 0)) + 1
    else:
        _session_count = 1
    s.set_value("Progress", "sessions", _session_count)
    s.save(SESSION_SAVE_PATH)

func _log(parts: Array) -> void:
    if cfg.debug:
        print("[WAS] ", " ".join(parts.map(func(p): return str(p))))
