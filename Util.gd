extends Node

var PLAY_AREA_RADIUS = 25

func anglemod(angle: float) -> float:
	return fmod(angle, PI * 2)

func raise_25d(two_d_vec: Vector2):
	return Vector3(two_d_vec.x, 0, two_d_vec.y)

func flatten_25d(three_d_vec: Vector3):
	return Vector2(three_d_vec.x, three_d_vec.z)

func wrap_to_play_radius(entity: Spatial):
	var position = flatten_25d(entity.global_transform.origin)
	if position.length() > PLAY_AREA_RADIUS:
		entity.global_transform.origin = raise_25d(
			Vector2(
				PLAY_AREA_RADIUS / 2, 0
			).rotated(
				anglemod(position.angle() + PI)
			)
		)
		return true
	return false
