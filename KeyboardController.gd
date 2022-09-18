extends Controller

func is_shooting() -> bool:
	return Input.is_action_pressed("shoot")
	
func is_thrusting() -> bool:
	return Input.is_action_pressed("thrust")
	
func rotation_impulse() -> int:
	var dc = 0
	if Input.is_action_pressed("turn_left"):
		dc += 1
	if Input.is_action_pressed("turn_right"):
		dc -= 1
	return dc

