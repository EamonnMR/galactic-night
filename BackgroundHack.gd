extends MeshInstance3D
@export var MOVE_SCALE = Vector2(0.05, 0.075)
#export var MOVE_SCALE = Vector2(1,1)
func _process(delta):
	if not is_instance_valid(Client.player):
		return
	var mat: ShaderMaterial = mesh.surface_get_material(0)
	mat.set_shader_parameter("position",
		Util.flatten_25d(
			Client.player.global_transform.origin
		).rotated(
			-Client.camera.rotation.y - PI/2
		) * MOVE_SCALE
	)
