extends MeshInstance3D
@export var MOVE_SCALE = Vector2(0.05, 0.075)
#export var MOVE_SCALE = Vector2(1,1)

@onready var mat: ShaderMaterial = mesh.surface_get_material(0)
func _ready():
	var bgcolor = Client.current_biome().bg_color_shift
	mat.set_shader_parameter("color_shift", bgcolor)
func _process(delta):
	if not is_instance_valid(Client.player):
		return
	mat.set_shader_parameter("position",
		Util.flatten_25d(
			Client.player.global_transform.origin
		).rotated(
			-Client.camera.rotation.y - PI/2
		) * MOVE_SCALE
	)
