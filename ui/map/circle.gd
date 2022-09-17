extends Node2D

onready var map = get_node("../../../../../../../")


func dat():
	return get_node("../").data

func _draw():
	if Client.selected_system == get_node("../").system_id:
		draw_circle(Vector2(0,0), 9, Color(0,1,0))
	var color = Color(0.2, 0.2, 0.2)
	if dat().explored or Cheats.explore_all:
		color = get_color()
	draw_circle(Vector2(0,0), 7, color)
	draw_circle(Vector2(0,0), 5, Color(0,0,0))
	
	if Client.current_system_id() == get_node("../").system_id:
		draw_circle(Vector2(0,0), 3, Color(0,1,0))

var DISPOSITION_COLORS = {
	"hostile": Color(1,0,0),
	"neutral": Color(0,0,1),
	"friendly": Color(0,1,0),
	"abandoned": Color(0.6, 0.6, 0.6)
}

func get_color():
	var mode = map.mode.selected
	#"Biome",
	#"Disposition",
	#"Distance from core",
	#"Political",
	if mode == 0:
		return Data.biomes[dat()["biome"]].map_color
	if mode == 1:
		var data = dat()
		if data.faction:
			var faction = Data.factions[dat()["faction"]]
			var disposition = faction["initial_disposition"]
			if disposition < 0:
				return DISPOSITION_COLORS["hostile"]
			elif disposition > 0:
				return DISPOSITION_COLORS["friendly"]
			else:
				return DISPOSITION_COLORS["neutral"]
		else:
			return DISPOSITION_COLORS["abandoned"]
	if mode == 2:
		var distance = dat()["distance_normalized"]
		var brightness = 1 - ((distance * 0.9) + 0.1)
		return Color(brightness, brightness, brightness)
	if mode == 3:
		var data = dat()
		if data.faction:
			var color = Data.factions[dat()["faction"]].color
			#var divisor = dat().get("grow_generation", 0) + 1
			var divisor = 1
			return color / divisor
		else:
			return DISPOSITION_COLORS["abandoned"]
	if mode == 4:
		var data = dat()
		if data.core:
			return DISPOSITION_COLORS["friendly"]
		else:
			return DISPOSITION_COLORS["abandoned"]

	return DISPOSITION_COLORS["abandoned"]
