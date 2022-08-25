extends RigidBody

func _ready():
	call_deferred("initial_velocity")

func initial_velocity():
	apply_central_impulse(
		10 * transform.basis.x
	)

func _on_Projectile_body_entered(body):
	queue_free()
	body.hit_by_projectile()
