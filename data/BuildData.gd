extends DataRow

class_name BuildData

var id: String
var name: String
var scene: PackedScene
var destination: String
var require_level: int
var ingredients: Dictionary
var icon: Texture2D
var text: String

func _init(data: Dictionary):
	super._init(data)
	ingredients = parse_colon_dict_int_values(data["ingredients"])

static func get_csv_path():
	return "res://data/build.csv"

func derive_codex_path():
	return "stations/" + id
