extends DataRow

class_name SpawnData

var id: String
var count: int
var preset: bool
var natural: bool

var chance: float
var scene: PackedScene
var destination: String
var types: Array[String]
var data_type: String
var faction: String
var evergreen: bool
var distance: float
var spob_prefix: String
var use_markov: bool
var always_use_spob_prefix: bool

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
				var type = Procgen.random_select(types, rng)
				instance = Data.get(data_type)[type].scene.instantiate()
				instance.type = type
			else:
				instance = scene.instantiate()
			if "faction" in instance:
				instance.faction = str(faction)
			if "spawn_id" in instance:
				instance.spawn_id = id
			instance.transform.origin = Util.raise_25d(position)
			instances.push_back(instance)
	return instances

func denormalize_to_factions(data):
	for sources_destination in [
		["factions_core", "spawns_core"],
		["factions_system", "spawns_system"],
		["factions_adjacent", "spawns_adjacent"]
	]:
		var sources = get(sources_destination[0])
		var destination = sources_destination[1]
		for faction in sources:
			data.factions[faction][destination].append(id)
