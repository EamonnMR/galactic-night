extends StaticBody3D

func serialize() -> Dictionary:
	return Util.get_multiple(self, [
		"transform",
		"scene_file_path"
	])

func deserialize(data: Dictionary):
	Util.set_multiple(self, data)
