extends MeshInstance3D
@export var MOVE_SCALE = Vector2(100, 75)
#export var MOVE_SCALE = Vector2(1,1)
func _process(delta):
	if not is_instance_valid(Client.player):
		return
	#var mat: StandardMaterial3D = mesh.surface_get_material(0)
	#mat.uv1_offset = Vector3(int(delta*10000)%100, int(delta*10000)%100, int(delta*10000)%100)
	#get_material().set_shader_parameter("position",
	#	Util.flatten_25d(
	#		Client.player.global_transform.origin
	#	).rotated(
	#		-Client.camera.rotation.y - PI/2
	#	) * MOVE_SCALE
	#)
