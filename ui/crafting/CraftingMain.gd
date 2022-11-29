extends Control

@onready var craft_tabs = get_node("NinePatchPanel/MarginContainer/TabContainer/").get_children()

func rebuild():
	for tab in craft_tabs:
		tab.rebuild()
	

func assign(crafting_level_node):
	for tab in craft_tabs:
		tab.assign(crafting_level_node)

func unassign():
	for tab in craft_tabs:
		tab.unassign()


func _on_craft_button_pressed():
	get_node("NinePatchPanel/MarginContainer/TabContainer/").get_current_tab_control()._on_CraftButton_pressed()
