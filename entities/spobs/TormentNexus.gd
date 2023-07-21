extends StaticBody3D

var spob_name: String
var type: String

var item_screen_box_side_length = 200

var faction = 3

func display_name():
	return "The Torment Nexus"
	
func display_type():
	return "Station"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("radar-spobs")
	add_to_group("spobs")
	Util.clickable_spob(self)

func serialize() -> Dictionary:
	var data = {}
	data["transform"] = Util.serialize_vec(Util.flatten_25d(transform.origin))
	return data

func deserialize(data: Dictionary):
	transform.origin = Util.raise_25d(Util.deserialize_vec(data["transform"]))

func _on_health_destroyed():
	Client.display_message("Congradulations! You have destroyed the torment nexus and defeated iLisk")
