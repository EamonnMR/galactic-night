extends Node

func enter_system():
	var system: SystemData = Procgen.systems[Client.current_system_id()]
	SystemGen.do_spawns(1, Client.current_system_id(), system.biome, $World3D)

func _ready():
	call_deferred("enter_system")
