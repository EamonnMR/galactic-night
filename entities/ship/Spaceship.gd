extends CharacterBody3D

class_name Spaceship

var faction
var type: String

var max_speed = 100
var accel = 0.01
var turn = 1
var max_bank = deg_to_rad(15)
var bank_speed = 2.5 / turn
var screen_box_side_length: int

var linear_velocity = Vector2()
var primary_weapons = []
var secondary_weapons = []


signal destroyed

func _ready():
	Data.ships[type].apply_to_node(self)
	# TODO: Better way to determine if it's the player
	add_to_group("radar")
	add_to_group("ships")
	
	if self == Client.player:
		add_to_group("players")
		# TODO: Check client for proper controller type?
		add_child(preload("res://component/controllers/KeyboardController.tscn").instantiate())
		$CameraFollower.remote_path = Client.camera.get_node("../").get_path()
		Client.ui_inventory.assign($Inventory, "Your inventory")
	else:
		input_event.connect(_on_input_event_npc)
		add_to_group("faction-" + faction)
		add_to_group("npcs")
		# TODO: Select AI type?
		add_child(preload("res://component/controllers/ai/AIController.tscn").instantiate())
		$Graphics.set_skin_data(Data.skins[Data.factions[faction].skin])
		var weapon_config = Data.ships[type].weapon_config
		for weapon_slot in weapon_config:
			get_node(weapon_slot).add_weapon(WeaponData.instantiate(weapon_config[weapon_slot]))
		
func get_weapon_slots() -> Array[WeaponSlot]:
	var weapon_slots = []
	for weapon_slot in get_children():
		if weapon_slot is WeaponSlot:
			weapon_slots.push_back(weapon_slot)
	return weapon_slots

func _physics_process(delta):
	linear_velocity = get_limited_velocity_with_thrust(delta)
	var rotation_impulse = $Controller.rotation_impulse
	rotation.y += rotation_impulse
	if rotation_impulse:
		increase_bank(rotation_impulse)
	else:
		decrease_bank(delta)
	
# warning-ignore:return_value_discarded
	set_velocity(Util.raise_25d(linear_velocity))
	move_and_slide()
	handle_shooting()
	handle_jumping()
	Util.wrap_to_play_radius(self)

func handle_shooting():
	if $Controller.shooting:
		for weapon in primary_weapons:
			weapon.try_shoot()

	if $Controller.shooting_secondary:
		for weapon in secondary_weapons:
			weapon.try_shoot()

func get_limited_velocity_with_thrust(delta):
	if $Controller.thrusting:
		linear_velocity += Vector2(accel * delta * 100, 0).rotated(-rotation.y)
		$Graphics.thrusting = true
	else:
		$Graphics.thrusting = false
	if $Controller.braking:
		linear_velocity = Vector2(linear_velocity.length() - (accel * delta * 100), 0).rotated(linear_velocity.angle())
	if linear_velocity.length() > max_speed:
		return Vector2(max_speed, 0).rotated(linear_velocity.angle())
	else:
		return linear_velocity

func flash_weapon():
	$Graphics.flash_weapon()

func increase_bank(rotation_impulse):
	$Graphics.rotation.x += rotation_impulse * bank_speed
	$Graphics.rotation.x = clamp(
		$Graphics.rotation.x,
		-max_bank,
		max_bank
	)

func decrease_bank(delta):
	if $Graphics.rotation.x != 0.0:
		var sgn = sign($Graphics.rotation.x)
		$Graphics.rotation.x -= sgn * bank_speed * delta
		if sign($Graphics.rotation.x) != sgn:
			$Graphics.rotation.x = 0
	
func handle_jumping():
	if $Controller.jumping:
		$Controller.jumping = false
		if Client.selected_system:
			Client.change_system()
			#_jump_effects()
			#queue_free()
		else:
			pass
			# TODO: Print some sort of reminder to select a destination


func _on_health_destroyed():
	call_deferred("queue_free")
	emit_signal("destroyed")

func _on_input_event_npc(_camera, event, _click_position, _camera_normal, _shape):
	#https://stackoverflow.com/questions/58628154/detecting-click-touchscreen-input-on-a-3d-object-inside-godot
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed:
		Client.update_player_target_ship(self)
	else:
		Client.mouseover_entered(self)
