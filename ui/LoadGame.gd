extends NinePatchRect

func update():
	for available_save in Client.get_available_saved_games():
		var button = Button.new()
		button.text = available_save
		button.pressed.connect(
			func on_button_pressed():
				Client.load_game(available_save)
				Client.enter_game()
		)
		%LoadGamesList.add_child(button)


func _on_open_save_game_folder_pressed():
	OS.shell_open(ProjectSettings.globalize_path(Client.SAVE_FILE))
