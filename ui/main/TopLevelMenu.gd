extends CanvasLayer

func switch_to(new_child):
	for child in $Control.get_children():
		child.hide()
	new_child.show()
