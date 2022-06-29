extends MeshInstance

func _process(delta):
	rotate_y(delta * 0.5)

	var xform = \
		Transform(global_transform.basis)\
		.rotated(Vector3(0,1,0), PI/4)\
		.rotated(Vector3(1,0,0), PI/4)

	get_surface_material(0).set_shader_param("xform", xform)
	get_surface_material(0).set_shader_param("inv_xform", xform.inverse())
