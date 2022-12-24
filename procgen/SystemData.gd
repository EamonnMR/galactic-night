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
var entities: Dictionary

var distance: float
var distance_normalized: float

func serialize():
	
	var serialized = Util.default_serialize(self)
	serialized["position"] = [position.x, position.y]
	serialized["explored"] = int(explored)
	serialized["ambient_color"] = ambient_color.to_html(false)
	serialized["starlight_color"] = starlight_color.to_html(false)
	
	return serialized

func deserialize(data: Dictionary):
	id = data["id"]
	name = data["name"]
	position = Vector2(data["position"][0], data["position"][1])
	biome = data["biome"]
	links_cache = data["links_cache"]
	long_links_cache = data["long_links_cache"]
	state = data["state"]
	explored = bool(data["explored"])
	ambient_color = Color(data["color"])
	generation = data["generation"].to_int()
	core = data["core"]
	entities = data["entities"]

func deserialize_entities(world3D: Node3D):
	for destination_str in entities:
		var destination = world3D.get_child(destination_str)
		for serialized in entities[destination_str]:
			
