extends Node

var player
var camera
signal system_selection_updated
@onready var current_system = Procgen.generate_systems(0)
var selected_system = null
var selected_system_circle_cache = []

func current_system_id():
	return current_system

func map_select_system(system_id, system_node):
	sel_sys(system_id, system_node)
	emit_signal("system_selection_updated")

func sel_sys(system_id: String, node):
	selected_system = system_id
	for old_node in selected_system_circle_cache:
		old_node.redraw()
	selected_system_circle_cache = [node]
	# TODO: If we're in immediate jump mode, toggle out of the map and initiate a jump

func change_sys():
	get_main().change_system()

func get_world():
	return get_main().get_node("World3D")

func get_main():
	return get_tree().get_root().get_node("Main")
