extends Node2D

var radar_scale = 2

# TODO: Don't hardcode this
@onready var radar_offset = Vector2(119, 119)

@onready var radar_rotate = PI + Util.flatten_25d(Client.camera.global_position).angle()

var DISPOSITION_COLORS = {
		"hostile": Color(1,0,0),
		"neutral": Color(1,1,0),
		"abandoned": Color(0.5, 0.5, 0.5),
		"player": Color(1,1,1),
		"asteroid": Color(0.5, 0.25, 0)
}

func _relative_position(subject: Node3D, player_position: Vector2) -> Vector2:
	var relative_position: Vector2 = (Util.flatten_25d(subject.global_transform.origin) - player_position) * radar_scale
	relative_position = relative_position.rotated(radar_rotate)
	return relative_position.limit_length((radar_offset.x - 5))
	
func _process(_delta):
	queue_redraw()

func _get_color(node: Node):
	# TODO: if IFF decoder type upgrade is installed
	if node.is_in_group("players") or node.is_in_group("player-assets"):
		return DISPOSITION_COLORS["player"]
	if "faction" in node:
		if node.faction:
			return DISPOSITION_COLORS[
				Data.factions[node.faction].get_player_disposition()
			]
	else:
		return DISPOSITION_COLORS["abandoned"]

func _get_ship_size(node: Node):
	if node.name == "Spob":
		return 5
	return 2

func _draw():
	if is_instance_valid(Client.player) and Client.player.is_inside_tree():
		var player_position = Util.flatten_25d(Client.player.global_transform.origin)
		for spob_blip in get_tree().get_nodes_in_group("radar-spobs"):
			draw_circle(_relative_position(spob_blip, player_position), 5, _get_color(spob_blip))
		for blip in get_tree().get_nodes_in_group("radar"):
			#draw_circle(_relative_position(blip, player_position), size, _get_color(blip))
			draw_circle(_relative_position(blip, player_position), _get_ship_size(blip), _get_color(blip))
