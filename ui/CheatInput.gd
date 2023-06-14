extends LineEdit

func _on_text_submitted(new_text):
	text = ""
	Cheats.attempt_cheat(new_text)
	hide()
	Client.typing = false


func _on_focus_entered():
	Client.typing = true

func _on_focus_exited():
	Client.typing = false
