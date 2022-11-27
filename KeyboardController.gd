extends Controller

var skin_id = "0"

@onready var ui = get_tree().get_root().get_node("Main/UI/")
	
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
	toggle_inventory()
	check_jumped()

func _ready():
	Client.player = parent
	# toggle_map_hack_what_happened_to_visibility()

func toggle_map():
	if Input.is_action_just_released("toggle_map"):
		ui.toggle_map()
		
func toggle_inventory():
	if Input.is_action_just_released("toggle_inventory"):
		ui.toggle_inventory()

func cycle_skins():
	if Input.is_action_just_pressed("switch_color"):
		skin_id = str(
			(skin_id.to_int() + 1) % Data.skins.size()
		)
		var skin = Data.skins[skin_id]
		print(skin)
		get_node("../Graphics").set_skin_data(skin)
		
func check_jumped():
	if Input.is_action_just_released("jump"):
		jumping = true

#func _toggle_pause():
#  var pause_menu = Client.get_ui().get_node("PauseMenu")
#  if get_tree().paused:
#    pause_menu.hide()
#    get_tree().paused = false
#  else:
#    pause_menu.show()
#    get_tree().paused = true

#func _interact():
#  var entity = Client.player.get_node("InteractRange").top
#  if is_instance_valid(Client.player.get_node("InteractRange").top):
#    var interaction_modes = []
#    if entity.has_node("Inventory"):
#      Client.get_ui().get_node("OtherInventory").assign(entity.get_node("Inventory"), entity.name)
#      interaction_modes += ["Inventory", "OtherInventory"]
#    if entity.has_node("CraftingLevel"):
#      Client.get_ui().get_node("Crafting").assign(entity.get_node("CraftingLevel"))
#      interaction_modes += ["Crafting"]
#    _toggle_inventory(interaction_modes)

