extends Node3D

class_name Health

var already_destroyed: bool = false

signal damaged(source)
signal healed
signal destroyed

@export var max_health: int = 1
@export var health: int = -1
@export var max_shields: int = 10
@export var shields: int = -1
@export var explosion: PackedScene

func _ready():
	set_max_health(max_health, max_shields)
	
func set_max_health(max_h, max_s):
	var old_max = max_health
	max_health = max_h
	if health == -1 or health == old_max:
		health = max_health
	max_shields = max_s
	old_max = max_shields
	if shields == -1 or shields == old_max:
		shields = max_shields
  
func heal(amount):
	if can_heal():
		health += amount
	if health >= max_health:
		health = max_health
		emit_signal("healed")

func can_heal():
	return health < max_health

func take_damage(damage, source):
	if shields > 0:
		shields -= damage
	
		if shields > 0:
			emit_signal("damaged", source)
			return
		else:
			shields = 0
	
	# reset shield timers
	
	if health <= 0:  # Beating a dead horse
		return
	health -= damage

	if health <= 0 and not already_destroyed:
		already_destroyed = true
		emit_signal("destroyed")
		if explosion != null:
			Explosion.make_explo(explosion, get_node("../"))
	else:
		emit_signal("damaged", source)

func serialize():
	return {
		"health": health
	}
	
func deserialize(data):
	health = data.health

static func do_damage(entity, damage, source):
	if entity.has_node("Health"):
		entity.get_node("Health").take_damage(damage, source)
