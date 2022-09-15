extends KinematicBody

onready var faction: String = Data.factions.keys()[0]

var max_speed = 100
var accel = 0.01
var turn = 1

var linear_velocity = Vector2()

const PLAY_AREA_RADIUS = 300

func _ready():
	Client.player = self

func _process(delta):
	cycle_faction_colors()

func _physics_process(delta):
	linear_velocity = get_limited_velocity_with_thrust(delta)
	rotation.y += delta * turn * get_rotation_change()
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
	if Input.is_action_pressed("shoot"):
		$Weapon.try_shoot()
		#$Weapon2.try_shoot()

func get_limited_velocity_with_thrust(delta):
	if Input.is_action_pressed("thrust"):
		linear_velocity += Vector2(accel * delta * 100, 0).rotated(-rotation.y)
		$Graphics.thrusting = true
	else:
		$Graphics.thrusting = false
	if linear_velocity.length() > max_speed:
		return Vector2(max_speed, 0).rotated(linear_velocity.angle())
	else:
		return linear_velocity

func get_rotation_change():
	var dc = 0
	if Input.is_action_pressed("turn_left"):
		dc += 1
	if Input.is_action_pressed("turn_right"):
		dc -= 1
	return dc

func flash_weapon():
	$Graphics.flash_weapon()

func hit_by_asteroid():
	call_deferred("queue_free")

func cycle_faction_colors():
	if Input.is_action_just_pressed("switch_color"):
		# Thanks, I hate it
		var keys: PoolStringArray = Data.factions.keys()
		var index: int = keys.find(faction)
		index += 1
		if index == keys.size():
			index = 0
		faction = keys[index]
		$Graphics.set_faction_color(faction)
