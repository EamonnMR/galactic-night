extends Node

# For incidental randomness in systems

func get_faction_spawns(system: SystemData):
	if system.faction == "":
		return []
	var faction = Data.factions[system.faction]
	return faction.spawns_system + (faction.spawns_core if system.core else [])

func get_adjacent_spawns(system: SystemData) -> Array[String]:
	# TODO: Adjacency Radius
	var adjacent_spawns: Array[String] = []
	for other_system_id in system.links_cache:
		var other_system = Procgen.systems[other_system_id]
		if other_system.faction != "":
			var faction: FactionData = Data.factions[other_system.faction]
			var adjacent_for_faction: Array[String] 
			adjacent_for_faction.assign(faction.spawns_adjacent)
			adjacent_spawns.append_array(adjacent_for_faction)
	return adjacent_spawns

func get_special_system_spawns(system):
	if system.static_system_id != "":
		return Data.static_systems[system.static_system_id].spawns
	return []
	
func do_spawns(seed_value: int, system: SystemData, gameplay: Node):
	var rng = RandomNumberGenerator.new()
	print("Seed: ", (seed_value + 10) * system.id.to_int())
	rng.seed = (seed_value + 10) * system.id.to_int()
	var biome_data: BiomeData = Data.biomes[system.biome]
	for spawn_id in (
		biome_data.spawns +
		get_special_system_spawns(system) +
		get_faction_spawns(system) +
		get_adjacent_spawns(system) +
		Data.evergreen_spawns
	):
		var spawn: SpawnData = Data.spawns[spawn_id]
		print(spawn.id)
		if not spawn.preset:
			var entities = spawn.do_spawns(rng)
			for instance in entities:
				gameplay.get_node(spawn.destination).add_child(instance)
