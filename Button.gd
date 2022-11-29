extends Button

func _on_crafting_visibility_changed():
	visible = get_node("../Crafting").visible
