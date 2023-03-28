extends NinePatchRect

@onready var top_menu_level = get_node("../../")

var seed: int

func set_seed(i: int):
	%SeedSlider.value = i
	%SeedText.text = str(i)
	
func _on_seed_text_changed(new_text):
	set_seed(int(new_text))

func _on_seed_slider_drag_ended(value_changed):
	if value_changed:
		set_seed(%SeedSlider.value)

func _on_new_game_pressed():
	Client.new_game(seed, %PlayerName.text)
	Client.enter_game()
	top_menu_level.switch_to(%MainMenu)
