extends DataRow

class_name SpawnData

var id: String
var count: int
var respawn: bool
var chance: float
var scene: PackedScene
var destination: String
var type: String

func _init(data: Dictionary):
	init(data)

static func get_csv_path():
	return "res://data/spawns.csv"
