extends DataRow

class_name WeaponData

var id: String
var projectile_scene: PackedScene
var burst_count
var dupe_count
var spread: float
var world_projectile: bool  # Disable for beams or other things that should follow the player
var vary_pitch
var ammo_item: String
var primary

func apply_to_node(node):
	super.apply_to_node(node)
	node.weapon_name = id

static func get_csv_path():
	return "res://data/weapons.csv"
