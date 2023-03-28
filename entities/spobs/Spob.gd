extends StaticBody3D

var spob_name: String
var type: String

var item_screen_box_side_length = 100

@export var spob_prefix: String
@export var is_planet = true
@export var inhabited = true
@export var center = true
@export var available_items = {}

func display_name():
	return spob_name
	
func display_type():
	if is_planet:
		return "Planet - " + type
	else:
		return "Station"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("radar-spobs")
	add_to_group("spobs")
	input_event.connect(
		func _on_input_event(_camera, event, _click_position, _camera_normal, _shape):
			#https://stackoverflow.com/questions/58628154/detecting-click-touchscreen-input-on-a-3d-object-inside-godot
			var mouse_click = event as InputEventMouseButton
			if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed:
				Client.update_player_target_spob(self)
			else:
				Client.mouseover_entered(self)
	)

const SERIAL_FIELDS = [
		"spob_name",
		"type",
		"scene_file_path",
		"available_items",
		"inhabited"
	]

func serialize() -> Dictionary:
	var data =  Util.get_multiple(self, SERIAL_FIELDS)
	
	data["transform"] = Util.serialize_vec(Util.flatten_25d(transform.origin))
	return data

func deserialize(data: Dictionary):
	Util.set_multiple_only(self, data, SERIAL_FIELDS)
	#for key in data.available_items.keys():
	#	available_items[key] = ItemData.CommodityPrice(available_items[key])
	transform.origin = Util.raise_25d(Util.deserialize_vec(data["transform"]))

func spob_interact():
	get_tree().get_root().get_node("Main/UI/InhabitedSpob").assign(self)
	get_tree().get_root().get_node("Main/UI/").toggle_inventory(["Inventory", "Money", "InhabitedSpob"])
