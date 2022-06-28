extends MeshInstance

export var camera_distance: float = 4.0
export var camera_position = Vector3(-1,1,1)

func _process(delta):
	rotate_y(delta * 0.5)
	
	var offset = Transform().rotated(Vector3(0,1,0), 0)
	var inv_offset = offset.inverse()
	var cam_xform = Transform(get_viewport().get_camera().global_transform.basis)
	var xform = Transform(global_transform.basis)
	get_surface_material(0).set_shader_param("xform", xform)
	get_surface_material(0).set_shader_param("inv_xform", xform.inverse())

	get_surface_material(0).set_shader_param("cam_xform", cam_xform)
	get_surface_material(0).set_shader_param("inv_cam_xform", cam_xform.inverse())

	get_surface_material(0).set_shader_param("offset", offset)
	get_surface_material(0).set_shader_param("inv_offset", offset.inverse())
