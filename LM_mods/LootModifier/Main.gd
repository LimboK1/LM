extends Node

var _lib = null
var container_handler = null
var simulation_handler = null

func _ready():
	# Create instances handlers

	container_handler = preload("res://LM_mods/LootModifier/LM_LootContainer.gd").new()
	simulation_handler = preload("res://LM_mods/LootModifier/LM_LootSimulation.gd").new()
	
	if Engine.has_meta("RTVModLib"):
		var lib = Engine.get_meta("RTVModLib")
		if lib._is_ready:
			_on_lib_ready()
		else:
			lib.frameworks_ready.connect(_on_lib_ready)

func _on_lib_ready():
	_lib = Engine.get_meta("RTVModLib")
	
	# Loot Container Hooks - runs code in LootContainer.gd
	_lib.hook("lootcontainer-generateloot-post", container_handler.on_container_generateloot)
	_lib.hook("lootcontainer-createloot-post", container_handler.on_container_createloot)
	_lib.hook("lootcontainer-_ready-post", container_handler.on_ready)
	
	# Loot Simulation Hooks - runs code in LootSimulation.gd
	_lib.hook("lootsimulation-generateloot", simulation_handler.on_simulation_generateloot)
	_lib.hook("lootsimulation-spawnitems", simulation_handler.on_simulation_spawnitems)
	
	print("LootModifier hooks registered!")
