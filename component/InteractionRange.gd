extends Area3D

var in_range = []

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
