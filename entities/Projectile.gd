extends RigidBody3D

func _ready():
	call_deferred("initial_velocity")

func _physics_process(delta):
	Util.wrap_to_play_radius(self)

func initial_velocity():
	apply_central_impulse(
		10 * transform.basis.x
	)

func _on_Projectile_body_entered(body):
	queue_free()
	body.hit_by_projectile( )


func _on_Timer_timeout():
	queue_free()
