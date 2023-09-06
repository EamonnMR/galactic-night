extends DataRow

class_name FactionData

var id: String
var name: String
var short: String
var color: Color
var initial_disposition: float
var core_systems_per_hundred: int
var systems_radius: int
var favor_galactic_center: int
var peninsula_bonus: bool
var allies: Array[String]
var enemies: Array[String]
var disposition_per_player: Dictionary
var destroy_penalty: float
var destroy_foe_bonus: float
var sys_name_scheme: String
var color_scheme: String
var skin: String
var spawns_system: Array[String]
var spawns_core: Array[String]
var spawns_adjacent: Array[String]
var quadrants: Array[String]

static func get_csv_path():
	return "res://data/factions.csv"

func get_player_disposition():
	if initial_disposition < 0:
		return Util.DISPOSITION.HOSTILE
	else:
		return Util.DISPOSITION.NEUTRAL
