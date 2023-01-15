extends Sprite2D

var parent: Node3D


func _process(delta):
	#var background = get_node("../../Background")
	#if background:
	#	position = -1 * background.pos / 10
	position = Client.camera.unproject_position(parent.global_position)
