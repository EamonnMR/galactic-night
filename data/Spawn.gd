extends DataRow

class_name SpawnData

var id: String
var count: int
var preset: bool
var natural: bool

var chance: float
var scene: PackedScene
var destination: String
var type: String
var data_type: String
var faction: String
var evergreen: bool
var distance: float
var spob_prefix: String
var use_markov: bool

var quadrants: Array[String]
var factions_adjacent: Array[String]
var factions_system: Array[String]
var factions_core: Array[String]

static func get_csv_path():
	return "res://data/spawns.csv"

func valid_for_quadrant(quadrant: String):
	if not quadrants or quadrants == []:
		return true
	return quadrant in quadrants

func do_spawns(rng: RandomNumberGenerator) -> Array[Node]:
	var instances: Array[Node] = []
	for i in range(count):
		if chance >= rng.randf():
			var position = Procgen.random_location_in_system(rng)
			var instance: Node
			if data_type != "":
				instance = Data.get(data_type)[type].scene.instantiate()
			else:
				instance = scene.instantiate()
			if type != null and type != "":
				instance.type = type
			if "faction" in instance:
				instance.faction = str(faction)
			if "spawn_id" in instance:
				instance.spawn_id = id
			instance.transform.origin = Util.raise_25d(position)
			instances.push_back(instance)
	return instances
