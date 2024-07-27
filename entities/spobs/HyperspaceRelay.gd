extends StaticBody3D

var type: String

var item_screen_box_side_length = 1000

var faction = "jumpstar"
var spob_name: String
var hypergate_links: Array
var spawn_id: String
var chain_spawns = ["gatebridge_npcs"]


func display_name():
	return spob_name
	
func display_type():
	return "Hyperspace Relay"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("radar-spobs")
	add_to_group("spobs")
	Util.clickable_spob(self)

const SERIAL_FIELDS = [
		"spob_name",
		"type",
		"hypergate_links",
		"scene_file_path",
		"spawn_id",
		"faction",
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
	get_tree().get_root().get_node("Main/UI/Map").assign_hypergate(hypergate_links)
	get_tree().get_root().get_node("Main/UI/").toggle_map()
