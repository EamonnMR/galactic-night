extends Node3D

var spob_name: String
@export var spob_prefix: String

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("radar")

func serialize() -> Dictionary:
	return Util.get_multiple(self, [
		"spob_name",
		"transform",
		"scene_file_path"
	])

func deserialize(data: Dictionary):
	Util.set_multiple(self, data)
