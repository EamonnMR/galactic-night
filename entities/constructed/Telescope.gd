extends StaticBody3D

var is_planet = false
var is_populated = true
var spob_name = display_name()

func screen_box_side_length():
	return 400

func display_name():
	return "Telescope"
	
func display_type():
	return "Station"

func _ready():
	add_to_group("radar-spobs")
	add_to_group("player-assets")
	Util.clickable_spob(self)
	Procgen.systems[Client.current_system].longjump_enabled = true
	Client.get_ui().get_node("Map").update_for_explore(Client.current_system)

func serialize() -> Dictionary:
	return Util.get_multiple(self, [
		"transform",
		"scene_file_path",
		"spob_name"
	])

func deserialize(data: Dictionary):
	Util.set_multiple(self, data)

func spob_interact():
	get_tree().get_root().get_node("Main/UI/Crafting").assign(self)
	get_tree().get_root().get_node("Main/UI/").toggle_inventory(["Inventory", "Crafting"])

func crafting_level() -> int:
	return 3
