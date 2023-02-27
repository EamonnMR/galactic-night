extends Node

var warp_factor = 0.0

var warp_rate = 1

enum STATES {
	POWERED_DOWN,
	WARPING_OUT,
	WARPING_IN
}

var state: STATES = STATES.POWERED_DOWN
func start_hyperjump():
	if state == STATES.POWERED_DOWN:
		state = STATES.WARPING_OUT
		Client.get_background().warp_angle = Util.flatten_rotation(get_node("../"))
		return true
	else:
		return false

func _process(delta):
	Client.get_background().warp_angle = Util.flatten_rotation(get_node("../"))
	if state == STATES.POWERED_DOWN:
		return
	
	if state == STATES.WARPING_OUT:
		warp_factor += warp_rate * delta
		if warp_factor >= 1:
			Client.change_system()
			# Play warping down SFX
			# Invert ship position
			state = STATES.WARPING_IN
	
	elif state == STATES.WARPING_IN:
		warp_factor -= warp_rate * delta
		
		if warp_factor <= 0:
			state = STATES.POWERED_DOWN
			warp_factor = 0

	Client.get_background().warp_factor = warp_factor
