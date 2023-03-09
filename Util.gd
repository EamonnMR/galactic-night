extends Node

var PLAY_AREA_RADIUS = 200

var JUMP_DISTANCE = PLAY_AREA_RADIUS * 0.35

func get_multiple(object: Object, attributes: Array) -> Dictionary:
	var attrs = {}
	for i in attributes:
		attrs[i] = object.get(i)
	return attrs

func set_multiple(object: Object, attributes: Dictionary):
	for key in attributes:
		object.set(key, attributes[key])

func set_multiple_only(object: Object, attributes: Dictionary, only):
	for key in only:
		object.set(key, attributes[key])

func serialize_vec(vec: Vector2) -> String:
	return "%s %s" % [vec.x, vec.y]

func deserialize_vec(str: String) -> Vector2:
	var split = str.split(" ")
	return Vector2(float(split[0]), float(split[1]))

func default_serialize(object: Object):
	const NO_SERIAL_PROPS = [
		"Script",
		"script",
		"Script Variables",
		"process_mode",
		"process_priority",
		"unique_name_in_owner",
		"multiplayer",
		"Node",
	]
	var keys = []
	for prop in object.get_property_list():
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
			invert_position(position, PLAY_AREA_RADIUS / 2.0)
		)
		return true
	return false

func invert_position(position: Vector2, distance) -> Vector2:
	return Vector2(
		distance, 0
	).rotated(
		anglemod(position.angle() + PI)
	)

func constrained_point(source_position: Vector2, current_rotation: float,
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

func item_screen_box_side_length(object):
	if object.has_method("screen_box_side_length"):
		return object.screen_box_side_length()
	elif "screen_box_side_length" in object:
		return object.screen_box_side_length
	else:
		return 100

func lead_correct_position(projectile_velocity: float, origin_position: Vector2, origin_velocity: Vector2, target_velocity: Vector2, target_position: Vector2) -> Vector2:
	# Simplified 'first order' leading via https://www.gamedev.net/tutorials/programming/math-and-physics/leading-the-target-r4223/
	var relative_vel = target_velocity - origin_velocity
	var travel_time = target_position.distance_to(origin_position) / projectile_velocity
	return relative_vel * travel_time + target_position

func out_of_system_radius(node: Node3D, radius: float) -> bool:
	return flatten_25d(node.global_position).length() >= radius
	
