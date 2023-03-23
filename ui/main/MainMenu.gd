extends TextureRect

@onready var top_menu_level = get_node("../../")

func _on_new_pressed():
	Client.new_game(1, "Shannon Merrol")
	Client.enter_game()

func _on_load_pressed():
	top_menu_level.switch_to(%LoadGame)

func _on_save_pressed():
	Client.save_game()

func _on_quit_pressed():
	get_tree().quit()

func _on_continue_pressed():
	Client.toggle_pause()


func _on_visibility_changed():
	if is_instance_valid(Client.player):
		$Continue.disabled = false
	else:
		$Continue.disabled = true
