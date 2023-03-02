extends Controller
class_name JumpAutopilotController

# This implements the shared behavior for warp autopilot
# For the animated portion, see HyperspaceManager

var warp_aligned = false

var WARP_MARGIN = 0.1

var WARP_MAX_SPEED = 0.1

var warp_dest_system

func complete_jump():
	pass
	
func complete_warp_conditions_met() -> bool:
	return Util.out_of_system_radius(parent, Util.PLAY_AREA_RADIUS * 0.8) \
		and parent.linear_velocity.length() >= parent.max_speed * 0.9

func warp_conditions_met() -> bool:
	return Util.out_of_system_radius(parent, Util.JUMP_DISTANCE) and not parent.warping_in

func get_imagionary_position_of_other_system() -> Vector2:
	return (Procgen.systems[warp_dest_system].position
	- Procgen.systems[Client.current_system].position) * 100000

func process_warping_out(delta):
	shooting = false
	if not warp_aligned:
		braking = true
		populate_rotation_impulse_and_ideal_face(get_imagionary_position_of_other_system(), delta)
		
		thrusting = false
		braking = not thrusting
		
		if _facing_within_margin(WARP_MARGIN) and parent.linear_velocity.length() <= WARP_MAX_SPEED:
			warp_aligned = true
	else:
		rotation_impulse = 0
		thrusting = true
		braking = false
		if complete_warp_conditions_met():
			complete_jump()
