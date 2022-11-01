extends Controller

var skin_id = "0"

@onready var map: Control = get_tree().get_root().get_node("World3D/Map")
	
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
	# toggle_map_hack_what_happened_to_visibility()

func toggle_map():
	if Input.is_action_just_released("toggle_map"):
		if map.visible:
			map.visible = false
			get_tree().pause = false
		else:
			map.visible = true
			get_tree().paused = true

func cycle_skins():
	if Input.is_action_just_pressed("switch_color"):
		skin_id = str(
			(skin_id.to_int() + 1) % Data.skins.size()
		)
		var skin = Data.skins[skin_id]
		print(skin)
		get_node("../Graphics").set_skin_data(skin)
