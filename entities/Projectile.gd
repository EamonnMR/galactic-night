extends CharacterBody3D

var iff: IffProfile
var damage: int
var splash_damage: int
var splash_radius: int
var linear_velocity = Vector2()
var initial_velocity = 10
var explode_on_timeout: bool = true
var damage_falloff: bool = false
var fade: bool = false
var impact: float
var material: StandardMaterial3D# = $MeshInstance3D.surface_get_material(0)
@export var explosion: PackedScene


func _ready():
	linear_velocity += Vector2(initial_velocity, 0).rotated(-rotation.y)
	
	if fade:
		material = $MeshInstance3D.mesh.surface_get_material(0).duplicate(true)
		$MeshInstance3D.set_surface_override_material(0, material)

func _process(delta):
	if fade:
		material.albedo_color.a = _fade_factor()

func _physics_process(_delta):
	set_velocity(Util.raise_25d(linear_velocity))
	move_and_slide()
	Util.wrap_to_play_radius(self)


func _on_Projectile_body_entered(body):
	if not iff.should_exclude(body):
		Health.do_damage(body, get_falloff_damage(damage), iff.owner)
		if impact > 0 and body.has_method("receive_impact"):
			body.receive_impact(linear_velocity.normalized(), impact)
		detonate()
		queue_free()

func get_falloff_damage(damage) -> int:
	if damage_falloff:
		return roundi(damage - 1 * _fade_factor()) + 1
	else:
		return damage
		
func _fade_factor():
	return $Timer.time_left / $Timer.wait_time

func _on_Timer_timeout():
	if explode_on_timeout:
		detonate()
	queue_free()


func set_lifetime(lifetime: float):
	if lifetime:
		$Timer.wait_time = lifetime

func detonate():
	if explosion:
		Explosion.make_explo(explosion, self)
	if splash_damage:
		for data in Util.sphere_query(get_world_3d(), global_transform, splash_radius, $Area3D.collision_mask, $Sphere/SphereShapeHolder.shape):
			Health.do_damage(data.collider, splash_damage, iff.owner)
