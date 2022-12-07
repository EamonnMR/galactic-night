extends DataRow

class_name SpawnData

var id: String
var count: int
var respawn: bool
var chance: float
var scene: PackedScene
var destination: String
var type: String
var data_type: String
var faction: int
var evergreen: bool

static func get_csv_path():
	return "res://data/spawns.csv"
