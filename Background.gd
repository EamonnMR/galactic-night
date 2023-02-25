extends TextureRect
#@export var MOVE_SCALE = Vector2(100, 75)
var MOVE_SCALE = Vector2(1,1)
var pos
var warp_factor = 0
var warp_angle = 0

func _process(delta):
	if not is_instance_valid(Client.player):
		return
	pos = -1 * Client.camera.unproject_position(Vector3(0,0,0))
	get_material().set_shader_parameter("position", pos)
	get_material().set_shader_parameter("warp_factor", warp_factor)
	get_material().set_shader_parameter("warp_vector", Vector2(1,0).rotated(1.5 * PI))
