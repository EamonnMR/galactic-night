extends Node

var warp_factor = 0.0

var warp_rate = 0.5

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
		Client.get_foreground().warp_angle = Util.flatten_rotation(get_node("../"))
		return true
	else:
		return false

func warp_transition():
	Client.change_system()
	# Play warping down SFX
	var old_origin = Util.flatten_25d(Client.player.transform.origin)
	Client.player.transform.origin = Util.raise_25d(
		Vector2(Util.PLAY_AREA_RADIUS * 0.75, 0).rotated(Util.flatten_rotation(get_node("../")))
	) * -1
	#Client.player.transform.origin *= -10
	var new_origin = Util.flatten_25d(Client.player.transform.origin)
	#breakpoint
	state = STATES.WARPING_IN

func _process(delta):
	# Client.get_background().warp_angle = Util.flatten_rotation(get_node("../"))
	if state == STATES.POWERED_DOWN:
		return
	
	if state == STATES.WARPING_OUT:
		Client.display_message("WARPING OUT")
		warp_factor += warp_rate * delta
		if warp_factor >= 1:
			warp_transition()
	
	elif state == STATES.WARPING_IN:
		Client.display_message("WARPING IN")
		warp_factor -= warp_rate * delta
		
		if warp_factor <= 0:
			state = STATES.POWERED_DOWN
			warp_factor = 0

	Client.get_background().warp_factor = warp_factor
	Client.get_foreground().warp_factor = warp_factor
