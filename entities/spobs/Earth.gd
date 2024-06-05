extends StaticBody3D

var spob_name: String
var type: String

var item_screen_box_side_length = 100

@export var s2pob_prefix: String
@export var is_planet = true
@export var inhabited = false
@export var center = true
@export var available_items = {}
@export var faction: String
var spawn_id: String

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
	Util.clickable_spob(self)

const SERIAL_FIELDS = [
		"faction",
		"spob_name",
		"type",
		"scene_file_path",
		"available_items",
		"inhabited",
		"spawn_id",
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
	if inhabited:
		get_tree().get_root().get_node("Main/UI/InhabitedSpob").assign(self)
		get_tree().get_root().get_node("Main/UI/").toggle_inventory(["Inventory", "Money", "InhabitedSpob"])
