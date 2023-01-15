extends RigidBody3D

var iff: IffProfile
var damage: int

func _ready():
	call_deferred("initial_velocity")

func _physics_process(delta):
	Util.wrap_to_play_radius(self)

func initial_velocity():
	apply_central_impulse(
		10 * transform.basis.x
	)

func _on_Projectile_body_entered(body):
	if not iff.should_exclude(body):
		queue_free()
		Health.do_damage(body, damage, iff.owner)


func _on_Timer_timeout():
	queue_free()
