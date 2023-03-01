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

func complete_jump():
	pass
	
func complete_warp_conditions_met() -> bool:
	return Util.flatten_25d(parent.position).length() >= Util.WARP_OUT_DISTANCE

func warp_conditions_met() -> bool:
	return Util.flatten_25d(parent.position).length() >= Util.JUMP_DISTANCE

func _facing_within_margin(margin):
	# Relies on 'ideal face' being populated
	return ideal_face and abs(Util.anglemod(ideal_face - Util.flatten_rotation(parent))) < margin

func get_target_position() -> Vector2:
	return (Procgen.systems[Client.selected_system].position
	- Procgen.systems[Client.current_system].position) \
	+ Util.flatten_25d(get_node("../").transform.origin)

func process_warping_out(delta):
	populate_rotation_impulse_and_ideal_face(get_target_position(), delta)
	shooting = false
	thrusting = _facing_within_margin(0.1)
	braking = not thrusting
	Client.display_message("Distance: %s, Jump at: %s" % [Util.flatten_25d(parent.position).length(), Util.WARP_OUT_DISTANCE])
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
