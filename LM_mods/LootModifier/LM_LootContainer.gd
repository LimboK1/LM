extends Node

var lootSettings = preload("res://LM_mods/LootModifier/LootSettings.tres")
var _creating_loot_from_custom_generator = false

func on_ready():
	var lib = Engine.get_meta("RTVModLib")
	var container = lib._caller

	if container.stash:

		container.process_mode = ProcessMode.PROCESS_MODE_DISABLED
		container.hide()

		if randi_range(0, 100) <= lootSettings.special_crate_chance:
			container.process_mode = ProcessMode.PROCESS_MODE_ALWAYS
			container.show()

func on_container_generateloot():
	var lib = Engine.get_meta("RTVModLib")
	var container = lib._caller

	if container == null:
		return

	container.loot.clear()

	generate_initial_loot(container)

	if container.loot.size() == 0 and lootSettings.reroll_container:
		generate_initial_loot(container)

func generate_initial_loot(container):

	var rarityRoll = randf()
	var LM_Roll: float = randf()
	var loot_before = container.loot.size()

	if rarityRoll * 100.0 <= lootSettings.joker_chance: # Basically a joker has a (0.01) 1% chance to occur, so this effectively increases the chance if modified.
		container.joker = true

	if container.joker:
		rarityRoll = 1.0

	if rarityRoll <= lootSettings.legendary_chance:
		if container.legendaryBucket.size() != 0:
			for pick in range(randi_range(lootSettings.legendary_min,lootSettings.legendary_max)):
				_create_loot_with_condition(container, container.legendaryBucket.pick_random())

	elif rarityRoll <= lootSettings.rare_chance:
		if container.rareBucket.size() != 0:
			for pick in range(randi_range(lootSettings.rare_min, lootSettings.rare_max)): 
				_create_loot_with_condition(container, container.rareBucket.pick_random())

	elif rarityRoll <= lootSettings.common_chance:
		if container.commonBucket.size() != 0:
			for pick in range(randi_range(lootSettings.common_min, lootSettings.common_max)): 
				_create_loot_with_condition(container, container.commonBucket.pick_random())

	elif rarityRoll == 1.0:

		if LM_Roll <= lootSettings.joker_legendary_item_chance:
			if container.legendaryBucket.size() != 0:
				for pick in range(randi_range(lootSettings.joker_legendary_min,lootSettings.joker_legendary_max)):
					_create_loot_with_condition(container, container.legendaryBucket.pick_random())

		if container.rareBucket.size() != 0:
			for pick in range(randi_range(lootSettings.joker_rare_min, lootSettings.joker_rare_max)):
				_create_loot_with_condition(container, container.rareBucket.pick_random())

		if container.commonBucket.size() != 0:
			for pick in range(randi_range(lootSettings.joker_common_min, lootSettings.joker_common_max)):
				_create_loot_with_condition(container, container.commonBucket.pick_random())

	# Add items to meet minimum if needed.
	if lootSettings.container_loot_adding:
		var current_loot_count = container.loot.size() - loot_before

		if current_loot_count <= lootSettings.min_loot_items_container:
			var min_items = lootSettings.min_loot_items_container
			var max_items = lootSettings.max_loot_items_container

			if max_items < min_items:
				max_items = min_items

			var target_loot_count = randi_range(min_items, max_items)
			var items_to_add = target_loot_count - current_loot_count

			for i in range(items_to_add):
				if randf() <= lootSettings.loot_add_chance:
					var item = _get_weighted_random_item(container)
					if item:
						_create_loot_with_condition(container, item)
					else:
						break

# Helper function(s)
func _get_weighted_random_item(container):
	var roll = randf()

	if roll <= lootSettings.legendary_chance:
		if container.legendaryBucket.size() > 0:
			return container.legendaryBucket.pick_random()

	elif roll <= lootSettings.rare_chance:
		if container.rareBucket.size() > 0:
			return container.rareBucket.pick_random()

	else:
		if container.commonBucket.size() > 0:
			return container.commonBucket.pick_random()

	var all_items = []
	all_items.append_array(container.commonBucket)
	all_items.append_array(container.rareBucket)
	all_items.append_array(container.legendaryBucket)

	if all_items.is_empty():
		return null

	return all_items.pick_random()

# Huge thanks to Blur for helping me with conditions!

func _create_loot_with_condition(container, item):
	if container == null or item == null:
		return

	_creating_loot_from_custom_generator = true
	container.CreateLoot(item)
	_creating_loot_from_custom_generator = false

	_apply_condition_to_latest_slot(container, item)


func on_container_createloot(item):
	if _creating_loot_from_custom_generator:
		return

	var lib = Engine.get_meta("RTVModLib")
	var container = lib._caller

	_apply_condition_to_latest_slot(container, item)


func _apply_condition_to_latest_slot(container, item):
	if container == null or item == null:
		return

	if container.loot.is_empty():
		return

	var slot = container.loot[-1]

	if item.type == "Weapon" or item.subtype == "Light" or item.subtype == "NVG":
		slot.condition = randi_range(lootSettings.min_condition, lootSettings.max_condition)
