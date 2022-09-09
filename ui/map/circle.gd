extends Node2D

func dat():
	return get_node("../").data

func _draw():
	#if Client.player.get_node("Controller").selected_system == get_node("../").system_id:
	#	draw_circle(Vector2(0,0), 9, Color(0,1,0))
	var color = Color(0.2, 0.2, 0.2)
	if dat().explored or Cheats.explore_all:
		color = Data.biomes[dat().biome].map_color
	draw_circle(Vector2(0,0), 7, color)
	draw_circle(Vector2(0,0), 5, Color(0,0,0))
	
	#if Client.current_system_id() == get_node("../").system_id:
	#	draw_circle(Vector2(0,0), 3, Color(0,1,0))
