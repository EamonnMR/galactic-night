extends Label

var warp_cond: bool = false

const COLORS = {
	true: Color("ffffff"),
	false: Color(1, 1, 1, 0.5)
}

func _ready():
	Client.selected_system_updated.connect(update)

func update():
	if not is_instance_valid(Client.player):
		warp_cond = false
		hide()
		return
	
	if not Client.valid_jump_destination_selected():
		warp_cond = false
		hide()
		return
	
	var dest = Procgen.systems[Client.selected_system]
	text = "Hyperspace: %s" % dest.name if dest.explored else "Unexplored System"
	show()
	
	if not Client.player.get_node("Controller").warp_conditions_met():
		label_settings.font_color = COLORS[false]
		return
	
	label_settings.font_color = COLORS[true]
	
	if not warp_cond:
		warp_cond = true
		# Play sound cue
		# Display hyperspace ready message
