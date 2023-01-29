extends StaticBody3D

func _ready():
	add_to_group("radar-spobs")
	add_to_group("player-assets")

func serialize() -> Dictionary:
	return Util.get_multiple(self, [
		"transform",
		"scene_file_path"
	])

func deserialize(data: Dictionary):
	Util.set_multiple(self, data)
