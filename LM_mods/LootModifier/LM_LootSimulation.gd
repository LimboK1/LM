extends Node

var lootSettings = preload("res://LM_mods/LootModifier/LootSettings.tres")
var sim = null  # Store sim reference for use across functions

func on_simulation_generateloot():
	var lib = Engine.get_meta("RTVModLib")
	sim = lib._caller
	lib.skip_super()

	# sim.loot.clear()

	var Roll = randf()
	var LM_Roll: float = randf()

	if sim.joker:
		Roll = 1.0

	if Roll <= lootSettings.legendary_chance_floor:
		if sim.legendaryBucket.size() != 0:
			for pick in range(randi_range(lootSettings.legendary_min,lootSettings.legendary_max)):
				sim.loot.append(sim.legendaryBucket.pick_random())

	elif Roll <= lootSettings.rare_chance_floor:
		if sim.rareBucket.size() != 0:
			for pick in randi_range(lootSettings.rare_min, lootSettings.rare_max):
				sim.loot.append(sim.rareBucket.pick_random())

	elif Roll <= lootSettings.common_chance_floor:
		if sim.commonBucket.size() != 0:
			for pick in randi_range(lootSettings.common_min, lootSettings.common_max):
				sim.loot.append(sim.commonBucket.pick_random())

	elif Roll == 1.0:
		if LM_Roll <= lootSettings.joker_legendary_item_chance and sim.legendaryBucket.size() != 0:
			for pick in range(randi_range(lootSettings.joker_legendary_min,lootSettings.joker_legendary_max)):
				sim.loot.append(sim, sim.legendaryBucket.pick_random())

		if sim.rareBucket.size() != 0:
			for pick in randi_range(lootSettings.joker_rare_min, lootSettings.joker_rare_max):
				sim.loot.append(sim.rareBucket.pick_random())

		if sim.commonBucket.size() != 0:
			for pick in randi_range(lootSettings.joker_common_min, lootSettings.joker_common_max):
				sim.loot.append(sim.commonBucket.pick_random())

	if lootSettings.floor_loot_adding and Roll <= lootSettings.guarantee_floor_chance:
		var min_items = lootSettings.min_loot_items_floor
		var max_items = lootSettings.max_loot_items_floor

		if max_items < min_items:
			max_items = min_items

		var target_loot_count = randi_range(min_items, max_items)

		for i in range(target_loot_count):
				_get_weighted_random_item(sim)



func _get_weighted_random_item(sim):
	var roll = randf()

	if roll <= lootSettings.legendary_chance_floor:
		if sim.legendaryBucket.size() > 0:
			sim.loot.append(sim.legendaryBucket.pick_random())
	elif roll <= lootSettings.rare_chance_floor:
		if sim.rareBucket.size() > 0:
			sim.loot.append(sim.rareBucket.pick_random())
	else:
		if sim.commonBucket.size() > 0:
			sim.loot.append(sim.commonBucket.pick_random())

	var all_items = []
	all_items.append_array(sim.commonBucket)
	all_items.append_array(sim.rareBucket)
	all_items.append_array(sim.legendaryBucket)

	if all_items.is_empty():
		return null

	return all_items.pick_random()

func on_simulation_spawnitems():
	var lib = Engine.get_meta("RTVModLib")
	var sim = lib._caller
	lib.skip_super()

	if sim.loot.size() != 0:
		for itemData in sim.loot:
			var file = Database.get(itemData.file)
			if !file:
				print("File not found: " + itemData.file)
				continue

			var pickup = Database.get(itemData.file).instantiate()
			sim.add_child(pickup)

			var dropDirection = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
			pickup.Unfreeze()
			pickup.linear_velocity = dropDirection * 10.0

			var newSlotData = SlotData.new()
			newSlotData.itemData = itemData

			if itemData.defaultAmount != 0:
				newSlotData.amount = randi_range(1, itemData.defaultAmount)

			# Condition is all I modify so far, I will modify the rest at some later date
			if itemData.type == "Weapon" or itemData.subtype == "Light" or itemData.subtype == "NVG":
				newSlotData.condition = randi_range(lootSettings.min_condition, lootSettings.max_condition)

			if Simulation.season == 2:
				if newSlotData.itemData.freezable:
					if randi_range(0, 100) < 10:
						newSlotData.state = "Frozen"

			pickup.slotData = newSlotData
