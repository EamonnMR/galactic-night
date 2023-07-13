extends DataRow

class_name StaticSystem

var id: String
var name: String
var spawns: Array[String]
var quadrants: Array[String]
var startloc: bool
var fixed_name: String
var biome: String
var faction_id: String
var auto_explore: bool

static func get_csv_path():
	return "res://data/static_systems.csv"
