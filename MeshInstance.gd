extends MeshInstance

export var camera_distance: float = 4.0
export var camera_angle = Vector3(-1,1,1)

func _process(delta):
	rotate_y(delta * 0.5)
	var local_cam_pos = to_local(global_transform.origin + camera_angle * camera_distance)
	get_surface_material(0).set_shader_param("camera_position", local_cam_pos)
