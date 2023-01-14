extends TextureRect
#@export var MOVE_SCALE = Vector2(100, 75)
var MOVE_SCALE = Vector2(1,1)
var pos

func _process(delta):
	if not is_instance_valid(Client.player):
		return
	pos = -1 * Client.camera.unproject_position(Vector3(0,0,0))
	get_material().set_shader_parameter("position", pos)
