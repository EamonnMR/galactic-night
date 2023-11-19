extends CharacterBody3D

var iff: IffProfile
var damage: int
var splash_damage: int
var splash_radius: int
var linear_velocity = Vector2()
var initial_velocity = 10
var explode_on_timeout: bool = true

func _ready():
	linear_velocity += Vector2(initial_velocity, 0).rotated(-rotation.y)

func _physics_process(_delta):
	set_velocity(Util.raise_25d(linear_velocity))
	move_and_slide()
	Util.wrap_to_play_radius(self)


func _on_Projectile_body_entered(body):
	if not iff.should_exclude(body):
		queue_free()
		Health.do_damage(body, damage, iff.owner)
		detonate()


func _on_Timer_timeout():
	queue_free()

func set_lifetime(lifetime: float):
	if lifetime:
		$Timer.wait_time = lifetime

func detonate():
	# TODO: pretty explosion
	if splash_damage:
		for data in Util.sphere_query(get_world_3d(), global_transform, splash_radius, $Area3D.collision_mask, $Sphere/SphereShapeHolder.shape):
			Health.do_damage(data.collider, splash_damage, iff.owner)
