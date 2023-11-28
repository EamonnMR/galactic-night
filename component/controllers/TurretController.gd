extends Controller

var lead_velocity = 12

func update_lead_vel():
	pass
	#lead_velocity = get_node("../Weapon").projectile_velocity

func _physics_process(delta):
	var target = get_node("../../Controller").get_target()
	if is_instance_valid(target):
		populate_rotation_impulse_and_ideal_face(
			_get_target_lead_position(lead_velocity, target),
		delta)

func get_parent_object():
	return get_node("../../")
