extends Controller

enum STATES {
	IDLE,
	ATTACK,
	PERSUE
}

export var accel_margin = PI / 2
export var shoot_margin = PI / 2
export var max_target_distance = 1000
export var destination_margin = 100

export var engagement_range_radius = 10

var target
var ideal_face

var state = STATES.IDLE

func ready():
	$EngagementRange/CollisionShape.shape.radius = engagement_range_radius
	get_node("../Graphics").set_skin_data(Data.skins[1])

func _verify_target():
	if not target or not is_instance_valid(target):
		change_state_idle()

func _physics_process(delta):
	match state:
		STATES.IDLE:
			process_state_idle(delta)
		STATES.ATTACK:
			process_state_attack(delta)
		STATES.PERSUE:
			process_state_persue(delta)
			
func process_state_idle(delta):
	pass

func process_state_attack(delta):
	_verify_target()
	populate_rotation_impulse_and_ideal_face(target.global_position, delta)
	shooting = _facing_within_margin(shoot_margin)
	thrusting = parent.joust and _facing_within_margin(accel_margin)
	
func process_state_persue(delta):
	_verify_target()
	populate_rotation_impulse_and_ideal_face(target.global_position, delta)
	shooting = false
	thrusting = _facing_within_margin(accel_margin)
	
func populate_rotation_impulse_and_ideal_face(at: Vector2, delta):
	var impulse = Util._constrained_point(
		Util.flatten_25d(parent.global_transform.origin),
		Util.flatten_rotation(parent),
		parent.turn * delta,
		at
	)
	rotation_impulse = impulse[0]
	ideal_face = impulse[1]

func _find_target():
	# This could be more complex, but to function as a basic enemy npc, this is all we need
	if is_instance_valid(Client.player):
		change_state_chase(Client.player)
	else:
		change_state_idle()

func _on_Rethink_timeout():
	match state:
		STATES.IDLE:
			rethink_state_idle()
		STATES.ATTACK:
			rethink_state_attack()
		STATES.PERSUE:
			rethink_state_persue()

func rethink_state_idle():
	_find_target()

func rethink_state_persue():
	_find_target()

func rethink_state_attack():
	pass

func change_state_idle():
	state = STATES.IDLE
	target = null

func change_state_chase(target):
	state = STATES.CHASE
	target = target

func change_state_attack():
	state = STATES.ATTACK

func _facing_within_margin(margin):
	""" Relies on 'ideal face' being populated """
	return (
		parent.has_turrets or
		(ideal_face and abs(Util.anglemod(ideal_face - parent.rotation)) < margin)
	)

# Somewhat questioning the need for a whole node setup for this.
func _on_EngagementRange_body_entered(body):
	if body == target and state == STATES.CHASE:
		change_state_attack()


func _on_EngagementRange_body_exited(body):
	if body == target and state == STATES.ATTACK:
		change_state_chase(target)
