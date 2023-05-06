extends JumpAutopilotController

var warp_autopilot = false

@onready var ui = get_tree().get_root().get_node("Main/UI/")
	
func get_rotation_impulse() -> int:
	var dc = 0
	if Input.is_action_pressed("turn_left"):
		dc += 1
	if Input.is_action_pressed("turn_right"):
		dc -= 1
	return dc

func _physics_process(delta):
	
	toggle_pause()
	
	if warp_autopilot:
		process_warping_out(delta)
		return
	
	thrusting = Input.is_action_pressed("thrust")
	braking = Input.is_action_pressed("brake")
	shooting = Input.is_action_pressed("shoot")
	shooting_secondary = Input.is_action_pressed("shoot_secondary")
	rotation_impulse = get_rotation_impulse() * delta * parent.turn
	
	toggle_map()
	toggle_inventory()
	toggle_fire_mode()
	check_jumped()
	select_nearest_target()
	cycle_targets()
	interact()
	hyperspace()
	

func _ready():
	Client.set_player(parent)
	# toggle_map_hack_what_happened_to_visibility()

func toggle_map():
	if Input.is_action_just_released("toggle_map"):
		ui.toggle_map()
		
func toggle_inventory():
	if Input.is_action_just_released("toggle_inventory"):
		ui.toggle_inventory(["Inventory", "Crafting", "Equipment"])
		
func check_jumped():
	if Input.is_action_just_released("jump"):
		jumping = true

func select_nearest_target():
	if Input.is_action_just_pressed("target_nearest_hostile"):
		var hostile_ships = get_tree().get_nodes_in_group("npcs-hostile")
		if len(hostile_ships) == 0:
			return
		elif len(hostile_ships) == 1:
			Client.update_player_target_ship(hostile_ships[0])
		else:
			Client.update_player_target_ship(Util.closest(
				hostile_ships,
				Util.flatten_25d(parent.global_transform.origin)
			))
		
func cycle_targets():
	if Input.is_action_just_pressed("cycle_targets"):
		var all_ships = get_tree().get_nodes_in_group("npcs")
		var index = all_ships.find(Client.target_ship)
		var next_index = (index + 1) % all_ships.size()
		Client.update_player_target_ship(all_ships[next_index])

func interact():
	if Input.is_action_just_pressed("interact") and is_instance_valid(Client.player):
		Client.player.get_node("InteractionRange").interact()

func hyperspace():
	if Input.is_action_just_pressed("jump"):
		if warp_conditions_met():
			if Client.selected_system:
				if is_instance_valid(Client.player):
					warp_dest_system = Client.selected_system
					warp_autopilot = true
					parent.warping = true
			else:
				Client.display_message("No system selected - press 'm' and select a destination")
		else:
			Client.display_message("Cannot warp to hyperspace - move further from system center\n"
			+ "(Mass Lock: %s, Your distance: %s" % [Util.JUMP_DISTANCE, Util.flatten_25d(parent.position).length()])

func complete_jump():
	warp_autopilot = false
	if is_instance_valid(parent):
		parent.get_node("HyperspaceManager").start_hyperjump()

func toggle_pause():
	if Input.is_action_just_pressed("pause"):
		Client.toggle_pause()

func toggle_fire_mode():
	if Input.is_action_just_pressed("toggle_chain_fire"):
		parent.chain_fire_mode = not parent.chain_fire_mode
		Client.display_message("Fire Mode: " + ("chain fire" if parent.chain_fire_mode else "syncro"))
