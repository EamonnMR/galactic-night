extends Controller

enum STATES {
	IDLE,
	ATTACK,
	PERSUE,
	PATH
}

@export var accel_margin = PI / 4
@export var shoot_margin = PI / 2
@export var max_target_distance = 1000
@export var destination_margin = 100

#export var engagement_range_radius = 100

var target
var path_target
var ideal_face

var state = STATES.IDLE

@onready var faction: FactionData = Data.factions[get_node("../").faction]

func _ready():
	#$EngagementRange/CollisionShape3D.shape.radius = engagement_range_radius
	get_node("../Health").connect("damaged", self._on_damage_taken)

func _verify_target():
	if target == null or not is_instance_valid(target):
		#print("No target", target)
		change_state_idle()
		return false
	return true

func _physics_process(delta):
	#$Label.text = STATES.keys()[state] + "\n" \
	#	+ "My faction: " + Data.factions[parent.faction].name + "\n" \
	#	+ str(target) + " (" + Data.factions[target.faction].name + ")" if is_instance_valid(target) else "" + "\n"
	match state:
		STATES.IDLE:
			process_state_idle(delta)
		STATES.ATTACK:
			process_state_attack(delta)
		STATES.PERSUE:
			process_state_persue(delta)
		STATES.PATH:
			process_state_path(delta)

func process_state_path(delta):
	populate_rotation_impulse_and_ideal_face(Util.flatten_25d(path_target.global_transform.origin), delta)
	shooting = false
	thrusting = _facing_within_margin(accel_margin)
	braking = false

func process_state_idle(_delta):
	pass

func process_state_attack(delta):
	if not _verify_target():
		return
	
	populate_rotation_impulse_and_ideal_face(Util.flatten_25d(target.global_transform.origin), delta)
	shooting = _facing_within_margin(shoot_margin)
	thrusting = false #parent.joust and _facing_within_margin(accel_margin)
	braking = true

func process_state_persue(delta):
	if not _verify_target():
		return
	populate_rotation_impulse_and_ideal_face(Util.flatten_25d(target.global_transform.origin), delta)
	shooting = false
	thrusting = _facing_within_margin(accel_margin)
	braking = false
	
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
	var enemy_ships: Array[Node3D] = [Client.player] if faction.initial_disposition < 0 and is_instance_valid(Client.player) else []
	for faction_id in faction.enemies:
		enemy_ships += get_tree().get_nodes_in_group("faction-" + str(faction_id))

	if enemy_ships.size() == 0:
		_find_spob()
	elif enemy_ships.size() == 1:
		change_state_persue(enemy_ships[0])
	else:
		var parent_position: Vector2 = Util.flatten_25d(get_node("../").global_transform.origin)
		enemy_ships.sort_custom(
			func distance_comparitor(lval: Node3D, rval: Node3D):
				# For sorting other nodes by how close they are
				
				var ldist =  Util.flatten_25d(lval.global_transform.origin).distance_to(parent_position)
				var rdist = Util.flatten_25d(rval.global_transform.origin).distance_to(parent_position)
				return ldist < rdist
		)
		change_state_persue(enemy_ships[0])
		
func _find_spob():
	var spobs = get_tree().get_nodes_in_group("spobs")
	if spobs.size() == 0:
		change_state_idle()
	else:
		var rng  = RandomNumberGenerator.new()
		rng.randomize()
		path_target = Procgen.random_select(spobs, rng)
		change_state_path(Procgen.random_select(spobs, rng))

func _on_Rethink_timeout():
	match state:
		STATES.IDLE:
			rethink_state_idle()
		STATES.ATTACK:
			rethink_state_attack()
		STATES.PERSUE:
			rethink_state_persue()
		STATES.PATH:
			rethink_state_path()

func rethink_state_idle():
	_find_target()

func rethink_state_path():
	pass

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
	#print("New State: Idle")

func change_state_persue(target):
	state = STATES.PERSUE
	self.target = target
	#print("New State: Persue")

func change_state_attack():
	state = STATES.ATTACK
	#print("New State: Attack")
	
func change_state_path(path_target):
	self.path_target = path_target
	state = STATES.PATH

func _facing_within_margin(margin):
	# Relies checked 'ideal face' being populated
	return ideal_face and abs(Util.anglemod(ideal_face - Util.flatten_rotation(parent))) < margin

# Somewhat questioning the need for a whole node setup for this.
func _on_EngagementRange_body_entered(body):
	if body == target and state == STATES.PERSUE:
		#print("Reached target")
		change_state_attack()
	
	if body == path_target and state == STATES.PATH:
		change_state_idle()

func _on_EngagementRange_body_exited(body):
	if body == target and state == STATES.ATTACK:
		#print("Target left engagement range")
		change_state_persue(target)

func _on_damage_taken(source):
	change_state_persue(source)
