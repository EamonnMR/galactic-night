extends Node

@export var seed: int = 0
var player
var camera
signal system_selection_updated
signal camera_updated
signal player_ship_updated
signal ship_target_updated
signal spob_target_updated
signal mouseover_updated
signal exited_system
signal money_updated
signal message(message)
signal selected_system_updated
var current_system

var selected_system = null
var selected_system_circle_cache = []

var target_ship: Spaceship
var target_spob
var mouseover
var mouseover_via_mouse = false

var money = 10

func has_money(price):
	return money >= price
	
func deduct_money(price):
	money -= price
	money_updated.emit()

func add_money(amount):
	money += amount
	money_updated.emit()

@onready var ui_inventory = get_tree().get_root().get_node("Main/UI/Inventory")

func set_player(player):
	self.player = player
	emit_signal("player_ship_updated")
	

func set_camera(camera: Camera3D):
	self.camera = camera
	emit_signal("camera_updated")

func enter_system():
	var ship_type = "nimbus"
	player = Data.ships[ship_type].scene.instantiate()
	player.type = ship_type
	
	get_main().enter_system(current_system_id())

func current_system_id():
	return current_system

func map_select_system(system_id, system_node):
	sel_sys(system_id, system_node)
	emit_signal("system_selection_updated")

func sel_sys(system_id, node):
	selected_system = system_id
	for old_node in selected_system_circle_cache:
		old_node.redraw()
	if system_id:
		selected_system_circle_cache = [node]
	else:
		selected_system_circle_cache = []
	selected_system_updated.emit()
	# TODO: If we're in immediate jump mode, toggle out of the map and initiate a jump

func valid_jump_destination_selected():
	return selected_system != current_system and selected_system != null

func change_system():
	var old_system = current_system
	current_system = selected_system
	sel_sys(null, null)
	exited_system.emit()
	get_main().change_system(old_system, current_system)
	display_message("Entering the %s system" % Procgen.systems[current_system].name)

func get_world():
	return get_main().get_node("World3D")

func get_ui():
	return get_main().get_node("UI")

func get_main():
	return get_tree().get_root().get_node("Main")

func get_background():
	return get_main().get_node("background/Background")
	
func get_foreground():
	return get_main().get_node("foreground/Foreground")

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

func update_player_target_ship(new_target):
	target_ship = new_target
	ship_target_updated.emit()
	
func update_player_target_spob(new_target):
	target_spob = new_target
	spob_target_updated.emit()
	
	
func mouseover_entered(target, mouse=true):
	mouseover = target
	mouseover_updated.emit()
	mouseover_via_mouse = mouse


func get_disposition(node):
	if node.is_in_group("players") or node.is_in_group("player-assets"):
		return Util.DISPOSITION.FRIENDLY
	if "faction" in node:
		if node.faction:
			return Data.factions[node.faction].get_player_disposition()
	else:
		return Util.DISPOSITION.ABANDONED

func display_message(msg: String):
	message.emit(msg)

const SAVE_FILE = "user://bla.json"

func save_game():
	var save_game = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	
	save_game.store_line(JSON.stringify(serialize()))
	save_game.close()

func load_game():
	var file: FileAccess = FileAccess.open(SAVE_FILE, FileAccess.READ)
	var text = file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(text)

	if not parse_result == OK:
		var error = "JSON Parse Error: %s at line %s" % [json.get_error_message(), json.get_error_line()]
		breakpoint
	deserialize(json.get_data())

func new_game():
	current_system = Procgen.generate_systems(seed)
	
func enter_game():
	get_main().get_node("MainMenu").hide()
	enter_system()
	get_ui().show()
	get_ui().new_map()
	get_main().enter_system(current_system_id())
	
func leave_game():
	get_main().get_node("MainMenu").show()
	get_ui().hide()

func toggle_pause():
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		get_main().get_node("MainMenu").show()
	else:
		get_main().get_node("MainMenu").hide()

const CONSERVED_PROPS = [
	"money",
	"current_system"
]

func serialize():
	var data = Util.get_multiple(self, CONSERVED_PROPS)
	
	data["procgen"] = Procgen.serialize()
	
	return data

func deserialize(data):
	Util.set_multiple_only(self, data, CONSERVED_PROPS)
	
	Procgen.deserialize(data["procgen"])
