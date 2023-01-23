extends DataRow

class_name SpobData

var id: String
var texture: Texture2D
var radius: int
var offset: Vector2
var type_name: String

static func get_csv_path():
	return "res://data/spobs.csv"
