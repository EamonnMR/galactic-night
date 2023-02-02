extends DataRow

class_name ShipData

var name: String
var subtitle: String
var max_speed: float
var accel: float
var turn: float
var max_bank: int
var bank_speed: float
var scene: PackedScene
var weapon_config: Dictionary

func _init(data):
	super._init(data)
	weapon_config = parse_colon_dict_string_values(data["weapon_config"])

func apply_to_node(node):
	super.apply_to_node(node)
	node.max_bank = deg_to_rad(max_bank)
	node.bank_speed = bank_speed / turn

static func get_csv_path():
	return "res://data/ships.csv"
