extends Node3D

class_name WeaponSlot
		
func _ready():
	var children = get_children()
	if children:
		get_node("../").add_weapon(children[0])
	
func remove_weapon():
	var removed = get_children()[0]
	remove_child(removed)
	get_node("../").remove_weapon(removed)

func add_weapon(weapon: Node):
	add_child(weapon)
	get_node("../").add_weapon(weapon)
