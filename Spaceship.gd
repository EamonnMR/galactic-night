extends KinematicBody

var max_speed = 100
var accel = 0.01
var turn = 1

var linear_velocity = Vector2()

const PLAY_AREA_RADIUS = 3000

func _physics_process(delta):
	linear_velocity = get_limited_velocity_with_thrust(delta)
	rotation.y += delta * turn * get_rotation_change()
	move_and_slide(Util.raise_25d(linear_velocity))


func get_limited_velocity_with_thrust(delta):
	if Input.is_action_pressed("ui_up"):
		linear_velocity += Vector2(accel * delta * 100, 0).rotated(-rotation.y)
	if linear_velocity.length() > max_speed:
		return Vector2(max_speed, 0).rotated(linear_velocity.angle())
	else:
		return linear_velocity

func get_rotation_change():
	var dc = 0
	# TODO:
	# Something is fucked up about the shader so invert this for now.
	if Input.is_action_pressed("ui_left"):
		dc += 1
	if Input.is_action_pressed("ui_right"):
		dc -= 1
	return dc
