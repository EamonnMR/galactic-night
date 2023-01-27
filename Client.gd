extends Node

@export var seed: int = 0
var player
var camera
signal system_selection_updated
signal camera_updated
signal player_ship_updated
@onready var current_system = Procgen.generate_systems(seed)
var selected_system = null
var selected_system_circle_cache = []

@onready var ui_inventory = get_tree().get_root().get_node("Main/UI/Inventory")

func set_player(player):
	self.player = player
	emit_signal("player_ship_updated")
	

func set_camera(camera: Camera3D):
	self.camera = camera
	emit_signal("camera_updated")

func _ready():
	var ship_type = "nimbus"
	player = Data.ships[ship_type].scene.instantiate()
	player.type = ship_type

func current_system_id():
	return current_system

func map_select_system(system_id, system_node):
	sel_sys(system_id, system_node)
	emit_signal("system_selection_updated")

func sel_sys(system_id: String, node):
	selected_system = system_id
	for old_node in selected_system_circle_cache:
		old_node.redraw()
	selected_system_circle_cache = [node]
	# TODO: If we're in immediate jump mode, toggle out of the map and initiate a jump

func change_system():
	current_system = selected_system
	selected_system = null
	get_main().change_system()

func get_world():
	return get_main().get_node("World3D")

func get_main():
	return get_tree().get_root().get_node("Main")

func switch_ship(new_type: String):
	var old_ship = player
	var old_inventory = player.get_node("Inventory")
	old_ship.remove_child(old_inventory)
	var position = player.global_transform
	
	player = Data.ships[new_type].scene.instantiate()
	player.type = new_type
	
	player.remove_child(player.get_node("Inventory"))
	player.add_child(old_inventory)
	
	player.global_transform = position
	
	var parent = old_ship.get_node("../")
	parent.remove_child(old_ship)
	parent.add_child(player)
	
func current_biome() -> BiomeData:
	if current_system in Procgen.systems:
		return Data.biomes[Procgen.systems[current_system].biome]
	else:
		return BiomeData.new({})

func deserialize_entity(destination_path, serial_data):
	var destination = get_world().get_node(destination_path)
	var entity = load(serial_data["scene_file_path"]).instantiate() # TODO: Explicitly list allowed nodes and cache them at load time.
	entity.deserialize(serial_data)
	# object.name = serial_data["name"] # TODO: We want to deal with names/IDs for networked play
	destination.add_child(entity)
