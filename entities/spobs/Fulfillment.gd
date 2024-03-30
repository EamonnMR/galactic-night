extends StaticBody3D

var type: String
var spob_name: String
var spob_prefix: String

var item_screen_box_side_length = 200

var faction = "autofac"
var spawn_id: String

var holds = true

signal destroyed

func display_name():
	return spob_name
	
func display_type():
	return "Station"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("radar-spobs")
	add_to_group("spobs")
	Util.clickable_spob(self)

const SERIAL_FIELDS = [
		"spob_name",
		"scene_file_path",
		"spawn_id",
		"position",
		"faction",
		"hold",
	]

func serialize() -> Dictionary:
	var data =  Util.get_multiple(self, SERIAL_FIELDS)
	data["transform"] = Util.serialize_vec(Util.flatten_25d(transform.origin))
	return data

func deserialize(data: Dictionary):
	Util.set_multiple_only(self, data, SERIAL_FIELDS)
	transform.origin = Util.raise_25d(Util.deserialize_vec(data["transform"]))

func _on_health_destroyed():
	destroyed.emit()
	queue_free()
