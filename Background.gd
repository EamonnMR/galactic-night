extends TextureRect
export var MOVE_SCALE = 0.11111111
func _physics_process(delta):
	get_material().set_shader_param("position",
		Util.flatten_25d(
			Client.player.global_transform.origin
		).rotated(
			-Client.camera.rotation.y - PI/2
		) * MOVE_SCALE
		)
