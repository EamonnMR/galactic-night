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

var distance: float
var distance_normalized: float

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

func deserialize_entities():
	for destination_str in entities:
		for serial_data in entities[destination_str]:
			Client.deserialize_entity(destination_str, serial_data)
