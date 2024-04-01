extends DataRow

class_name ShipData
var id: String
var name: String
var subtitle: String
var max_speed: float
var accel: float
var turn: float
var max_bank: int
var inventory_max_items: int
var bank_speed: float
var engagement_range: float
var screen_box_side_length: int
var scene: PackedScene
var weapon_config: Dictionary
var armor: int
var shields: int
var shield_regen: float
var shield_regen_delay: float
var standoff: bool
var ingredients: Dictionary
var icon: Texture2D
var desc: String
var require_level: int
var loot: Dictionary
var make: String
var mass: float
var price: int
var techbase: String

func derive_codex_path():
	return "ships/" + make + "/" + id

func _init(data):
	super._init(data)
	weapon_config = parse_colon_dict_string_values(data["weapon_config"])
	ingredients = parse_colon_dict_int_values(data["ingredients"])
	loot = parse_colon_dict_int_values(data["ingredients"])

func apply_to_node(node):
	super.apply_to_node(node)
	node.max_bank = deg_to_rad(max_bank)
	node.bank_speed = bank_speed / turn
	node.get_node("Health").set_max_health(armor, shields)
	node.get_node("Health").set_shield_regen(shield_regen, shield_regen_delay)
	node.get_node("Loot").loot_items = loot
	node.get_node("Inventory").max_items = inventory_max_items

static func get_csv_path():
	return "res://data/ships.csv"
