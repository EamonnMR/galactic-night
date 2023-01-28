extends DataRow

class_name BiomeData

var id: String
var name: String
var spawns: Array[String]
var map_color: Color
var do_seed: bool
var grow: bool
# var background: Texture2D
var bg_color_shift: float
var always_do_one: bool
var startloc: bool
var fixed_name: String
var auto_explore: bool
var ambient_color: Color
var starlight_color: Color

static func get_csv_path():
	return "res://data/biomes.csv"
