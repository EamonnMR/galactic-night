extends StaticBody3D

var spob_name: String
var type: String
@export var spob_prefix: String
@export var is_planet = true


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("radar-spobs")
	add_to_group("spobs")

func serialize() -> Dictionary:
	return Util.get_multiple(self, [
		"spob_name",
		"type",
		"transform",
		"scene_file_path"
	])

func deserialize(data: Dictionary):
	Util.set_multiple(self, data)
