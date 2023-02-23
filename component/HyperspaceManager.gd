extends Node

var warp_factor = 0.0

var warp_rate = 1.0

enum STATES {
	POWERED_DOWN,
	WARPING_OUT,
	WARPING_IN
}

var state: STATES

func start_warp():
	if state == STATES.POWERED_DOWN:
		state = STATES.WARPING_OUT
		Client.get_background().warp_vector = Vector2(1,0).rotated(PI)
		return true
	else:
		return false

func _process(delta):
	if state == STATES.POWERED_DOWN:
		return
	
	if state == STATES.WARPING_IN:
		warp_factor += warp_rate * delta
		
		if warp_factor >= 1:
			Client.change_system()
			# Play warping down SFX
			# Invert ship position
			state = STATES.WARPING_OUT
	
	elif state == STATES.WARPING_OUT:
		warp_factor -= warp_rate * delta
		
		if warp_factor <= 0:
			state = STATES.POWERED_DOWN

	Client.get_background().warp_factor = warp_factor
