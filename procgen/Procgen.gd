extends Node

var RADIUS = 1000
var DENSITY = 1.0/3000.0
var SYSTEMS_COUNT = int(RADIUS * RADIUS * DENSITY)
var systems = {}
var hyperlanes = []
var longjumps = []
var MIN_DISTANCE = 50
var MAX_LANE_LENGTH = 130
var MAX_GROW_ITERATIONS = 3
var SEED_DENSITY = 1.0/5.0

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


func _random_location_in_system(rng: RandomNumberGenerator):
	return random_circular_coordinate(1000, rng)

#func do_spawns(seed_value: int, system_id: String, biome: String, gameplay: Node):
#	var rng = RandomNumberGenerator.new()
#	print("Seed: ", (seed_value + 10) * int(system_id))
#	rng.seed = (seed_value + 10) * int(system_id)
#	var biome_data: BiomeData = Data.biomes[biome]
#	for spawn_id in biome_data.spawns:
#		var spawn: SpawnData = Data.spawns[spawn_id]
#		for _i in range(spawn.count):
#			if spawn.chance >= rng.randf():
#				var position = _random_location_in_system(rng)
#				var instance: Node = spawn.scene.instance()
#				if spawn.type:
#					instance.type = spawn.type
#				instance.position = position
#				gameplay.get_node(spawn.destination).add_child(instance)

func generate_systems(seed_value: int) -> String:
	# Returns the id of the system that "start" gets put in
	var start_sys: String
	
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	print("Seed Value: ", seed_value)
	
	# Generate Systems
	
	var systems_by_position = {}
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
	var points = PoolVector2Array(systems_by_position.keys())
	var link_mesh = Geometry.triangulate_delaunay_2d(points)
	for i in range(0, link_mesh.size(), 3):
		
		var first_pos = points[link_mesh[i]]
		var second_pos = points[link_mesh[i+1]]
		var third_pos = points[link_mesh[i+2]]
		
		var first = systems_by_position[first_pos]
		var second = systems_by_position[second_pos]
		var third = systems_by_position[third_pos]
		
		if Vector2(first_pos).distance_to(second_pos) < MAX_LANE_LENGTH:
			hyperlanes.append(HyperlaneData.new(first, second))
		else:
			longjumps.append(HyperlaneData.new(first, second))
		if Vector2(first_pos).distance_to(third_pos) < MAX_LANE_LENGTH:
			hyperlanes.append(HyperlaneData.new(first, third))
		else:
			longjumps.append(HyperlaneData.new(first, third))
		if Vector2(second_pos).distance_to(third_pos) < MAX_LANE_LENGTH:
			hyperlanes.append(HyperlaneData.new(second, third))
		else:
			longjumps.append(HyperlaneData.new(second, third))
	
	cache_links()
	
	# Select systems for special biomes
	var always_biomes = []
	
	for biome_id in Data.biomes:
		var biome = Data.biomes[biome_id]
		if biome.always_do_one:
			while true:
				var system_id = random_select(systems.keys(), rng)
				var system = systems[system_id]
				if not systems[system_id].biome:
					system.biome = biome_id
					system.explored = biome.auto_explore
					if biome.fixed_name:
						system.name = biome.fixed_name
					else:
						system.name = random_name(systems[system_id], rng)
					_set_light(system, biome)
					if biome.startloc:
						start_sys = system_id
					break
				else:
					print("Cannot put always_do biome in an occupied system.")
	
	
	# Select seed systems for biomes
	
	var seed_biomes = []
	
	for biome_id in Data.biomes:
		if Data.biomes[biome_id].do_seed:
			seed_biomes.append(biome_id)
	
	
	var seed_count = int(systems.size() * SEED_DENSITY)
	var seeds_planted = 0
	while seeds_planted < seed_count:
		var biome_id = random_select(seed_biomes, rng)
		var system_id = random_select(systems.keys(), rng)
		if not systems[system_id].biome:
			systems[system_id].biome = biome_id
			_set_light(systems[system_id], Data.biomes[biome_id])
			systems[system_id].name = random_name(systems[system_id], rng)
			seeds_planted += 1
	# Player start system always gets the "start" biome
	systems["0"].biome = "start"
	systems["0"].name = "Holdfast"
	# Grow Seeds
	for _i in MAX_GROW_ITERATIONS:
		print("Growing Seeds")
		for system in systems.values():
			if not system.biome:
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
					system.name = random_name(system, rng)
					_set_light(system, Data.biomes[system.biome])
					
	# Fill in any systems that somehow fell through the cracks
	for system in systems.values():
		if not system.biome:
			system.biome = "empty"
			system.name = random_name(system, rng)
	
	# Remember, we had a return value. Client needs to know which system to start in.
	return start_sys

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

func random_name(sys: SystemData, _rng: RandomNumberGenerator):
	# TODO: Use the markov thing?
	# TODO: Let the player change the name?
	return "GSC " + sys.id

func randi_radius(radius: int, rng: RandomNumberGenerator):
	return (rng.randi() % (2 * radius)) - radius

func random_circular_coordinate(radius: int, rng: RandomNumberGenerator) -> Vector2:
	"""Remember to seed first if desired"""
	var position: Vector2
	while not position or position.length() > radius:
		position = Vector2(
			self.randi_radius(radius, rng),
			self.randi_radius(radius, rng)
		)
	return position
	
func random_select(iterable, rng: RandomNumberGenerator):
	""" Remember to seed the rng"""
	return iterable[rng.randi() % iterable.size()]

func _set_light(system: SystemData, biome: BiomeData):
	system.ambient_color = biome.ambient_color
	system.starlight_color = biome.starlight_color
