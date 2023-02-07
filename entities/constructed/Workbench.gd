extends StaticBody3D

func screen_box_side_length():
	return 400

func display_name():
	return "Workbench"
	
func display_type():
	return "Station"

func _ready():
	add_to_group("radar-spobs")
	add_to_group("player-assets")
	input_event.connect(
		func _on_input_event(_camera, event, _click_position, _camera_normal, _shape):
			#https://stackoverflow.com/questions/58628154/detecting-click-touchscreen-input-on-a-3d-object-inside-godot
			var mouse_click = event as InputEventMouseButton
			if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed:
				Client.update_player_target_spob(self)
			else:
				Client.mouseover_entered(self)
	)


func serialize() -> Dictionary:
	return Util.get_multiple(self, [
		"transform",
		"scene_file_path"
	])

func deserialize(data: Dictionary):
	Util.set_multiple(self, data)

func spob_interaction():
	breakpoint
