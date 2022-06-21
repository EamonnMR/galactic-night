extends MeshInstance

func _process(delta):
	rotate_y(delta * 0.5)
	get_surface_material(0).set_shader_param("position", global_transform.origin)
