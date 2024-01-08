extends DataRow

class_name SkinData

var id: String
# Item info


var name: String
var ingredients: Dictionary
var icon: Texture2D
var desc: String
var require_level: int


# The actial skin
var paint_hue: float
var paint_saturation: float
var paint_brightness: float
var base_brightness: float
var lights_hue: float
var lights_saturation: float
var lights_brightness: float
var weapon_hue: float
var weapon_saturation: float

func _init(data):
	super._init(data)
	ingredients = parse_colon_dict_int_values(data["ingredients"])

static func get_csv_path():
	return "res://data/skins.csv"

func apply_to_shader(shader):
	# similar to apply_to_node, but different to merit a new func
	for column in get_columns():
		if column != "id" and column != "name":
			# TODO: Remove this if, ships shouldn't use any other shader types
			if shader.has_method("set_shader_parameter"):
				shader.set_shader_parameter(column, get(column))
