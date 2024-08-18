extends Controller
class_name JumpAutopilotController

# This implements the shared behavior for warp autopilot
# For the animated portion, see HyperspaceManager

var warp_aligned = false

# var WARP_MARGIN = 0.1
var WARP_MARGIN = 0.03
#var WARP_MAX_SPEED = 0.1
var WARP_MAX_SPEED = 0.1
var warp_dest_system

func complete_jump():
	pass
	
func complete_warp_conditions_met() -> bool:
	return Util.out_of_system_radius(parent, Util.PLAY_AREA_RADIUS * 0.8) \
		and parent.linear_velocity.length() >= parent.max_speed * 0.9

func warp_conditions_met() -> bool:
	return Util.out_of_system_radius(parent, Util.JUMP_DISTANCE) and not parent.warping_in

func process_warping_out(delta):
	shooting = false
	if not warp_aligned:
		setup_backstop_timer()
		braking = true
		process_rotation(delta)
		thrusting = false
		braking = true
		if _facing_within_margin(WARP_MARGIN) and parent.linear_velocity.length() <= WARP_MAX_SPEED:
			warp_aligned = true
	else:
		rotation_impulse = 0
		thrusting = true
		braking = false
		if complete_warp_conditions_met():
			warp_aligned = false
			$WarpBackstopTimer.stop()
			complete_jump()

func process_rotation(delta):
	var rot_2d = Util.flatten_rotation(parent)
	var max_turn = parent.turn * delta
	ideal_face = get_ideal_face()
	rotation_impulse = Util.get_ideal_turn_for_ideal_face(
		ideal_face, rot_2d, max_turn
	)

func get_ideal_face():
	return (Procgen.systems[warp_dest_system].position
	- Procgen.systems[Client.current_system].position).angle() + 2*PI

func setup_backstop_timer():
	if has_node("WarpBackstopTimer"):
		if $WarpBackstopTimer.is_stopped():
			$WarpBackstopTimer.wait_time = 15 / parent.turn
			#Client.display_message("Backstop timer started, waiting " + str($WarpBackstopTimer.wait_time) + " seconds")
			$WarpBackstopTimer.start()
		return
		
	var timer = Timer.new()
	timer.name = "WarpBackstopTimer"
	timer.one_shot = true
	timer.autostart = true
	timer.wait_time = 15 / parent.turn
	#Client.display_message("Backstop timer started, waiting " + str(timer.wait_time) + " seconds")
	timer.timeout.connect(
		func WarpBackstopTimerComplete():
			var angle_diff = abs(ideal_face - Util.flatten_rotation(parent))
			#Client.display_message("Warp Backstop Timer hit; Speed " + str(parent.linear_velocity.length()) + ", angle error: " + str(angle_diff) )
			warp_aligned = true
	)
	
	add_child(timer)
