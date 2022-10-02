extends Controller

var skin_id = "0"

	
func get_rotation_impulse() -> int:
	var dc = 0
	if Input.is_action_pressed("turn_left"):
		dc += 1
	if Input.is_action_pressed("turn_right"):
		dc -= 1
	return dc

func _physics_process(delta):
	thrusting = Input.is_action_pressed("thrust")
	shooting = Input.is_action_pressed("shoot")
	rotation_impulse = get_rotation_impulse() * delta * parent.turn
	cycle_skins()
	toggle_map()

func _ready():
	Client.player = parent

func toggle_map():
	if Input.is_action_just_released("toggle_map"):
		var map = get_tree().get_root().get_node("Node/Map")
		map.visible = not map.visible

func cycle_skins():
	if Input.is_action_just_pressed("switch_color"):
		skin_id = str(
			(int(skin_id) + 1) % Data.skins.size()
		)
		var skin = Data.skins[skin_id]
		print(skin)
		get_node("../Graphics").set_skin_data(skin)
