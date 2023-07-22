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
	get_material().set_shader_parameter("warp_angle", (PI / 2) -(warp_angle + (PI / 4.0)))
	
func set_textures(foreground: Texture2D, background: Texture2D):
	texture = background
	get_material().set_shader_parameter("nebula", foreground)
	
