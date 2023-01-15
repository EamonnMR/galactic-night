extends Node

func enter_system():
	$World3D/players.add_child(Client.player)
	var system: SystemData = Procgen.systems[Client.current_system_id()]
	system.deserialize_entities()  # Probably make this a method on World3D
	SystemGen.do_spawns(Client.current_system_id().to_int() + Client.seed, system, $World3D)
	

func _ready():
	call_deferred("enter_system")

func leave_system():
	# Don't free the player
	Client.player.get_node("../").remove_child(Client.player)
	var old_world: Node = $World3D
	remove_child($World3D)
	old_world.queue_free()

func change_system():
	leave_system()
	add_child(preload("res://World3D.tscn").instantiate())
	call_deferred("enter_system")
	for child in $background/SpobSprites.get_children():
		$background/SpobSprites.remove_child(child)
		
func add_spob_sprite(sprite: Sprite2D):
	$background/SpobSprites.add_child(sprite)

