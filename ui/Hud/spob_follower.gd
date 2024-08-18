extends Control

var target_spob
var disposition: Util.DISPOSITION = Util.DISPOSITION.ABANDONED

func _ready():
	hide()
	#Client.camera_updated.connect(
		#func _on_camera_updated():
			#if visible and is_instance_valid(Client.target_spob):
				#$SelectionBox.set_radius(Util.item_screen_box_side_length(Client.target_spob))
	#)
	Client.spob_target_updated.connect(
		func _on_target_changed():
			target_spob = Client.target_spob
			if target_spob:
				show()
				$SelectionBox.set_radius(Util.item_screen_box_side_length(target_spob))
				$SelectionBox.set_disposition(Client.get_disposition(target_spob))
				if target_spob.has_signal("destroyed"):
					target_spob.destroyed.connect(_on_target_spob_exited)
				Client.exited_system.connect(_on_target_spob_exited)
	)

func _process(delta):
	if target_spob:
		position = Client.camera.unproject_position(target_spob.global_position)

func _on_target_spob_exited():
	hide()
	target_spob = null
