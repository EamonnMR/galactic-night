extends TextureRect
@export var MOVE_SCALE = Vector2(100, 75)
#export var MOVE_SCALE = Vector2(1,1)
func _physics_process(delta):
	if not is_instance_valid(Client.player):
		return
	get_material().set_shader_parameter("position",
		Util.flatten_25d(
			Client.player.global_transform.origin
		).rotated(
			-Client.camera.rotation.y - PI/2
		) * MOVE_SCALE
	)
