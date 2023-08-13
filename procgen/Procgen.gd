extends Node

var RADIUS = 1000
#var RADIUS = 500
var DENSITY = 1.0/3000.0
var SYSTEMS_COUNT = int(RADIUS * RADIUS * DENSITY)
var systems = {}
var hyperlanes = []
var longjumps = []
var hypergate_links = []

var MIN_DISTANCE = 50
var MAX_LANE_LENGTH = 130
var MAX_GROW_ITERATIONS = 3
var SEED_DENSITY = 1.0/5.0
var quadrant_cache = {}


var quadrant_permutations_cache = {}
var systems_by_position = {}
@onready var rng: RandomNumberGenerator


func serialize() -> Dictionary:
	# Make sure you cache state from the current system
	var serial_systems = {}
	var serial_hyperlanes = []
	var serial_longjumps = []
	
	for system_id in systems:
		serial_systems[system_id] = systems[system_id].serialize()
	for jump in hyperlanes:
		serial_hyperlanes.append([jump.lsys, jump.rsys])
	for jump in longjumps:
		serial_longjumps.append([jump.lsys, jump.rsys])
	return {
		"systems": serial_systems,
		"hyperlanes": serial_hyperlanes,
		"longjumps": serial_longjumps
	}
	
func deserialize(data: Dictionary):
	systems = {}
	hyperlanes = []
	longjumps = []
	for system_id in data["systems"]:
		var system = SystemData.new()
		system.deserialize(data["systems"][system_id])
		systems[system_id] = system
	for lane in data["hyperlanes"]:
		hyperlanes.append(HyperlaneData.new(lane[0], lane[1]))
	for lane in data["longjumps"]:
		longjumps.append(HyperlaneData.new(lane[0], lane[1]))


func random_location_in_system(rng: RandomNumberGenerator):
	return random_circular_coordinate(rng.randf() * Util.PLAY_AREA_RADIUS / 2.0, rng)

func generate_systems(seed_value: int) -> String:
	# Returns the id of the system that "start" gets put in
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	print("Seed Value: ", seed_value)
	
	generate_positions_and_links()
	cache_links()
	calculate_system_distances()
	calculate_system_quadrants()
	var start_sys = place_static_systems()
	place_preset_static_spawns()
	populate_biomes()
	place_natural_static_spawns()
	populate_factions()
	name_systems()
	place_artificial_static_spawns()
	connect_hyperspace_relays()
	setup_trade()
	# Remember, we had a return value. Client needs to know which system to start in.
	return start_sys

func populate_biomes():
	place_biome_seeds()
	grow_biome_seeds()
	fill_remaining_empty_biomes()

func get_system_set_by_quadrants(quadrants: Array) -> Array:
	if quadrants in quadrant_permutations_cache:
		return quadrant_permutations_cache[quadrants]
	var set: Array = []
	for i in quadrants:
		set += quadrant_cache[i]
	quadrant_permutations_cache[quadrants] = set
	return set

func place_static_systems():
	var start_sys
	
	for static_system_id in Data.static_systems:
		var static_system = Data.static_systems[static_system_id]
		while true:
			var system_id = random_select(get_system_set_by_quadrants(static_system.quadrants), rng)
			var system = systems[system_id]
			if systems[system_id].static_system_id == "":
				system.biome = static_system.biome
				system.explored = static_system.auto_explore
				system.name = static_system.name
				system.faction = static_system.faction_id
				system.static_system_id = static_system_id
				if static_system.startloc:
					start_sys = system_id
				break
			else:
				print("Cannot put special_system in an occupied system: ", system_id, " static system id ", static_system_id)
	return start_sys
	
func place_biome_seeds():
	
	var seed_biomes = []
	
	for biome_id in Data.biomes:
		if Data.biomes[biome_id].do_seed:
			seed_biomes.append(biome_id)
	
	var seed_count = int(systems.size() * SEED_DENSITY)
	var seeds_planted = 0
	while seeds_planted < seed_count:
		var biome_id = random_select(seed_biomes, rng)
		var system_id = random_select(systems.keys(), rng)
		if systems[system_id].biome == "":
			systems[system_id].biome = biome_id
			_set_light(systems[system_id], Data.biomes[biome_id])
			seeds_planted += 1

func grow_biome_seeds():
	for _i in MAX_GROW_ITERATIONS:
		print("Growing Seeds")
		for system in systems.values():
			if system.biome == "":
				var possible_biomes = []
				
				# Preferentially use the links cache
				for list in [system.links_cache, system.long_links_cache]:
					for link in list:
						var other_system = systems[link]
						if other_system.biome and Data.biomes[other_system.biome].grow:
							possible_biomes.append(other_system.biome)
				if possible_biomes.size():
					system.biome = random_select(possible_biomes, rng)
					# TODO: Names - per - biome
					#system.name = random_name(system, rng)
					#_set_light(system, Data.biomes[system.biome])

func fill_remaining_empty_biomes():
	# Fill in any systems that somehow fell through the cracks
	for system in systems.values():
		if system.biome == "":
			system.biome = Data.biomes.keys()[0]

func grow_attribute(_attribute):
	pass

func generate_positions_and_links():
	for i in SYSTEMS_COUNT:
		var system_id = str(i)
		var system = SystemData.new()
		system.id = system_id
		# Avoid overlap
		var position = _get_non_overlapping_position(rng)
		if position:
			system.position = position
			systems[system_id] = system
			systems_by_position[position] = system_id
	
	for edge in get_linkmesh_edges_from_points(systems_by_position.keys()):
		var first = systems_by_position[edge[0]]
		var second = systems_by_position[edge[1]]
		
		if Vector2(edge[0]).distance_to(edge[1]) < MAX_LANE_LENGTH:
			hyperlanes.append(HyperlaneData.new(first, second))
		else:
			longjumps.append(HyperlaneData.new(first, second))


func cache_links():
	for lane in hyperlanes:
		var lsys = systems[lane.lsys]
		var rsys = systems[lane.rsys]
		if not lane.rsys in lsys.links_cache:
			lsys.links_cache.append(lane.rsys)
		if not lane.lsys in rsys.links_cache:
			rsys.links_cache.append(lane.lsys)
	
	for lane in longjumps:
		var lsys = systems[lane.lsys]
		var rsys = systems[lane.rsys]
		if not lane.rsys in lsys.links_cache:
			lsys.long_links_cache.append(lane.rsys)
		if not lane.lsys in rsys.links_cache:
			rsys.long_links_cache.append(lane.lsys)


func _get_non_overlapping_position(rng: RandomNumberGenerator):
	var max_iter = 10
	var bad_position = true
	var position = Vector2()
	for _i in range(max_iter):
		position = random_circular_coordinate(RADIUS, rng)
		bad_position = false
		for key in systems:
			var other_system: SystemData = systems[key]
			if other_system.position.distance_to(position) < MIN_DISTANCE:
				bad_position = true
				break
		if not bad_position:
			return position
	print("Cannot find a suitable position for system in ", max_iter, " iterations")
	return null

func populate_factions():
	print("Populate factions")
	assign_faction_core_worlds()
	assign_peninsula_bonus_systems()
	grow_faction_influence_from_core_worlds()
	


func assign_faction_core_worlds() -> Array:
	print("Randomly Assigning core worlds ")
	var sorted = systems_sorted_by_distance()
	var sorted_reverse = sorted.duplicate()
	sorted_reverse.reverse()
	var already_selected = []
	for faction_id in Data.factions:
		var faction = Data.factions[faction_id]
		var i = 0
		var system_count = int(int(faction.core_systems_per_hundred) * (systems.size() / 100))
		while i < system_count:
			var rnd_result = abs(rng.randfn(0.0))
			var scale = int(faction.favor_galactic_center)
			var scaled_rnd_result = 0
			if scale:
				scaled_rnd_result = int(rnd_result * (sorted.size() / scale))
			else:
				print(0, sorted.size())
				scaled_rnd_result = rng.randi_range(0, sorted.size())
			# TODO: This code kinda baffles me, but it's happening a lot.
			# Fix it and we can get a decent perf improvement
			if scaled_rnd_result >= sorted.size() or scaled_rnd_result <= - sorted.size():
				# print("Long tail too long: ", rnd_result, " (", scaled_rnd_result, ")")
				continue
			var system_id = sorted[scaled_rnd_result]
			if system_id in already_selected:
				print("Collision: ", system_id)
				continue
			else:
				systems[system_id].faction = faction_id
				systems[system_id].core = true
				systems[system_id].generation = 0
				# add_npc_spawn(Game.systems[system_id], faction_id, int(faction["npc_radius"]) + int(faction["systems_radius"]))
				already_selected.append(system_id)
				i += 1
	print("Core worlds assigned: ", already_selected.size())
	return already_selected

func assign_peninsula_bonus_systems() -> Array:
	# The 'peninsula bonus' field lets you add core worlds to systems with only one link.
	# This adds a little flavor.
	var peninsula_factions = []
	var core_systems = []
	for faction_id in Data.factions:
		var faction = Data.factions[faction_id]
		if faction.peninsula_bonus:
			peninsula_factions.append(faction_id)
	var i = 0
	if peninsula_factions.size():
		print("Assigning factions to systems with only one connection")
		for system_id in systems:
			var system = systems[system_id]
			if system.links_cache.size() == 1 and system.faction == "":
				# TODO: Randomize, don't just iterate through
				system["faction"] = peninsula_factions[i]
				# add_npc_spawn(system, peninsula_factions[i], 10)
				core_systems.append(system_id)
				i += 1
				if i == peninsula_factions.size():
					i = 0
	return core_systems

func grow_faction_influence_from_core_worlds():
	# TODO: This is obviously not optimal
	print("Growing faction influence")
	for faction_id in Data.factions:
		var faction = Data.factions[faction_id]
		for i in range(faction.systems_radius):
			print("Full iteration: ", faction["name"], ", iteration: ", i)
			var marked_systems = []
			for system_id in systems:
				var system = systems[system_id]
				for link_id in system.links_cache:
					var link_system = systems[link_id]
					if "faction" in link_system and link_system.faction == faction_id:
						marked_systems.append(system_id)
						break
			for system_id in marked_systems:
				var system = systems[system_id]
				system.faction = faction_id
				system.generation = i
	print("Factions grown")

func name_systems():
	for system_id in systems:
		var system = systems[system_id]
		if system.name == "":
			system.name = random_name(system, "NGC-")
		
func place_natural_static_spawns():
	# TODO: This is causing an issue.
	print("Place natural static spawns")
	place_static_spawns(
		func(system):
			return Data.biomes[system.biome].spawns +  Data.evergreen_natural_spawns
	)

func place_artificial_static_spawns():
	print("Place artificial static spawns")
	place_static_spawns(
		func(system):
			if system.faction == null or system.faction == "":
				return Data.evergreen_artificial_spawns
			
			var faction = Data.factions[system.faction]
			return (
				faction.spawns_system
				+ Data.evergreen_artificial_spawns
				+ (faction.spawns_core if system.core else [])
			)
	)
	
func place_preset_static_spawns():
	print("Place static spawns for static systems")
	place_static_spawns(
		func(system):
			if system.static_system_id == "":
				return []
			return Data.static_systems[system.static_system_id].spawns
	)

func place_static_spawns(get_spawns: Callable):
	for system_id in systems:
		var system = systems[system_id]
		var spawns = get_spawns.call(system)
		for spawn_id in spawns:
			var spawn = Data.spawns[spawn_id]
			if spawn.preset:
				print(system_id)
				var entities = spawn.do_spawns(rng)
				var i: int = 0
				var center_entities = []
				for entity in entities:
					if "spob_name" in entity:
						entity.spob_name = random_name(system, entity.spob_prefix, "-" + ['A', 'B', 'C', 'D', 'E', 'H', 'I', 'J'][i])
					if "is_planet" in entity and entity.is_planet:
						entity.type = random_select(Data.spob_types.keys(), rng)
					if "center_system" in entity and entity.center_system:
						center_entities.append(entity)
					i += 1
				if center_entities.size() == 1:
					center_entities.transform.origin = Vector3(0,0,0)
				if not (spawn.destination in system.entities):
					system.entities[spawn.destination] = []
				for instance in entities:
					system.entities.spobs += [instance.serialize()]

					
func random_name(sys: SystemData, default_prefix: String, default_postfix: String = ""):
	if sys.faction != "" and sys.faction != "0":
		var name_scheme = Data.factions[sys.faction].sys_name_scheme
		print("Current name scheme", name_scheme)
		return Data.name_generators[ name_scheme ].get_random_name()
	else:
		return default_prefix + sys.id + default_postfix

func random_circular_coordinate(radius: int, rng: RandomNumberGenerator) -> Vector2:
	return radius * Vector2(sqrt(rng.randf()), 0).rotated(PI * 2 * rng.randf())

func random_select(iterable, rng: RandomNumberGenerator):
	#Remember to seed the rng
	return iterable[rng.randi() % iterable.size()]


func _set_light(system: SystemData, biome: BiomeData):
	system.ambient_color = biome.ambient_color
	system.starlight_color = biome.starlight_color

func calculate_system_distances():
	var sum_position = Vector2(0,0)
	
	for system_id in systems:
		var system = systems[system_id]
		sum_position += system.position
		
	var mean_position = sum_position / systems.size()

	var max_distance = 0
	for system_id in systems:
		var system = systems[system_id]
		system.distance = mean_position.distance_to(system.position)
		if system.distance > max_distance:
			max_distance = system.distance
		
	for system_id in systems:
		var system = systems[system_id]
		system.distance_normalized = system.distance / max_distance

func calculate_system_quadrants():
	for quadrant in ['A', 'B', 'C', 'D']:
		var cache_member: Array = []
		quadrant_cache[quadrant] = cache_member
	for system_id in systems:
		var system = systems[system_id]
		system.quadrant = assign_quadrant(system.position)
		quadrant_cache[system.quadrant].push_back(system_id)
func assign_quadrant(position: Vector2) -> String:
	var normalized_position = sign(position)
	match normalized_position:
		Vector2(1,1):
			return "A"
		Vector2(1,-1):
			return "B"
		Vector2(-1,-1):
			return "C"
		Vector2(-1,1):
			return "D"
		
	return "A"
			
func system_distance_comparitor(l_id, r_id) -> bool:
	var lval = systems[l_id]["distance"]
	var rval = systems[r_id]["distance"]
	return lval < rval

func systems_sorted_by_distance() -> Array:
	var system_ids = systems.keys()
	system_ids.sort_custom(Callable(self,"system_distance_comparitor"))
	return system_ids

func connect_hyperspace_relays():
	var systems_with_hypergates = {}
	var positions_of_systems_with_hypergates = []
	for system_id in systems:
		var system = systems[system_id]
		if "spobs" in system.entities:
			for entity in system.entities.spobs:
				if "hypergate_links" in entity:
					systems_with_hypergates[system_id] = entity.spob_name
					positions_of_systems_with_hypergates.append(system.position)

	for edge in get_linkmesh_edges_from_points(positions_of_systems_with_hypergates):
		var first = systems_by_position[edge[0]]
		var second = systems_by_position[edge[1]]
		
		var first_gate_id = systems_with_hypergates[first]
		var second_gate_id = systems_with_hypergates[second]
		
		for entity in systems[first].entities:
			if "hypergate_links" in entity:
				entity.hypergate_links.append(systems_with_hypergates[second])

		for entity in systems[second].entities:
			if "hypergate_links" in entity:
				entity.hypergate_links.append(systems_with_hypergates[first])
	
		hypergate_links.append(HyperlaneData.new(first, second))
	
func setup_trade():
	# Setup commodities
	var commodities = []
	for item in Data.items.values():
		if item.commodity:
			commodities.push_back(item.id)
	for system in systems.values():
		var system_wide_commodity_prices = {}
		for item in Data.items.values():
			if item.commodity:
				system_wide_commodity_prices[item.id] = random_select(ItemData.CommodityPrice.values(), rng)
		if "spobs" in system.entities:
			for entity in system.entities.spobs:
				if "available_items" in entity and entity.inhabited:
					for commodity in system_wide_commodity_prices:
						if random_select([true, false], rng):
							entity.available_items[commodity] = system_wide_commodity_prices[commodity]

func get_linkmesh_edges_from_points(source_points):
	# This mostly deals with the slightly odd format expected by triangulate_delaunay
	
	var points = PackedVector2Array(source_points)
	var link_mesh = Geometry2D.triangulate_delaunay(points)
	
	var edge_counts = {}
	
	for i in range(0, link_mesh.size(), 3):
		var tri = [
			link_mesh[i],
			link_mesh[i+1],
			link_mesh[i+2]
		]
		for edge in [
			[tri[0], tri[1]],
			[tri[1], tri[2]],
			[tri[0], tri[2]],
		]:
			edge.sort()
			if edge in edge_counts:
				edge_counts[edge] += 1
			else:
				edge_counts[edge] = 1
	var linkmesh_edges = []
	for edge in edge_counts:
		if edge_counts[edge] >= 2:
			linkmesh_edges.append(
				[points[edge[0]], points[edge[1]]]
			)
	return linkmesh_edges
