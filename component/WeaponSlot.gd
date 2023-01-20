extends Node3D

class_name WeaponSlot

func inform_parent(weapon: Node):
	# TODO: Secondary weapons also
	if weapon.primary:
		get_parent().primary_weapons.push_back(weapon)
	else:
		get_parent().secondary_weapons.push_back(weapon)
	
func inform_parent_removed(weapon: Node):
	# TODO: Secondary weapons also
	if weapon.primary:
		get_parent().primary_weapons.erase(weapon) 
	else:
		get_parent().secondary_weapons.erase(weapon)
		
func _ready():
	var children = get_children()
	if children:
		inform_parent(children[0])
	
func remove_weapon():
	var removed = get_children()[0]
	remove_child(removed)
	inform_parent_removed(removed)

func add_weapon(weapon: Node):
	add_child(weapon)
	inform_parent(weapon)
