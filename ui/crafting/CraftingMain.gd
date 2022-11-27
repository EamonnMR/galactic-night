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
