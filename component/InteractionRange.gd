extends Area3D

var in_range = []

func interact():
	# Interact does something subtily different if you have something selected or don't
	if Client.target_spob:
		if Client.target_spob in in_range:
			Client.target_spob.spob_interact()
	else:
		if Client.mouseover in in_range:
			Client.update_player_target_spob(Client.mouseover)
			Client.target_spob.spob_interact()

func _on_timer_timeout():
	if Client.mouseover_via_mouse == false:
		var candidate = null
		if in_range.size() == 1:
			candidate = in_range[0]
		elif in_range.size() > 1: 
			candidate = Util.closest(
				in_range,
				Util.flatten_25d(global_transform.origin)
			)
		Client.mouseover_entered(candidate, false)

func _on_body_entered(body):
	if body == Client.player:
		return
	in_range.push_back(body)

func _on_body_exited(body):
	in_range.erase(body)
