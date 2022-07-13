extends Node

func raise_25d(two_d_vec: Vector2):
	return Vector3(two_d_vec.x, 0, two_d_vec.y)

func flatten_25d(three_d_vec: Vector3):
	return Vector2(three_d_vec.x, three_d_vec.z)
