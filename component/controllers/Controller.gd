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

func _facing_within_margin(margin):
	# Relies on 'ideal face' being populated
	return ideal_face and abs(Util.anglemod(ideal_face - Util.flatten_rotation(parent))) < margin

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

func _get_target_lead_position(lead_velocity: float, target: CharacterBody3D):
	return Util.lead_correct_position(
		lead_velocity,
		Util.flatten_25d(get_parent().global_transform.origin),
		get_parent_object().linear_velocity,
		target.linear_velocity,
		Util.flatten_25d(target.global_transform.origin)
	)
	
func get_parent_object():
	return get_parent()
	
func get_target():
	return null
