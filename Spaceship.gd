extends KinematicBody

onready var faction: String = Data.factions.keys()[0]

var max_speed = 100
var accel = 0.01
var turn = 1
var max_bank = deg2rad(15)
var bank_speed = 2.5

var linear_velocity = Vector2()

const PLAY_AREA_RADIUS = 300

func _ready():
	Client.player = self

func _physics_process(delta):
	linear_velocity = get_limited_velocity_with_thrust(delta)
	var rotation_impulse = delta * $Controller.rotation_impulse()
	rotation.y += turn * rotation_impulse
	if rotation_impulse:
		increase_bank(rotation_impulse)
	else:
		decrease_bank(delta)
		
	
# warning-ignore:return_value_discarded
	move_and_slide(Util.raise_25d(linear_velocity))
	handle_shooting()
	Util.wrap_to_play_radius(self)
	
	handle_hitting_stuff()

func handle_hitting_stuff():
	var collision = get_last_slide_collision()
	if collision:
		if collision.collider.has_method("break_up"):
			collision.collider.break_up()
			hit_by_asteroid()
			

func handle_shooting():
	if $Controller.is_shooting():
		$Weapon.try_shoot()
		#$Weapon2.try_shoot()

func get_limited_velocity_with_thrust(delta):
	if $Controller.is_thrusting():
		linear_velocity += Vector2(accel * delta * 100, 0).rotated(-rotation.y)
		$Graphics.thrusting = true
	else:
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
	$Graphics.rotation.x += rotation_impulse * bank_speed
	$Graphics.rotation.x = clamp(
		$Graphics.rotation.x,
		-max_bank,
		max_bank
	)

func decrease_bank(delta):
	if abs($Graphics.rotation.x) < delta:
		$Graphics.rotation.x = 0
	else:
		$Graphics.rotation.x -= sign($Graphics.rotation.x) * \
			max($Graphics.rotation.x, bank_speed * delta)
