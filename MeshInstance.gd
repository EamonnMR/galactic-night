tool
extends MeshInstance

export var offset = PI/4
export var ortho_cam_angle = PI/4
export var spin_aimlessly = true

var thrusting: bool = false
var weapons_glow: bool = false
var base_glow: bool = true

func _process(delta):
	if spin_aimlessly:
		rotate_y(delta * 0.5)
	
	var xform = \
		Transform(global_transform.basis)\
		.rotated(Vector3(0,1,0), offset)\
		.rotated(Vector3(1,0,0), ortho_cam_angle)

	get_surface_material(0).set_shader_param("xform", xform)
	get_surface_material(0).set_shader_param("inv_xform", xform.inverse())
	if thrusting:
		get_surface_material(0).set_shader_param("engine_emission_factor", 1.0)
	else:
		get_surface_material(0).set_shader_param("engine_emission_factor", 0)
