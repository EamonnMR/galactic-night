extends Node

func get_faction_spawns(system: SystemData) -> Array[String]:
	if system.faction == "":
		return []
	var faction = Data.factions[system.faction]
	return faction.spawns_system + (faction.spawns_core if system.core else [])

func get_adjacent_spawns(system: SystemData) -> Array[String]:
	var adjacent_spawns = []
	for other_system_id in system.links_cache:
		var other_system = Procgen.systems[other_system_id]
		if other_system.faction != "":
			adjacent_spawns += Data.factions[other_system.faction].spawns_adjacent
	return adjacent_spawns

func do_spawns(seed_value: int, system: SystemData, gameplay: Node):
	var rng = RandomNumberGenerator.new()
	print("Seed: ", (seed_value + 10) * system.id.to_int())
	rng.seed = (seed_value + 10) * system.id.to_int()
	var biome_data: BiomeData = Data.biomes[system.biome]
	for spawn_id in (
		biome_data.spawns +
		get_faction_spawns(system) +
		get_adjacent_spawns(system) +
		Data.evergreen_spawns
	):
		var spawn: SpawnData = Data.spawns[spawn_id]
		print(spawn.id)
		for _i in range(spawn.count):
			if spawn.chance >= rng.randf():
				var position = Procgen.random_location_in_system(rng)
				var instance: Node
				if spawn.data_type != "":
					instance = Data.get(spawn.data_type)[spawn.type].scene.instantiate()
				else:
					instance = spawn.scene.instantiate()
				if spawn.type != null and spawn.type != "":
					instance.type = spawn.type
				if "faction" in instance:
					instance.faction = str(spawn.faction)
				instance.transform.origin = Util.raise_25d(position)
				# TODO: This will be important for visual layering
				gameplay.get_node(spawn.destination).add_child(instance)
