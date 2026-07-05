## ModConfig.gd — MCM Configuration Manager v5.2

extends Node

var cfg = preload("res://LM_mods/WeaponAttachmentSpawner/Settings.tres")
var McmHelpers = null
const FILE_PATH = "user://MCM/WeaponAttachmentSpawner"
const MOD_ID    = "WeaponAttachmentSpawner"

func _ready() -> void:
    if ResourceLoader.exists("res://ModConfigurationMenu/Scripts/Doink Oink/MCM_Helpers.tres"):
        McmHelpers = load("res://ModConfigurationMenu/Scripts/Doink Oink/MCM_Helpers.tres")
    var c := ConfigFile.new()
    _register_all(c)
    if McmHelpers:
        if not FileAccess.file_exists(FILE_PATH + "/config.ini"):
            DirAccess.open("user://").make_dir_recursive(FILE_PATH)
            c.save(FILE_PATH + "/config.ini")
        else:
            McmHelpers.CheckConfigurationHasUpdated(MOD_ID, c, FILE_PATH + "/config.ini")
            c.load(FILE_PATH + "/config.ini")
        McmHelpers.RegisterConfiguration(
            MOD_ID, "LM - Weapon Attachment Spawner", FILE_PATH,
            "Randomly equips enemy weapons with scopes, suppressors and lasers by faction. World weapons in containers or on the ground can spawn with attachments and loaded magazines.",
            _on_config_updated, self)
        _on_config_updated(c)
    else:
        if not FileAccess.file_exists(FILE_PATH + "/config.ini"):
            DirAccess.open("user://").make_dir_recursive(FILE_PATH)
            c.save(FILE_PATH + "/config.ini")
        else:
            c.load(FILE_PATH + "/config.ini")
        _on_config_updated(c)
        push_warning("[WAS] MCM not found — using default settings.")

func _register_all(c: ConfigFile) -> void:

    c.set_value("Category", "Credit to Peter Master", {"menu_pos" = 0})

    # 1. General
    c.set_value("Bool","mod_enabled",{"name"="Enable Mod","tooltip"="Disable to completely stop all attachment and magazine injection.","default"=true,"value"=true,"category"="1. General"})
    c.set_value("Bool","debug",{"name"="Debug Logging","tooltip"="Print detailed log output to godot.log. Disable during normal play.","default"=false,"value"=false,"category"="1. General"})

    # 2. Enemy - Bandit
    c.set_value("Int","bandit_scope",{"name"="Scope Chance (%)","tooltip"="Chance for a bandit's weapon to have a scope.","default"=10,"value"=10,"minRange"=0,"maxRange"=100,"category"="2. Enemy - Bandit"})
    c.set_value("Int","bandit_silencer",{"name"="Suppressor Chance (%)","tooltip"="Chance for a bandit's weapon to have a suppressor.","default"=8,"value"=8,"minRange"=0,"maxRange"=100,"category"="2. Enemy - Bandit"})
    c.set_value("Int","bandit_laser",{"name"="Laser Chance (%)","tooltip"="Chance for a bandit's weapon to have a laser.","default"=8,"value"=8,"minRange"=0,"maxRange"=100,"category"="2. Enemy - Bandit"})

    # 3. Enemy - Guard
    c.set_value("Int","guard_scope",{"name"="Scope Chance (%)","tooltip"="Chance for a guard's weapon to have a scope.","default"=30,"value"=30,"minRange"=0,"maxRange"=100,"category"="3. Enemy - Guard"})
    c.set_value("Int","guard_silencer",{"name"="Suppressor Chance (%)","tooltip"="Chance for a guard's weapon to have a suppressor.","default"=15,"value"=15,"minRange"=0,"maxRange"=100,"category"="3. Enemy - Guard"})
    c.set_value("Int","guard_laser",{"name"="Laser Chance (%)","tooltip"="Chance for a guard's weapon to have a laser.","default"=15,"value"=15,"minRange"=0,"maxRange"=100,"category"="3. Enemy - Guard"})

    # 4. Enemy - Military/Punisher
    c.set_value("Int","military_scope",{"name"="Scope Chance (%)","tooltip"="Chance for military (incl. Punisher) to have a scope.","default"=40,"value"=40,"minRange"=0,"maxRange"=100,"category"="4. Enemy - Military/Punisher"})
    c.set_value("Int","military_silencer",{"name"="Suppressor Chance (%)","tooltip"="Chance for military (incl. Punisher) to have a suppressor.","default"=35,"value"=35,"minRange"=0,"maxRange"=100,"category"="4. Enemy - Military/Punisher"})
    c.set_value("Int","military_laser",{"name"="Laser Chance (%)","tooltip"="Chance for military (incl. Punisher) to have a laser.","default"=30,"value"=30,"minRange"=0,"maxRange"=100,"category"="4. Enemy - Military/Punisher"})

    # 5. Container Loot - Attachments 
    c.set_value("Int","container_scope",{"name"="Container Scope Chance (%)","tooltip"="Chance for a weapon in a container to have a scope.","default"=15,"value"=15,"minRange"=0,"maxRange"=100,"category"="5. Container Loot - Attachments"})
    c.set_value("Int","container_silencer",{"name"="Container Suppressor Chance (%)","tooltip"="Chance for a weapon in a container to have a suppressor.","default"=6,"value"=6,"minRange"=0,"maxRange"=100,"category"="5. Container Loot - Attachments"})
    c.set_value("Int","container_laser",{"name"="Container Laser Chance (%)","tooltip"="Chance for a weapon in a container to have a laser.","default"=7,"value"=7,"minRange"=0,"maxRange"=100,"category"="5. Container Loot - Attachments"})

    # 6. Container Loot - Magazine
    c.set_value("Int","container_mag_chance",{"name"="Container Magazine Chance (%)","tooltip"="Chance for a container weapon to spawn with a loaded magazine.","default"=50,"value"=50,"minRange"=0,"maxRange"=100,"category"="6. Container Loot - Magazine"})
    c.set_value("Int","container_mag_fill_min",{"name"="Container Min Fill (%)","tooltip"="Minimum bullet fill ratio for container weapon magazines.","default"=5,"value"=5,"minRange"=1,"maxRange"=100,"category"="6. Container Loot - Magazine"})
    c.set_value("Int","container_mag_fill_max",{"name"="Container Max Fill (%)","tooltip"="Maximum bullet fill ratio for container weapon magazines.","default"=80,"value"=80,"minRange"=1,"maxRange"=100,"category"="6. Container Loot - Magazine"})

    # 7. Floor Loot - Attachments 
    c.set_value("Int","floor_scope",{"name"="Floor Scope Chance (%)","tooltip"="Chance for a weapon on the ground to have a scope.","default"=8,"value"=8,"minRange"=0,"maxRange"=100,"category"="7. Floor Loot - Attachments"})
    c.set_value("Int","floor_silencer",{"name"="Floor Suppressor Chance (%)","tooltip"="Chance for a weapon on the ground to have a suppressor.","default"=5,"value"=5,"minRange"=0,"maxRange"=100,"category"="7. Floor Loot - Attachments"})
    c.set_value("Int","floor_laser",{"name"="Floor Laser Chance (%)","tooltip"="Chance for a weapon on the ground to have a laser.","default"=3,"value"=3,"minRange"=0,"maxRange"=100,"category"="7. Floor Loot - Attachments"})

    # 8. Floor Loot - Magazine
    c.set_value("Int","floor_mag_chance",{"name"="Floor Magazine Chance (%)","tooltip"="Chance for a floor weapon to spawn with a loaded magazine.","default"=25,"value"=25,"minRange"=0,"maxRange"=100,"category"="8. Floor Loot - Magazine"})
    c.set_value("Int","floor_mag_fill_min",{"name"="Floor Min Fill (%)","tooltip"="Minimum bullet fill ratio for floor weapon magazines.","default"=5,"value"=5,"minRange"=1,"maxRange"=100,"category"="8. Floor Loot - Magazine"})
    c.set_value("Int","floor_mag_fill_max",{"name"="Floor Max Fill (%)","tooltip"="Maximum bullet fill ratio for floor weapon magazines.","default"=60,"value"=60,"minRange"=1,"maxRange"=100,"category"="8. Floor Loot - Magazine"})

# 9. Auto-Chamber System (excludes AI weapons)
    c.set_value("Dropdown","chamber_mode",{"name"="Chamber Behavior","tooltip"="Disabled: every world/container weapon found with a magazine is always pre-chambered (vanilla-like behavior).\nAuto Chamber on Equip: a weapon may spawn unchambered (rate set below); when you equip it, the charge animation plays automatically and the round is chambered.\nManual Chamber (Press R): same spawn rate, but the charge animation only plays when you press R while the weapon is equipped and chamber is empty (single tap, normal reload still works for full reload).\nAI weapons are never affected.","default"=1,"value"=1,"options"=["Disabled (Always Pre-chambered)","Auto Chamber on Equip","Manual Chamber (Press R)"],"category"="9. Auto-Chamber System"})
    c.set_value("Int","unchamber_chance",{"name"="Unchambered Spawn Chance (%)","tooltip"="When Chamber Behavior is Auto or Manual, this is the probability that a world/container weapon (with magazine) spawns unchambered. AI weapons are unaffected by this setting.","default"=30,"value"=30,"minRange"=0,"maxRange"=100,"category"="9. Auto-Chamber System"})


func _on_config_updated(c: ConfigFile) -> void:
    cfg.mod_enabled         = c.get_value("Bool","mod_enabled")["value"]
    cfg.debug               = c.get_value("Bool","debug")["value"]
    cfg.bandit_scope        = c.get_value("Int","bandit_scope")["value"]
    cfg.bandit_silencer     = c.get_value("Int","bandit_silencer")["value"]
    cfg.bandit_laser        = c.get_value("Int","bandit_laser")["value"]
    cfg.guard_scope         = c.get_value("Int","guard_scope")["value"]
    cfg.guard_silencer      = c.get_value("Int","guard_silencer")["value"]
    cfg.guard_laser         = c.get_value("Int","guard_laser")["value"]
    cfg.military_scope      = c.get_value("Int","military_scope")["value"]
    cfg.military_silencer   = c.get_value("Int","military_silencer")["value"]
    cfg.military_laser      = c.get_value("Int","military_laser")["value"]
    
    # Container settings
    cfg.container_scope     = c.get_value("Int","container_scope")["value"]
    cfg.container_silencer  = c.get_value("Int","container_silencer")["value"]
    cfg.container_laser     = c.get_value("Int","container_laser")["value"]
    cfg.container_mag_chance    = c.get_value("Int","container_mag_chance")["value"]
    cfg.container_mag_fill_min  = c.get_value("Int","container_mag_fill_min")["value"]
    cfg.container_mag_fill_max  = c.get_value("Int","container_mag_fill_max")["value"]
    
    # Floor settings
    cfg.floor_scope         = c.get_value("Int","floor_scope")["value"]
    cfg.floor_silencer      = c.get_value("Int","floor_silencer")["value"]
    cfg.floor_laser         = c.get_value("Int","floor_laser")["value"]
    cfg.floor_mag_chance    = c.get_value("Int","floor_mag_chance")["value"]
    cfg.floor_mag_fill_min  = c.get_value("Int","floor_mag_fill_min")["value"]
    cfg.floor_mag_fill_max  = c.get_value("Int","floor_mag_fill_max")["value"]

    # Chamber Round
    cfg.chamber_mode        = c.get_value("Dropdown","chamber_mode")["value"]
    cfg.unchamber_chance    = c.get_value("Int","unchamber_chance")["value"]
