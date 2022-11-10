extends Node


func get_faction_spawns(system: SystemData) -> Array[String]:
	var faction = Data.factions[system.faction]
	return faction.spawns_system + (faction.spawns_core if system.core else [])

func get_near_spawns(system: SystemData) -> Array[String]:
	return []
	
func get_evergreen_spawns(system: SystemData) -> Array[String]:
	return []

func do_spawns(seed_value: int, system: SystemData, gameplay: Node):
	var rng = RandomNumberGenerator.new()
	print("Seed: ", (seed_value + 10) * system.id.to_int())
	rng.seed = (seed_value + 10) * system.id.to_int()
	var biome_data: BiomeData = Data.biomes[system.biome]
	for spawn_id in (
		biome_data.spawns +
		get_faction_spawns(system) +
		get_near_spawns(system) +
		get_evergreen_spawns(system)
	):
		var spawn: SpawnData = Data.spawns[spawn_id]
		print(spawn.id)
		for _i in range(spawn.count):
			if spawn.chance >= rng.randf():
				var position = Procgen.random_location_in_system(rng)
				var instance: Node = spawn.scene.instantiate()
				if spawn.type != null and spawn.type != "":
					instance.type = spawn.type
				if "faction" in instance:
					instance.faction = str(spawn.faction)
				instance.transform.origin = Util.raise_25d(position)
				# TODO: This will be important for visual layering
				gameplay.get_node(spawn.destination).add_child(instance)
