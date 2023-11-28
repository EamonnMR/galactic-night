extends Node3D

class_name WeaponSlot

@export var turret: bool

var turn = PI*2

func _process(delta):
	if turret and $Controller.ideal_face:
		global_rotation.y = $Controller.ideal_face

func _ready():
	var children = get_children()
	if children:
		get_node("../").add_weapon(children[0])
	
	if turret:
		var controller: PackedScene = preload("res://component/controllers/turret_controller.tscn")
		add_child(controller.instantiate())

func remove_weapon():
	var removed = get_children()[0]
	remove_child(removed)
	get_node("../").remove_weapon(removed)

func add_weapon(weapon: Node):
	add_child(weapon)
	get_node("../").add_weapon(weapon)
