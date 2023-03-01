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
var lead_velocity: float
var state = STATES.IDLE

@onready var faction: FactionData = Data.factions[get_node("../").faction]

func complete_warp():
	parent.queue_free()

func _ready():
	#$EngagementRange/CollisionShape3D.shape.radius = engagement_range_radius
	get_node("../Health").damaged.connect(_on_damage_taken)
	_compute_weapon_velocity.call_deferred()

func _verify_target():
	if target == null or not is_instance_valid(target):
		#print("No target", target)
		change_state_idle()
		return false
	return true

func _physics_process(delta):
	#$LeadIndicator.hide()
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
	populate_rotation_impulse_and_ideal_face(
		Util.flatten_25d(path_target.global_transform.origin),
		delta
	)
	shooting = false
	thrusting = _facing_within_margin(accel_margin)
	braking = false

func process_state_idle(_delta):
	pass

func process_state_attack(delta):
	if not _verify_target():
		return
	
	populate_rotation_impulse_and_ideal_face(
		_get_target_lead_position(), delta)
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

func _find_target():
	var enemy_ships = [Client.player] if faction.initial_disposition < 0 and is_instance_valid(Client.player) else []
	for faction_id in faction.enemies:
		enemy_ships += get_tree().get_nodes_in_group("faction-" + str(faction_id))

	if enemy_ships.size() == 0:
		_find_spob()
	elif enemy_ships.size() == 1:
		change_state_persue(enemy_ships[0])
	else:
		change_state_persue(Util.closest(enemy_ships, Util.flatten_25d(parent.global_transform.origin)))
		
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
	parent.remove_from_group("npcs-hostile")
	#print("New State: Idle")

func change_state_persue(target):
	state = STATES.PERSUE
	self.target = target
	if target == Client.player:
		parent.add_to_group("npcs-hostile")
	else:
		parent.remove_from_group("npcs-hostile")
	#print("New State: Persue")

func change_state_attack():
	state = STATES.ATTACK
	#print("New State: Attack")
	
func change_state_path(path_target):
	self.path_target = path_target
	state = STATES.PATH
	parent.remove_from_group("npcs-hostile")

func _compute_weapon_velocity():
	lead_velocity = 6 # Plasma. TODO: actually compute this from weapons

func _get_target_lead_position():
	var lead_position = Util.lead_correct_position(
		lead_velocity,
		Util.flatten_25d(get_parent().global_transform.origin),
		get_parent().linear_velocity,
		target.linear_velocity,
		Util.flatten_25d(target.global_transform.origin)
		
	)
	#$LeadIndicator.global_transform.origin = Util.raise_25d(lead_position)
	#$LeadIndicator.show()
	return lead_position

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
	
