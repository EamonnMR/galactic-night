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
	for faction_id in system.adjacency:
		adjacent_spawns.append_array(Data.factions[faction_id].spawns_adjacent)
	return adjacent_spawns

func get_special_system_spawns(system):
	if system.static_system_id != "":
		return Data.static_systems[system.static_system_id].spawns
	return []
	
func get_chain_spawns(system):
	var chain_spawns = []
	for entity in get_tree().get_nodes_in_group("chain_spawners"):
		if "chain_spawns" in entity:
			chain_spawns += entity.chain_spawns
	return chain_spawns
	
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
		get_chain_spawns(system) +
		Data.evergreen_spawns
	):
		var spawn: SpawnData = Data.spawns[spawn_id]
		print(spawn.id)
		if not spawn.preset:
			if spawn.valid_for_quadrant(system.quadrant):
				var entities = spawn.do_spawns(rng)
				for instance in entities:
					gameplay.get_node(spawn.destination).add_child(instance)
