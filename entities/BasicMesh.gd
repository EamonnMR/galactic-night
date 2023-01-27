@tool
extends MeshInstance3D

@export var offset = PI/4
@export var ortho_cam_angle = PI/4

var material: Material

func _ready():
	material = mesh.surface_get_material(0).duplicate(true)
	set_surface_override_material(0, material)
	
func _process(delta):
	var xform = \
		Transform3D(global_transform.basis)\
		.rotated(Vector3(0,1,0), offset)\
		.rotated(Vector3(1,0,0), ortho_cam_angle)
	if material != null and material.has_method("set_shader_parameter"):
		material.set_shader_parameter("xform", xform)
		material.set_shader_parameter("inv_xform", xform.inverse())
