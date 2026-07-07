extends Resource
class_name LootSettings

var mcmEnabled: bool = false

#-------------Miscellaneous-------------#

# Item spawn condition

var min_condition: int = 25
var max_condition: int = 100

# Chance of a Joker roll (%)
var joker_chance: int = 1

# Chance of a joker spawning a legendary item
var joker_legendary_item_chance: float = 0.10

# Chance of a special crate appearing
var special_crate_chance: int = 10

# AI weapon spawn condition

# var AI_min_condition: int = 5
# var AI_max_condition: int = 50

#-------------Container Loot-------------#

# Item drop chance
var common_chance: float = 0.25
var rare_chance: float = 0.05
var legendary_chance: float = 0.001

# Item drop ranges
var common_min: int = 0
var common_max: int = 4

var rare_min: int = 0
var rare_max: int = 1

var legendary_min: int = 1
var legndary_max: int = 1

var joker_common_min: int = 4
var joker_common_max: int = 10

var joker_rare_min: int = 1
var joker_rare_max: int = 2

var joker_legendary_min: int = 1
var joker_legndary_max: int = 1

# corpse 
# var corpse_loot_chance: int = 70

# Loot Generation Reroll
var reroll_container: bool = false

# Loot add chance and range
var container_loot_adding: bool = true
var loot_add_chance: float = 0.3
var min_loot_items_container: int = 1
var max_loot_items_container: int = 3

#-------------Floor Loot-------------#

# Item drop chance
var common_chance_floor: float = 0.25
var rare_chance_floor: float = 0.05
var legendary_chance_floor: float = 0.001

var joker_legendary_item_chance_floor: float = 0.01

# Change to something along lines of add_floor_chance later for readability
var floor_loot_adding: bool = true
var guarantee_floor_chance: float = 0.35
var min_loot_items_floor: int = 1
var max_loot_items_floor: int = 5
