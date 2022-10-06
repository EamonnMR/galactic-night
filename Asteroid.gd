extends RigidBody3D

@export var initial_vel: float = 3.0
@export var size = 3

@export var next_type: PackedScene
@export var next_count: int = 0

func _ready():
	rotate_y(randf_range(0, PI*2))
	call_deferred("initial_velocity")

func _physics_process(delta):
	Util.wrap_to_play_radius(self)
	
func hit_by_projectile():
	break_up()

func break_up():
	# TODO: Spawn small asteroids
	if next_count:
		for i in range(next_count):
			var sub_roid: RigidBody3D = next_type.instantiate()
			sub_roid.set_linear_velocity(linear_velocity)
			sub_roid.transform.origin = global_transform.origin
			get_node("../").add_child(sub_roid)
	queue_free()
func initial_velocity():
	apply_central_impulse(
		initial_vel * transform.basis.x
	)


func _on_Area_body_entered(body):
	if body.has_method("hit_by_asteroid"):
		body.hit_by_asteroid()
		break_up()
