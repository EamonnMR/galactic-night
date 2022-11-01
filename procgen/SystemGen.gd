extends Node

func do_spawns(seed_value: int, system_id: String, biome: String, gameplay: Node):
	var rng = RandomNumberGenerator.new()
	print("Seed: ", (seed_value + 10) * system_id.to_int())
	rng.seed = (seed_value + 10) * system_id.to_int()
	var biome_data: BiomeData = Data.biomes[biome]
	for spawn_id in biome_data.spawns:
		var spawn: SpawnData = Data.spawns[spawn_id]
		for _i in range(spawn.count):
			if spawn.chance >= rng.randf():
				var position = Procgen.random_location_in_system(rng)
				var instance: Node = spawn.scene.instantiate()
				if spawn.type:
					instance.type = spawn.type
				instance.transform.origin = Util.raise_25d(position)
				# TODO: This will be important for visual layering
				#gameplay.get_node(spawn.destination).add_child(instance)
				gameplay.add_child(instance)
