extends TextureRect

func _physics_process(delta):
	get_material().set_shader_param("position", Util.flatten_25d(Client.player.global_transform.origin))
