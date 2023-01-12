extends TextureRect
#@export var MOVE_SCALE = Vector2(100, 75)
var MOVE_SCALE = Vector2(1,1)

func _ready():
	Client.connect("camera_updated", self.derive_move_scale_from_camera)

func derive_move_scale_from_camera():
	MOVE_SCALE = Client.camera.unproject_position(
		Util.raise_25d(Vector2(1,1))
		) - Client.camera.unproject_position(
		Util.raise_25d(Vector2(0,0))
	)

func _physics_process(delta):
	if not is_instance_valid(Client.player):
		return
	get_material().set_shader_parameter("position",
		Util.flatten_25d(
			Client.player.global_transform.origin
		).rotated(
			-Client.camera.rotation.y - PI/2
		) * MOVE_SCALE
	)
