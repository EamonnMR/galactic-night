extends RigidBody

export var initial_vel: float = 3.0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	rotate_y(rand_range(0, PI*2))
	call_deferred("initial_velocity")

func _physics_process(delta):
	Util.wrap_to_play_radius(self)

func _on_Asteroid_body_entered(body):
	if body.has_method("hit_by_asteroid"):
		body.hit_by_asteroid()
		break_up()
	
func hit_by_projectile():
	break_up()

func break_up():
	# TODO: Spawn small asteroids
	queue_free()

func initial_velocity():
	apply_central_impulse(
		initial_vel * transform.basis.x
	)
