extends Controller

var skin_id = "0"

func is_shooting() -> bool:
	return Input.is_action_pressed("shoot")
	
func is_thrusting() -> bool:
	return Input.is_action_pressed("thrust")
	
func rotation_impulse() -> int:
	var dc = 0
	if Input.is_action_pressed("turn_left"):
		dc += 1
	if Input.is_action_pressed("turn_right"):
		dc -= 1
	return dc

func _process(delta):
	cycle_skins()

func _ready():
	return
	get_node("../Graphics").set_skin_data(Data.skins[skin_id])

func cycle_skins():
	if Input.is_action_just_pressed("switch_color"):
		skin_id = str(
			(int(skin_id) + 1) % Data.skins.size()
		)
		var skin = Data.skins[skin_id]
		print(skin)
		get_node("../Graphics").set_skin_data(skin)
