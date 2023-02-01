extends Node

func enter_system(new_system):
	$World3D/players.add_child(Client.player)
	var system: SystemData = Procgen.systems[new_system]
	system.deserialize_entities()  # Probably make this a method on World3D
	SystemGen.do_spawns(Client.current_system_id().to_int() + Client.seed, system, $World3D)

func _ready():
	enter_system.call_deferred(Client.current_system_id())

func leave_system(old_system):
	# Don't free the player
	Client.player.get_node("../").remove_child(Client.player)
	Procgen.systems[old_system].entities = serialize_saved_entities()
	var old_world: Node = $World3D
	remove_child($World3D)
	old_world.queue_free()

func change_system(old_system, new_system):
	leave_system(old_system)
	add_child(preload("res://World3D.tscn").instantiate())
	enter_system.call_deferred(new_system)
	for child in $background/SpobSprites.get_children():
		$background/SpobSprites.remove_child(child)
		
func add_spob_sprite(sprite: Sprite2D):
	$background/SpobSprites.add_child(sprite)

func serialize_saved_entities():
	# TODO: Everything with serial data should probably live in one place to prevent
	# more errors from this sort of code
	var serial_data = {}
	for destination in $World3D.get_children():
		var entities = []
		for entity in destination.get_children():
			if entity.has_method("serialize"):
				entities.append(entity.serialize())
		if entities.size():
			serial_data[destination.name] = entities
	return serial_data
