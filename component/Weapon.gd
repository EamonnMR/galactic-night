extends Node3D

class_name Weapon

var cooldown: bool = false
var burst_cooldown: bool = false
var burst_counter: int = 0


var iff: IffProfile

var type: String

@onready var parent = get_node("../../")

@export var projectile_scene: PackedScene
@export var burst_count = 0
@export var dupe_count = 1
@export var spread: float = 0
@export var world_projectile: bool = true  # Disable for beams or other things that should follow the player
@export var vary_pitch = 0
@export var ammo_item: String
@export var primary = true
@export var weapon_name: String = "Plasma"
@export var projectile_velocity: float

# @export var dmg_factor: float = 1
@export var damage: int

func _ready():
	Data.weapons[type].apply_to_node(self)
	iff = IffProfile.new(
		parent,
		parent.faction,
		false
	)

func try_shoot():
	if not cooldown and not burst_cooldown:
		if _try_consume_ammo():
			# TODO: Consume ammo
			_shoot()

func _shoot():
	if burst_count:
		burst_counter += 1
		if burst_counter >= burst_count:
			burst_cooldown = true
			$BurstCooldown.start()
	for i in range(dupe_count):
		_create_projectile()
	cooldown = true
	$Cooldown.start()
	_effects()

func _create_projectile():
	var projectile = projectile_scene.instantiate()
	# projectile.init()
	if world_projectile:
		Client.get_world().get_node("projectiles").add_child(projectile)
	else:
		get_node("../").add_child(projectile)
	#projectile.damage *= dmg_factor
	#projectile.splash_damage *= dmg_factor
	# TODO: Also scale splash damage
	projectile.global_transform = global_transform
	projectile.damage = damage
	projectile.initial_velocity = projectile_velocity
	projectile.linear_velocity = parent.linear_velocity
	projectile.rotate_x(randf_range(-spread/2, spread/2))
	projectile.rotate_y(randf_range(-spread/2, spread/2))
	projectile.iff = iff

func _effects():
	#$Emerge/MuzzleFlash.restart()
	#$Emerge/MuzzleFlash.emitting = true
	$AudioStreamPlayer3D.play()
	parent.flash_weapon()

func _on_Cooldown_timeout():
	cooldown = false

func _on_BurstCooldown_timeout():
	burst_cooldown = false
	burst_counter = 0
	
func _try_consume_ammo():
	if ammo_item == "":
		return true
	return parent.get_node("Inventory").deduct_ingredients({ammo_item: 1})
