extends Node

var asteroid_count = 4

func _ready():
	SystemGen.do_spawns(1, 0, start, $World3D)
