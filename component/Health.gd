extends Node3D

class_name Health

var already_destroyed: bool = false

signal damaged(source)
signal healed
signal destroyed

@export var max_health: int = 1
@export var health: int = -1
@export var explosion: PackedScene

func _ready():
	set_max_health(max_health)
	
func set_max_health(max):
	var old_max = max_health
	max_health = max
	if health == -1 or health == old_max:
		health = max_health
  
func heal(amount):
	if can_heal():
		health += amount
	if health >= max_health:
		health = max_health
		emit_signal("healed")

func can_heal():
	return health < max_health

func take_damage(damage, source):
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
