extends Node

func enter_system():
	Client.player = $World3D/players.get_children()[0]
	var system: SystemData = Procgen.systems[Client.current_system_id()]
	SystemGen.do_spawns(Client.current_system_id().to_int() + Client.seed, Client.current_system_id(), system.biome, $World3D)

func _ready():
	call_deferred("enter_system")

func leave_system():
	var old_world: Node = $World3D
	remove_child($World3D)
	old_world.queue_free()

func change_system():
	leave_system()
	add_child(preload("res://World3D.tscn").instantiate())
	call_deferred("enter_system")
