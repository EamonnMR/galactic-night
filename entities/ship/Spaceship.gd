extends CharacterBody3D

var faction

var max_speed = 100
var accel = 0.01
var turn = 1
var max_bank = deg_to_rad(15)
var bank_speed = 2.5 / turn

var linear_velocity = Vector2()

const PLAY_AREA_RADIUS = 300

func _ready():
	if self == Client.player:
		$CameraFollower.remote_path = Client.camera.get_node("../").get_path()
		Client.ui_inventory.assign($Inventory, "Your inventory")
	else:
		$Graphics.set_skin_data(Data.skins[Data.factions[faction].skin])

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
	velocity
	handle_shooting()
	handle_jumping()
	Util.wrap_to_play_radius(self)
	
	handle_hitting_stuff()

func handle_hitting_stuff():
	var collision: KinematicCollision3D = get_last_slide_collision()
	if collision:
		if collision.get_collider().has_method("break_up"):
			collision.get_collider().break_up()
			hit_by_asteroid()
			

func handle_shooting():
	if $Controller.shooting:
		$Weapon.try_shoot()
		#$Weapon2.try_shoot()

func get_limited_velocity_with_thrust(delta):
	if $Controller.thrusting:
		linear_velocity += Vector2(accel * delta * 100, 0).rotated(-rotation.y)
		if $Graphics != null:
			$Graphics.thrusting = true
	else:
		if $Graphics != null:
			$Graphics.thrusting = false
	if linear_velocity.length() > max_speed:
		return Vector2(max_speed, 0).rotated(linear_velocity.angle())
	else:
		return linear_velocity

func flash_weapon():
	$Graphics.flash_weapon()

func hit_by_asteroid():
	call_deferred("queue_free")

func increase_bank(rotation_impulse):
	if $Graphics != null:
		$Graphics.rotation.x += rotation_impulse * bank_speed
		$Graphics.rotation.x = clamp(
			$Graphics.rotation.x,
			-max_bank,
			max_bank
		)

func decrease_bank(delta):
	if $Graphics != null:
		if abs($Graphics.rotation.x) < delta:
			$Graphics.rotation.x = 0
		else:
			$Graphics.rotation.x -= sign($Graphics.rotation.x) * \
				max($Graphics.rotation.x, bank_speed * delta)

func hit_by_projectile():
	hit_by_asteroid()
	
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
