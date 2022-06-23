extends MeshInstance

export var camera_distance: float = 4.0
export var camera_angle = Vector3(-1,1,1)

func _process(delta):
	rotate_y(delta * 0.5)
	var xform = Transform(global_transform.basis)

	get_surface_material(0).set_shader_param("xform", xform)
	get_surface_material(0).set_shader_param("inv_xform", xform.inverse())
