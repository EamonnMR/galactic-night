extends MeshInstance

func _ready():
	get_surface_material(0).set_shader_param("position", global_transform.origin)
