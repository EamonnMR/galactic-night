extends Node3D

class_name Health

var already_destroyed: bool = false
var shield_regen_cooldown: bool = false
var invulnerable: bool = false

signal damaged(source)
signal healed
signal destroyed

@export var max_health: int = 1
@export var health: int = -1
@export var max_shields: int = 10
@export var shields: int = -1
@export var explosion: PackedScene
@export var shield_regen: float = 1
@export var shield_regen_delay: float = 5

func _ready():
	set_max_health(max_health, max_shields)
	set_shield_regen(shield_regen, shield_regen_delay)
	
func set_max_health(max_h, max_s):
	var old_max = max_health
	max_health = max_h
	if health == -1 or health == old_max:
		health = max_health
	max_shields = max_s
	old_max = max_shields
	if shields == -1 or shields == old_max:
		shields = max_shields
		
func set_shield_regen(n_shield_regen, n_shield_regen_delay):
	shield_regen = n_shield_regen
	shield_regen_delay = n_shield_regen_delay
	$ShieldRegen.wait_time = shield_regen
	$RegenDelay.wait_time = shield_regen_delay
  
func heal(amount):
	if can_heal():
		health += amount
	if health >= max_health:
		health = max_health
		emit_signal("healed")

func can_heal():
	return health < max_health

func take_damage(damage, source):
	
	if invulnerable:
		return
	
	var mass_damage = damage.mass
	if not damage.ignore_shields:
		if damage.energy > 0:
			reset_shield_regen()
		
			if shields > 0:
				if damage.energy > 0:
					if shields < damage.energy:
						mass_damage = get_fractional_mass_damage(damage)
						shields = 0
					else:
						shields -= damage.energy
						if shields > 0:
							emit_signal("damaged", source)
							return
	
	health -= mass_damage

	if health <= 0 and not already_destroyed:
		already_destroyed = true
		emit_signal("destroyed")
		if explosion != null:
			Explosion.make_explo(explosion, get_node("../"))
	else:
		emit_signal("damaged", source)

func get_fractional_mass_damage(damage: DamageVal):
		var remainder = shields - damage.energy
		var remainder_fraction = damage.energy / remainder
		return round(damage.mass * (damage.energy / shields - damage.energy) )

func serialize():
	return {
		"health": health
	}
	
func deserialize(data):
	health = data.health

static func do_damage(entity: Node, damage: DamageVal, source: Node):
	if entity.has_node("Health"):
		entity.get_node("Health").take_damage(damage, source)

func reset_shield_regen():
	shield_regen_cooldown = true
	$ShieldRegen.start()
	$RegenDelay.start()

func _on_regen_delay_timeout():
	shield_regen_cooldown = false

func _on_shield_regen_timeout():
	if shields < max_shields and not shield_regen_cooldown:
		shields += 1

# TODO: Use complex damage values in place of ints
class DamageVal:
	var mass_damage: int
	var energy_damage: int
	#var ionization: int
	#var disruption: int
	var ignore_shields: bool
	
	func _init(mass_damage: int, energy_damage: int, ignore_shields: bool):
		self.mass_damage = mass_damage
		self.energy_damage = energy_damage
		self.ignore_shields = ignore_shields
