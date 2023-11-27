extends DataRow

class_name WeaponData

var id: String
var scene: PackedScene
var projectile_scene: PackedScene
var burst_count: int
var dupe_count: int
var spread: float
var world_projectile: bool  # Disable for beams or other things that should follow the player
var vary_pitch: int
var ammo_item: String
var primary: bool
var projectile_velocity: float
var damage: int
var cooldown: float
var projectile_lifetime: float
var splash_damage: int
var splash_radius: float
var timeout: float
var explode_on_timeout: bool
var damage_falloff: bool
var fade: bool

func apply_to_node(node):
	super.apply_to_node(node)
	node.weapon_name = id
	node.get_node("Cooldown").wait_time = cooldown

static func get_csv_path():
	return "res://data/weapons.csv"

static func instantiate(type):
	var instance = Data.weapons[type].scene.instantiate()
	instance.type = type
	instance.primary = Data.weapons[type].primary
	return instance
