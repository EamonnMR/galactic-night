extends Controller

enum STATES {
	IDLE,
	ATTACK,
	PERSUE
}

@export var accel_margin = PI / 4
@export var shoot_margin = PI / 2
@export var max_target_distance = 1000
@export var destination_margin = 100

#export var engagement_range_radius = 100

var target
var ideal_face

var state = STATES.IDLE

func ready():
	#$EngagementRange/CollisionShape3D.shape.radius = engagement_range_radius
	get_node("../Graphics").set_skin_data(Data.skins[1])

func _verify_target():
	if target == null or not is_instance_valid(target):
		print("No target", target)
		change_state_idle()
		return false
	return true

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
	if not _verify_target():
		return
	
	populate_rotation_impulse_and_ideal_face(Util.flatten_25d(target.global_transform.origin), delta)
	shooting = _facing_within_margin(shoot_margin)
	thrusting = false #parent.joust and _facing_within_margin(accel_margin)
	
func process_state_persue(delta):
	if not _verify_target():
		return
	populate_rotation_impulse_and_ideal_face(Util.flatten_25d(target.global_transform.origin), delta)
	shooting = false
	thrusting = _facing_within_margin(accel_margin)
	
func populate_rotation_impulse_and_ideal_face(at: Vector2, delta):
	var origin_2d = Util.flatten_25d(parent.global_transform.origin)
	var rot_2d = Util.flatten_rotation(parent)
	var max_move = parent.turn * delta
	
	var impulse = Util._constrained_point(
		origin_2d,
		rot_2d,
		max_move,
		at
	)
	rotation_impulse = impulse[0]
	ideal_face = impulse[1]

func _find_target():
	# This could be more complex, but to function as a basic enemy npc, this is all we need
	if is_instance_valid(Client.player):
		print("Target found: ", Client.player)
		change_state_persue(Client.player)
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
	#_find_target()
	pass

func rethink_state_attack():
	pass

func change_state_idle():
	state = STATES.IDLE
	target = null
	thrusting = false
	shooting = false
	rotation_impulse = 0
	print("New State: Idle")

func change_state_persue(target):
	state = STATES.PERSUE
	self.target = target
	print("New State: Persue")

func change_state_attack():
	state = STATES.ATTACK
	print("New State: Attack")

func _facing_within_margin(margin):
	""" Relies checked 'ideal face' being populated """
	return ideal_face and abs(Util.anglemod(ideal_face - Util.flatten_rotation(parent))) < margin

# Somewhat questioning the need for a whole node setup for this.
func _on_EngagementRange_body_entered(body):
	print("Body Entered")
	if body == target and state == STATES.PERSUE:
		print("Reached target")
		change_state_attack()

func _on_EngagementRange_body_exited(body):
	print("Body exited")
	if body == target and state == STATES.ATTACK:
		print("Target left engagement range")
		change_state_persue(target)
