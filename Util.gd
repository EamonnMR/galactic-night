extends Node

var PLAY_AREA_RADIUS = 100

func get_multiple(object: Object, attributes: Array[String]) -> Dictionary:
	var attrs = {}
	for i in attributes:
		attrs[i] = object.get(i)
	return attrs

func set_multiple(object: Object, attributes: Dictionary):
	for key in attributes:
		object.set(key, attributes[key])

func default_serialize(object: Object):
	const NO_SERIAL_PROPS = ["Script", "script", "Script Variables"]
	var keys = []
	for prop in get_property_list():
		if not (prop["name"] in NO_SERIAL_PROPS):
			keys.append(prop["name"])
	return get_multiple(object, keys)


func anglemod(angle: float) -> float:
	return fmod(angle, PI * 2)

func raise_25d(two_d_vec: Vector2) -> Vector3:
	return Vector3(two_d_vec.x, 0, two_d_vec.y)

func flatten_25d(three_d_vec: Vector3) -> Vector2:
	return Vector2(three_d_vec.x, three_d_vec.z)
	
func flatten_rotation(object: Node3D) -> float:
	return object.global_transform.basis.get_rotation_quaternion().get_euler().y

func wrap_to_play_radius(entity: Node3D) -> bool:
	var position = flatten_25d(entity.global_transform.origin)
	if position.length() > PLAY_AREA_RADIUS:
		entity.global_transform.origin = raise_25d(
			Vector2(
				PLAY_AREA_RADIUS / 2.0, 0
			).rotated(
				anglemod(position.angle() + PI)
			)
		)
		return true
	return false

func _constrained_point(source_position: Vector2, current_rotation: float,
		max_turn: float, target_position: Vector2) -> Array:
	# For finding the right direction and amount to turn when your rotation speed is limited
	var ideal_face = (target_position - source_position).angle()
	ideal_face = PI * 2 - ideal_face
	var ideal_turn = anglemod(ideal_face - current_rotation)
	if(ideal_turn > PI):
		ideal_turn = anglemod(ideal_turn - 2 * PI)

	elif(ideal_turn < -1 * PI):
		ideal_turn = anglemod(ideal_turn + 2 * PI)
	
	max_turn = sign(ideal_turn) * max_turn  # Ideal turn in the right direction
	
	if(abs(ideal_turn) > abs(max_turn)):
		return [max_turn, ideal_face]
	else:
		return [ideal_turn, ideal_face]

enum DISPOSITION {
	FRIENDLY,
	HOSTILE,
	NEUTRAL,
	ABANDONED
}

func closest(choices, position: Vector2) -> Node3D:
	# Warning: side effects
	choices.sort_custom(
		func distance_comparitor(lval: Node3D, rval: Node3D):
			# For sorting other nodes by how close they are
			
			var ldist =  Util.flatten_25d(lval.global_transform.origin).distance_to(position)
			var rdist = Util.flatten_25d(rval.global_transform.origin).distance_to(position)
			return ldist < rdist
	)
	return choices[0]
