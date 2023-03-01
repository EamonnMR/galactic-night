extends Node3D

class_name Controller

@onready var parent = get_node("../")
var ideal_face


var shooting: bool

var shooting_secondary: bool

var thrusting: bool

var rotation_impulse: float

var braking: bool

var jumping: bool

var warp_aligned = false

var WARP_MARGIN = 0.1

var WARP_MAX_SPEED = 0.1

func complete_jump():
	pass
	
func complete_warp_conditions_met() -> bool:
	return Util.out_of_system_radius(parent, Util.JUMP_DISTANCE) \
		and parent.linear_velocity.length() >= parent.max_speed * 0.9

func warp_conditions_met() -> bool:
	return Util.out_of_system_radius(parent, Util.JUMP_DISTANCE)

func _facing_within_margin(margin):
	# Relies on 'ideal face' being populated
	return ideal_face and abs(Util.anglemod(ideal_face - Util.flatten_rotation(parent))) < margin

func get_imagionary_position_of_other_system() -> Vector2:
	return (Procgen.systems[Client.selected_system].position
	- Procgen.systems[Client.current_system].position) * 100000

func process_warping_out(delta):
	shooting = false
	if not warp_aligned:
		braking = true
		populate_rotation_impulse_and_ideal_face(get_imagionary_position_of_other_system(), delta)
		
		thrusting = false
		braking = not thrusting
		
		if _facing_within_margin(WARP_MARGIN) and parent.linear_velocity.length() <= WARP_MAX_SPEED:
			warp_aligned = true
	else:
		rotation_impulse = 0
		thrusting = true
		braking = false
		if complete_warp_conditions_met():
			complete_jump()

func populate_rotation_impulse_and_ideal_face(at: Vector2, delta):
	var origin_2d = Util.flatten_25d(parent.global_transform.origin)
	var rot_2d = Util.flatten_rotation(parent)
	var max_move = parent.turn * delta
	
	var impulse = Util.constrained_point(
		origin_2d,
		rot_2d,
		max_move,
		at
	)
	rotation_impulse = impulse[0]
	ideal_face = impulse[1]
