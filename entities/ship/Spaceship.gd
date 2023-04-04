extends CharacterBody3D

class_name Spaceship

var faction
var type: String

var max_speed = 100
var accel = 0.01
var turn = 1
var max_bank = deg_to_rad(15)
var bank_speed = 2.5 / turn
var engagement_range: float = 0
var standoff: bool = false
@export var bank_factor = 1
@export var bank_axis = "x"
var screen_box_side_length: int

var linear_velocity = Vector2()
var primary_weapons = []
var secondary_weapons = []

var warping = false
var warping_in = false
var warp_speed_factor = 10

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
		add_child(preload("res://component/InteractionRange.tscn").instantiate())
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
	var weapon_slots: Array[WeaponSlot] = []
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
	if not warping:
		if warping_in:
			if Util.out_of_system_radius(self, Util.PLAY_AREA_RADIUS / 2):
				warping_in = false
		else:
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
	
	if not warping:
		if linear_velocity.length() > max_speed:
			return Vector2(max_speed, 0).rotated(linear_velocity.angle())
		else:
			return linear_velocity
	else:
		if linear_velocity.length() > max_speed * warp_speed_factor:
			return Vector2(max_speed * warp_speed_factor, 0).rotated(linear_velocity.angle())
		else:
			return linear_velocity
func flash_weapon():
	$Graphics.flash_weapon()

func increase_bank(rotation_impulse):
	$Graphics.rotation[bank_axis] += rotation_impulse * bank_speed * bank_factor
	$Graphics.rotation[bank_axis] = clamp(
		$Graphics.rotation[bank_axis],
		-max_bank,
		max_bank
	)

func decrease_bank(delta):
	if $Graphics.rotation[bank_axis] != 0.0:
		var sgn = sign($Graphics.rotation[bank_axis]) * bank_factor
		$Graphics.rotation[bank_axis] -= sgn * bank_speed * delta * bank_factor
		if sign($Graphics.rotation[bank_axis]) != sgn:
			$Graphics.rotation[bank_axis] = 0
	
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

func serialize_player():
	return {
		"type": type,
		"health": $Health.serialize(),
		"equipment": $Equipment.serialize(),
		"inventory": $Inventory.serialize()
	}

func deserialize_player(data: Dictionary):
	type = data.type
	$Health.deserialize(data.health)
	$Equipment.deserialize(data.equipment)
	$Inventory.deserialize(data.inventory)
