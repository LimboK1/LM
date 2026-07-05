extends Node

var McmHelpers = load("res://ModConfigurationMenu/Scripts/Doink Oink/MCM_Helpers.tres")
var LootSettings = preload("res://LM_mods/LootModifier/LootSettings.tres")

var _config = ConfigFile.new()

const MOD_ID = "LootModifier"
const FILE_PATH = "user://MCM/LootModifier"
const CONFIG_PATH = FILE_PATH + "/config.ini"

func _ready():
	_config.set_value("Category", "Container Loot", {"menu_pos" = 0})
	_config.set_value("Category", "Floor Loot", {"menu_pos" = 1})
	_config.set_value("Category", "Loot Rarity Item Ranges", {"menu_pos" = 2})
	_config.set_value("Category", "Miscellaneous", {"menu_pos" = 3})

#---------------------------------------------------------------------------------------
#                      Container Loot
#---------------------------------------------------------------------------------------

	_config.set_value("Float", "common_chance", {
		"name": "Container Item Chance: Common",
		"tooltip": "Higher = more common items.",
		"menu_pos": 0,
		"category": "Container Loot",
		"default": 0.25,
		"step": 0.0001,
		"minRange": 0.0,
		"maxRange": 1.0
	})

	_config.set_value("Float", "rare_chance", {
		"name": "Container Item Chance: Rare",
		"tooltip": "Higher = more rare items.",
		"menu_pos": 1,
		"category": "Container Loot",
		"default": 0.05,
		"step": 0.0001,
		"minRange": 0.0,
		"maxRange": 1.0
	})

	_config.set_value("Float", "legendary_chance", {
		"name": "Container Item Chance: Legendary",
		"tooltip": "Higher = more legendary items.",
		"menu_pos": 2,
		"category": "Container Loot",
		"default": 0.001,
		"step": 0.0001,
		"minRange": 0.0,
		"maxRange": 1.0
	})

	_config.set_value("Bool", "reroll_container", {
		"name": "Container Loot Reroll",
		"tooltip": "Rerolls container loot if no items spawn",
		"menu_pos": 6,
		"category": "Container Loot",
		"default": false,
	})

	_config.set_value("Bool", "container_loot_adding", {
		"name": "Container Loot Adding",
		"tooltip": "Enables/Disables container loot add chance",
		"menu_pos": 7,
		"category": "Container Loot",
		"default": true,
	})

	_config.set_value("Float", "loot_add_chance", {
		"name": "Container Loot Add Chance",
		"tooltip": "Chance to add items between min and max if min items aren't in container",
		"menu_pos": 8,
		"category": "Container Loot",
		"default": 0.3,
		"step": 0.0001,
		"minRange": 0.0,
		"maxRange": 1.0
	})
	
	_config.set_value("Int", "min_loot_items_container", {
		"name": "Minimum items in container",
		"tooltip": "Min items in a container if the loot add chance succeeds",
		"menu_pos": 9,
		"category": "Container Loot",
		"default": 1,
		"minRange": 0,
		"maxRange": 15
	})

	_config.set_value("Int", "max_loot_items_container", {
		"name": "Maximum items in container",
		"tooltip": "Max items in a container if the loot add chance succeeds",
		"menu_pos": 10,
		"category": "Container Loot",
		"default": 5,
		"minRange": 0,
		"maxRange": 15
	})

#---------------------------------------------------------------------------------------
#                      Floor Loot
#---------------------------------------------------------------------------------------

	_config.set_value("Float", "common_chance_floor", {
		"name": "Floor Item Chance: Common",
		"tooltip": "Higher = more common items.",
		"menu_pos": 1,
		"category": "Floor Loot",
		"default": 0.25,
		"step": 0.0001,
		"minRange": 0.0,
		"maxRange": 1.0
	})
	
	_config.set_value("Float", "rare_chance_floor", {
		"name": "Floor Item Chance: Rare",
		"tooltip": "Higher = more rare items.",
		"menu_pos": 2,
		"category": "Floor Loot",
		"default": 0.05,
		"step": 0.0001,
		"minRange": 0.0,
		"maxRange": 1.0
	})
	
	_config.set_value("Float", "legendary_chance_floor", {
		"name": "Floor Item Chance: Legendary",
		"tooltip": "Higher = more legendary items.",
		"menu_pos": 3,
		"category": "Floor Loot",
		"default": 0.001,
		"step": 0.0001,
		"minRange": 0.0,
		"maxRange": 1.0
	})

	_config.set_value("Bool", "floor_loot_adding", {
		"name": "Floor Loot Adding",
		"tooltip": "Enables/Disable floor loot add chance",
		"menu_pos": 4,
		"category": "Floor Loot",
		"default": true,
	})

	_config.set_value("Float", "guarantee_floor_chance", {
		"name": "Floor Loot add Chance",
		"tooltip": "Chance to reroll floor loot if no items spawned",
		"menu_pos": 5,
		"category": "Floor Loot",
		"default": 0.35,
		"step": 0.0001,
		"minRange": 0.0,
		"maxRange": 1.0
	})

	_config.set_value("Int", "min_loot_items_floor", {
		"name": "Minimum items on floor",
		"tooltip": "Min items per floor spawn node if the loot add chance succeeds. May cause lag at high values",
		"menu_pos": 6,
		"category": "Floor Loot",
		"default": 1,
		"minRange": 0,
		"maxRange": 30
	})

	_config.set_value("Int", "max_loot_items_floor", {
		"name": "Maximum items on floor",
		"tooltip": "Max items per floor spawn node if the loot add chance succeeds. May cause lag at high values",
		"menu_pos": 7,
		"category": "Floor Loot",
		"default": 5,
		"minRange": 0,
		"maxRange": 30
	})

#---------------------------------------------------------------------------------------
#                      Loot Rarity Item Ranges
#---------------------------------------------------------------------------------------

	_config.set_value("Int", "common_min", {
		"name": "Minimum common items",
		"tooltip": "The minimum common items when a common roll occurs",
		"menu_pos": 1,
		"category": "Loot Rarity Item Ranges",
		"default": 0,
		"minRange": 0,
		"maxRange": 10
	})

	_config.set_value("Int", "common_max", {
		"name": "Maximum common items",
		"tooltip": "The maximum common items when a common roll occurs",
		"menu_pos": 2,
		"category": "Loot Rarity Item Ranges",
		"default": 4,
		"minRange": 0,
		"maxRange": 10
	})

	_config.set_value("Int", "rare_min", {
		"name": "Minimum rare items",
		"tooltip": "The minimum rare items when a rare roll occurs",
		"menu_pos": 3,
		"category": "Loot Rarity Item Ranges",
		"default": 0,
		"minRange": 0,
		"maxRange": 10
	})

	_config.set_value("Int", "rare_max", {
		"name": "Maximum rare items",
		"tooltip": "The maximum rare items when a rare roll occurs",
		"menu_pos": 4,
		"category": "Loot Rarity Item Ranges",
		"default": 1,
		"minRange": 0,
		"maxRange": 10
	})

	_config.set_value("Int", "legendary_min", {
		"name": "Minimum legendary items",
		"tooltip": "The minimum legendary items when a legendary roll occurs",
		"menu_pos": 5,
		"category": "Loot Rarity Item Ranges",
		"default": 1,
		"minRange": 0,
		"maxRange": 10
	})

	_config.set_value("Int", "legendary_max", {
		"name": "Maximum legendary items",
		"tooltip": "The maximum legendary items when a legendary roll occurs",
		"menu_pos": 6,
		"category": "Loot Rarity Item Ranges",
		"default": 1,
		"minRange": 0,
		"maxRange": 10
	})

	_config.set_value("Int", "joker_common_min", {
		"name": "Joker min common items",
		"tooltip": "The minimum common items when a joker roll occurs",
		"menu_pos": 7,
		"category": "Loot Rarity Item Ranges",
		"default": 4,
		"minRange": 0,
		"maxRange": 10
	})

	_config.set_value("Int", "joker_common_max", {
		"name": "Joker max common items",
		"tooltip": "The maximum common items when a joker roll occurs",
		"menu_pos": 8,
		"category": "Loot Rarity Item Ranges",
		"default": 10,
		"minRange": 0,
		"maxRange": 10
	})

	_config.set_value("Int", "joker_rare_min", {
		"name": "Joker min rare items",
		"tooltip": "The minimum rare items when a joker roll occurs",
		"menu_pos": 9,
		"category": "Loot Rarity Item Ranges",
		"default": 1,
		"minRange": 0,
		"maxRange": 10
	})

	_config.set_value("Int", "joker_rare_max", {
		"name": "Joker max rare items",
		"tooltip": "The maximum rare items when a joker roll occurs",
		"menu_pos": 10,
		"category": "Loot Rarity Item Ranges",
		"default": 2,
		"minRange": 0,
		"maxRange": 10
	})

	_config.set_value("Int", "joker_legendary_min", {
		"name": "Joker min legendary items",
		"tooltip": "The minimum legendary items when a joker roll occurs and a legendary succeeds",
		"menu_pos": 11,
		"category": "Loot Rarity Item Ranges",
		"default": 1,
		"minRange": 0,
		"maxRange": 10
	})

	_config.set_value("Int", "joker_legendary_max", {
		"name": "Joker max legendary items",
		"tooltip": "The maximum legendary items when a joker roll occurs and a legendary succeeds",
		"menu_pos": 12,
		"category": "Loot Rarity Item Ranges",
		"default": 1,
		"minRange": 0,
		"maxRange": 10
	})

#---------------------------------------------------------------------------------------
#                      Miscellaneous
#---------------------------------------------------------------------------------------

	_config.set_value("Int", "joker_chance", {
		"name": "Joker Chance(%)",
		"tooltip": "Jokers are a type of spawn in vanilla, they have a 1% chance to occur",
		"menu_pos": 1,
		"category": "Miscellaneous",
		"default": 1,
		"step": 1,
		"minRange": 0,
		"maxRange": 100
	})

	_config.set_value("Float", "joker_legendary_item_chance", {
		"name": "Joker Legendary Item Chance",
		"tooltip": "Higher = increased chance of legendary spawning when a joker occurs",
		"menu_pos": 2,
		"category": "Miscellaneous",
		"default": 0.1,
		"step": 0.0001,
		"minRange": 0,
		"maxRange": 1.0
	})

	_config.set_value("Int", "special_crate_chance", {
		"name": "Special Crate Chance(%)",
		"tooltip": "Special crates are the large green ones that appear in vostok",
		"menu_pos": 3,
		"category": "Miscellaneous",
		"default": 10,
		"step": 1,
		"minRange": 0,
		"maxRange": 100
	})

	_config.set_value("Int", "min_condition", {
		"name": "Minimum item spawn condition",
		"tooltip": "The minimum condition items spawn at",
		"menu_pos": 4,
		"category": "Miscellaneous",
		"default": 25,
		"minRange": 0,
		"maxRange": 100
	})

	_config.set_value("Int", "max_condition", {
		"name": "Maximum item spawn condition",
		"tooltip": "The maximum condition items spawn at",
		"menu_pos": 5,
		"category": "Miscellaneous",
		"default": 100,
		"minRange": 0,
		"maxRange": 100
	})

	DirAccess.make_dir_recursive_absolute(FILE_PATH)

	if !FileAccess.file_exists(CONFIG_PATH):
		var save_err = _config.save(CONFIG_PATH)
		if save_err != OK:
			push_error("LootModifier: failed to save default MCM config: " + str(save_err))
	else:
		McmHelpers.CheckConfigurationHasUpdated(MOD_ID, _config, CONFIG_PATH)

		var load_err = _config.load(CONFIG_PATH)
		if load_err != OK:
			push_error("LootModifier: failed to load MCM config: " + str(load_err))

	apply_config_values(_config)

	McmHelpers.RegisterConfiguration(
		MOD_ID,
		"LM - Container and Floor",
		FILE_PATH,
		"A simple tool for modifying loot drops",
		{
			"config.ini": _on_config_updated
		}
	)

func apply_config_values(_config: ConfigFile):


# Container Loot

	LootSettings.common_chance = _config.get_value("Float", "common_chance")["value"]
	LootSettings.rare_chance = _config.get_value("Float", "rare_chance")["value"]
	LootSettings.legendary_chance = _config.get_value("Float", "legendary_chance")["value"]
	
	LootSettings.reroll_container = _config.get_value("Bool", "reroll_container")["value"]

	LootSettings.container_loot_adding = _config.get_value("Bool", "container_loot_adding")["value"]
	LootSettings.loot_add_chance = _config.get_value("Float", "loot_add_chance")["value"]
	LootSettings.min_loot_items_container = _config.get_value("Int", "min_loot_items_container")["value"]
	LootSettings.max_loot_items_container = _config.get_value("Int", "max_loot_items_container")["value"]

# Floor Loot

	LootSettings.common_chance_floor = _config.get_value("Float", "common_chance_floor")["value"]
	LootSettings.rare_chance_floor = _config.get_value("Float", "rare_chance_floor")["value"]
	LootSettings.legendary_chance_floor = _config.get_value("Float", "legendary_chance_floor")["value"]

	LootSettings.floor_loot_adding = _config.get_value("Bool", "floor_loot_adding")["value"]
	LootSettings.guarantee_floor_chance = _config.get_value("Float", "guarantee_floor_chance")["value"]
	LootSettings.min_loot_items_floor = _config.get_value("Int", "min_loot_items_floor")["value"]
	LootSettings.max_loot_items_floor = _config.get_value("Int", "max_loot_items_floor")["value"]

# Loot Chance Ranges

	LootSettings.common_min = _config.get_value("Int", "common_min")["value"]
	LootSettings.common_max = _config.get_value("Int", "common_max")["value"]
	
	LootSettings.rare_min = _config.get_value("Int", "rare_min")["value"]
	LootSettings.rare_max = _config.get_value("Int", "rare_max")["value"]
	
	LootSettings.legendary_min = _config.get_value("Int", "legendary_min")["value"]
	LootSettings.legendary_max = _config.get_value("Int", "legendary_max")["value"]

	LootSettings.joker_common_min = _config.get_value("Int", "joker_common_min")["value"]
	LootSettings.joker_common_max = _config.get_value("Int", "joker_common_max")["value"]
	
	LootSettings.joker_rare_min = _config.get_value("Int", "joker_rare_min")["value"]
	LootSettings.joker_rare_max = _config.get_value("Int", "joker_rare_max")["value"]

	LootSettings.joker_legendary_min = _config.get_value("Int", "joker_legendary_min")["value"]
	LootSettings.joker_legendary_max = _config.get_value("Int", "joker_legendary_max")["value"]

# Miscellaneous

	LootSettings.joker_chance = _config.get_value("Int", "joker_chance")["value"]
	LootSettings.joker_legendary_item_chance = _config.get_value("Float", "joker_legendary_item_chance")["value"]

	LootSettings.special_crate_chance = _config.get_value("Int", "special_crate_chance")["value"]

	LootSettings.min_condition = _config.get_value("Int", "min_condition")["value"]
	LootSettings.max_condition = _config.get_value("Int", "max_condition")["value"]

	LootSettings.mcmEnabled = true

func _on_config_updated(updated_config: ConfigFile):
	print("LootModifier: Config updated by MCM")
	_config = updated_config
	apply_config_values(_config)
