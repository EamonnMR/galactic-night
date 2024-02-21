extends Controller

enum STATES {
	IDLE,
	ATTACK
}

var target
var state = STATES.IDLE

var bodies_in_engagement_range = []
var faction: FactionData

func _ready():
	if parent.get("faction"):
		faction = Data.factions[get_node("../").faction]
	else:
		faction = null # Player-owned.
	if get_tree().debug_collisions_hint:
		$Label.show()
	var shape = $EngagementRange/CollisionShape3D.shape
	shape = shape.duplicate(true)
	shape.radius = parent.engagement_range
	$EngagementRange/CollisionShape3D.shape = shape
	

func _verify_target():
	if target == null or not is_instance_valid(target):
		#print("No target", target)
		change_state_idle()
		return false
	return true

func _physics_process(delta):
	if get_tree().debug_collisions_hint:
		$LeadIndicator.hide()
		$Label.text = STATES.keys()[state] + "\n"
	match state:
		STATES.IDLE:
			process_state_idle(delta)
		STATES.ATTACK:
			process_state_attack(delta)

func process_state_idle(_delta):
	pass

func process_state_attack(delta):
	if not _verify_target():
		change_state_idle()
	shooting = true


func _find_target():
	target = null
	Util.distance_ordered(bodies_in_engagement_range, Util.flatten_25d(parent.global_transform.origin))
	
	var hostile_to_player = faction and faction.initial_disposition < 0
	var hostile_groups = []
	if hostile_to_player:
		hostile_groups.append("player-assets")
	if faction: 
		for faction_id in faction.enemies:
			hostile_groups.append("faction-" + str(faction_id))
	else:
		for faction_id in Data.factions:
			if Data.factions[faction_id].initial_disposition < 0:
				hostile_groups.append("faction-" + str(faction_id))

	for possible_target in bodies_in_engagement_range:
		for group in hostile_groups:
			if possible_target.is_in_group(group):
				change_state_attack(possible_target)

	change_state_idle()

func _on_Rethink_timeout():
	_find_target()

func change_state_idle():
	state = STATES.IDLE
	target = null
	rotation_impulse = 0
	parent.remove_from_group("npcs-hostile")
	#print("New State: Idle")

func change_state_attack(target):
	state = STATES.ATTACK
	self.target = target
	if target.is_in_group("player-assets"):
		add_to_group("npcs-hostile")
	
func _on_EngagementRange_body_entered(body):
	bodies_in_engagement_range.append(body)
	
	_find_target()

func _on_EngagementRange_body_exited(body):
	bodies_in_engagement_range.erase(body)

func get_target():
	return target
