class_name SystemData

var id: String
var name: String
var position: Vector2
var biome: String
var links_cache: Array
var long_links_cache: Array
var state: Dictionary
var explored: bool
var ambient_color: Color
var starlight_color: Color
var faction: String
var core: bool
var generation: int
var longjump_enabled: bool
var entities: Dictionary
var adjacency: Array

var distance: float
var distance_normalized: float
var quadrant: String
var static_system_id: String

func serialize():
	var serialized = Util.default_serialize(self)
	serialized["id"] = id
	serialized["position"] = Util.serialize_vec(position)
	serialized["explored"] = int(explored)
	serialized["ambient_color"] = ambient_color.to_html(false)
	serialized["starlight_color"] = starlight_color.to_html(false)
	return serialized

func deserialize(data: Dictionary):
	id = data["id"]
	name = data["name"]
	position = Util.deserialize_vec(data["position"])
	biome = data["biome"]
	links_cache = data["links_cache"]
	long_links_cache = data["long_links_cache"]
	state = data["state"]
	explored = bool(data["explored"])
	ambient_color = Color(data["ambient_color"])
	generation = int(data["generation"])
	core = data["core"]
	entities = data["entities"]
	longjump_enabled = data["longjump_enabled"]
	quadrant = data["quadrant"]
	static_system_id = data["static_system_id"]
	faction = data["faction"]

func deserialize_entities():
	for destination_str in entities:
		for serial_data in entities[destination_str]:
			Client.deserialize_entity(destination_str, serial_data)

func dynamic_faction() -> String:
	# Rather than the designated faction, determine the faction based on the spobs in the system
	var possible_factions = {}
	if "spobs" in entities:
		for entity in entities.spobs:
			if "inhabited" in entity and "faction" in entity and entity.faction:
				possible_factions[entity.faction] = Data.factions[entity.faction]
			
			if possible_factions.size():
				var vals = possible_factions.values()
				vals.sort_custom(
					func faction_precedence_comparator(l, r):
						return l.precedence < r.precedence
				)
				return vals[0].id
	return ""
