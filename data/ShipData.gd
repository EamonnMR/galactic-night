extends DataRow

class_name ShipData

var max_speed: float
var accel: float
var turn: float
var max_bank: int
var bank_speed: float
var scene: PackedScene

func apply_to_node(node):
	super.apply_to_node(node)
	node.max_bank = deg_to_rad(max_bank)
	node.bank_speed = bank_speed / turn

static func get_csv_path():
	return "res://data/ships.csv"
