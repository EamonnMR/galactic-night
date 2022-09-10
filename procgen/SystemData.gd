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

var distance: float
var distance_normalized: float

func serialize():
	return {
		"id": id,
		"name": name,
		"position": [position.x, position.y],
		"biome": biome,
		"links_cache": links_cache,
		"long_links_cache": long_links_cache,
		"state": state,
		"explored": int(explored),
		"ambient_color": ambient_color.to_html(false),
		"starlight_color": starlight_color.to_html(false)
	}

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
