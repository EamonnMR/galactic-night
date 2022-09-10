extends DataRow

class_name FactionData

var id: int
var name: String
var short: String
var color: Color
var initial_disposition: float
var is_default: bool
var core_systems_per_500: int
var systems_radius: int
var npc_radius: int
var spawn_anywhere: bool
var host_spawn_anywhere: bool
var favor_galactic_center: int
var peninsula_bonus: bool
var allies: Array
var enemies: Array
var disposition_per_player: Dictionary
var destroy_penalty: float
var destroy_foe_bonus: float

func _init(data: Dictionary):
	init(data)
	for field in ["allies", "enemies"]:
		set(field, parse_int_array(data[field]))
