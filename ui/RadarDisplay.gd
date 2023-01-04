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
	
func _process(delta):
	queue_redraw()

func _get_color(node: Node):
	return DISPOSITION_COLORS["player"]

func _get_size(node: Node):
	if node.name == "Spob":
		return 5
	return 2

func _draw():
	if is_instance_valid(Client.player):
		var player_position = Util.flatten_25d(Client.player.global_transform.origin)
		for blip in get_tree().get_nodes_in_group("radar"):
			#draw_circle(_relative_position(blip, player_position), size, _get_color(blip))
			draw_circle(_relative_position(blip, player_position), _get_size(blip), _get_color(blip))
