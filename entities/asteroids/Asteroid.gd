extends RigidBody3D

@export var initial_vel: float = 3.0
@export var size = 3

@export var next_type: PackedScene
@export var next_count: int = 0
@export var surface_material_override: Material


signal destroyed

func _ready():
	add_to_group("radar")
	rotate_y(randf_range(0, PI*2))
	call_deferred("initial_velocity")
	if surface_material_override:
		$Mesh.set_surface_override_material(0, surface_material_override)

func _physics_process(_delta):
	Util.wrap_to_play_radius(self)

func _on_health_destroyed():
	if next_count:
		for i in range(next_count):
			var sub_roid: RigidBody3D = next_type.instantiate()
			sub_roid.set_linear_velocity(linear_velocity)
			sub_roid.transform.origin = global_transform.origin
			Client.get_world().get_node("asteroids").add_child(sub_roid)
	emit_signal("destroyed")
	queue_free()

func initial_velocity():
	apply_central_impulse(
		initial_vel * transform.basis.x
	)


