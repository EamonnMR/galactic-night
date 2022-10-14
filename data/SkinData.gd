extends DataRow

class_name SkinData

var id: String
var name: String
var paint_hue: float
var paint_saturation: float
var paint_brightness: float
var base_brightness: float
var lights_hue: float
var lights_saturation: float
var lights_brightness: float
var weapon_hue: float
var weapon_saturation: float


func _init(data: Dictionary):
	init(data)

static func get_csv_path():
	return "res://data/skins.csv"

func apply_to_shader(shader):
	for column in get_columns():
		if column != "id" and column != "name":
			var val = get(column)
			shader.set_shader_parameter(column, get(column))
