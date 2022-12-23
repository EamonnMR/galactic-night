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
var faction: int
var evergreen: bool

static func get_csv_path():
	return "res://data/spawns.csv"

func do_spawns(rng: RandomNumberGenerator) -> Array[Node]:
	var instances = Array[Node]
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
			instance.transform.origin = Util.raise_25d(position)
			instances.push_back(instance)
	return instances
