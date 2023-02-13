extends Control

var target
var disposition: Util.DISPOSITION = Util.DISPOSITION.ABANDONED

func _ready():
	Client.exited_system.connect(_on_target_ship_exited)
	hide()
	Client.mouseover_updated.connect(
		func _on_target_changed():
			if Client.mouseover != null:
				$Timer.start()
				target = Client.mouseover
				show()
				# TODO: Resize to target size
				$SelectionBox.set_radius(Util.item_screen_box_side_length(target))
				$SelectionBox.set_disposition(Client.get_disposition(target))
				if target.has_signal("destroyed"):
					if not target.destroyed.is_connected(_on_target_ship_exited):
						target.destroyed.connect(_on_target_ship_exited)
			else:
				if is_instance_valid(target) and target.has_signal("destroyed"):
					target.destroyed.disconnect(_on_target_ship_exited)
				hide()
				target = null
	)

func _process(delta):
	if target:
		if not is_instance_valid(target):
			_on_target_ship_exited()
		else:
			position = Client.camera.unproject_position(target.global_position)

func _on_target_ship_exited():
	if target and Client.mouseover_via_mouse:
		Client.mouseover_entered(null, false)
		target = null
