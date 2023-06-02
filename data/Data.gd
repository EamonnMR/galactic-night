extends Node

var items = {}
var recipes = {}
var builds = {}
var spawns = {}
var biomes = {}
var factions = {}
var skins = {}
var weapons = {}
var evergreen_spawns = []
var evergreen_natural_spawns = []
var evergreen_artificial_spawns = []
var ships = {}
var spob_types = {}

var codex = {}

# Game constants:
const PLAY_AREA_RADIUS = 3000
# const JUMP_RADIUS = 2000
var name_generators = {}

func _init():
	# We should merge: 
	# https://github.com/godotengine/godot/compare/master...V-Sekai:godot:cmark

	for class_and_dest in [
		[ItemData, "items"],
		[RecipeData, "recipes"],
		[BuildData, "builds"],
		[SpawnData, "spawns"],
		[BiomeData, "biomes"],
		[FactionData, "factions"],
		[SkinData, "skins"],
		[SpobData, "spob_types"],
		[WeaponData, "weapons"],
		[ShipData, "ships"]
	]:
		var cls = class_and_dest[0]
		var dest = class_and_dest[1]
		set(dest, DataRow.load_from_csv(cls))
	load_text()
	
	load_codex()

	cache_evergreen_spawns()
	cache_evergreen_preset_spawns()
	# Tests
	assert_ingredients_exist()
	assert_spawns_exist()
	assert_happy_markov()
	assert_weapons_belonging_to_items_exist()
	assert_weapon_ammo_types_exist()
	verify_destination_field()
	identify_farming_opportunities()
	verify_spawns_have_scene_or_type()


func load_codex():
	codex = load_directory("res://data/codex")

func has_codex_entry(path: String):
	var tree = codex
	for i in path.split("/"):
		if i in tree:
			tree = tree[i]
		else:
			return false
	return true
	
func codex_by_path(path: String):
	var tree = codex
	for i in path.split("/"):
		tree = tree[i]
	return tree


func load_directory(path: String) -> Dictionary:
	var directory = {}
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				directory[file_name] = load_directory(path + "/" + file_name)
			else:
				if file_name.ends_with(".bbcode"):
					directory[file_name.replace(".bbcode", "")] = "\n".join(load_lines(path + "/" + file_name))
			file_name = dir.get_next()
		return directory
	else:
		return {}

func load_text():
	print("Crunching markov chains")
	for corpus in [
		["new_england", "res://data/corpus/ne_towns.txt"],
		["beowulf", "res://data/corpus/beowulf_names.txt"],
		["tain", "res://data/corpus/tain_names.txt"],
		["illiad", "res://data/corpus/illiad_names.txt"],
		["gilgamesh", "res://data/corpus/gilgamesh_names.txt"],
		["cornwall", "res://data/corpus/cornwall_places.txt"],
		["cali", "res://data/corpus/cali.txt"]
	]:
		name_generators[corpus[0]] = Markov.new(RandomNumberGenerator.new(), load_lines(corpus[1]))

	print("Chains crunched.")
	
func load_lines(file_name):
	var lines = []
	var file = FileAccess.open(file_name, FileAccess.READ) # iterate through all lines until the end of file is reached
	while not file.eof_reached():
		lines.push_back(file.get_line())
	return lines

func cache_evergreen_spawns():
	for spawn in spawns:
		if spawns[spawn].evergreen:
			evergreen_spawns.push_back(spawn)

func cache_evergreen_preset_spawns():
	for spawn in spawns:
		var spawn_dat: SpawnData = spawns[spawn]
		if spawn_dat.evergreen and spawn_dat.preset:
			if spawn_dat.natural:
				evergreen_natural_spawns.push_back(spawn)
			else:
				evergreen_artificial_spawns.push_back(spawn)

func assert_ingredients_exist():
	# Test to prove that no recipes require nonexistent items
	for craftable_type in [
		recipes,
		builds
#		ships
	]:
		for blueprint_id in craftable_type:
			var blueprint = craftable_type[blueprint_id ]
			for key in blueprint.ingredients:
				assert(key in items)

func assert_spawns_exist():
	for biome_id in biomes:
		var biome = biomes[biome_id]
		for spawn_id in biome.spawns:
			assert(spawn_id in spawns)
	
	for faction_id in factions:
		var faction: FactionData = factions[faction_id]
		for spawn_list_name in [
			"spawns_system", "spawns_core", "spawns_adjacent"
		]:
			var spawn_list = faction.get(spawn_list_name)
			for spawn in spawn_list:
				if not (spawn in spawns):
					print("Spawn: ", spawn, " ain't real")
				assert(spawn in spawns)

func assert_spawns_have_scenes_or_types():
	for spawn_id in spawns:
		var spawn = spawns[spawn_id]
		assert(not (	
			spawn.scene == null and spawn.type == null
		))

func assert_happy_markov():
	for name_generator_id in name_generators:
		var terminators = name_generators[name_generator_id].find_mandatory_terminal_letters()
		assert(terminators == [])

func assert_weapons_belonging_to_items_exist():
	for item_id in items:
		if items[item_id].equip_category == Equipment.CATEGORY.WEAPON:
			assert(item_id in weapons)

func assert_weapon_ammo_types_exist():
	for weapon_id in weapons:
		var weapon = weapons[weapon_id]
		if weapon.ammo_item != "":
			assert(weapon.ammo_item in items)

func identify_farming_opportunities():
	for recipe_id in recipes:
		var recipe: RecipeData = recipes[recipe_id]
		var cost = 0
		for item_id in recipe.ingredients:
			var item: ItemData = items[item_id]
			cost += recipe.ingredients[item_id] * item.price
		var item = items[recipe.prod_item]
		var value = item.price * recipe.prod_count
		assert(cost >= value)

func verify_destination_field():
	# "Destination" means "where in World3D do we stick this thing"
	# Verify that it only ever goes to a valid place
	var dummy_world = preload("res://World3D.tscn").instantiate()
	for type_id in [
		"builds",
		"spawns"
	]:
		var type = get(type_id)
		for blueprint_id in type:
			var row = type[blueprint_id]
			assert(dummy_world.has_node(row.destination))

func verify_spawns_have_scene_or_type():
	for name in spawns:
		var i = spawns[name]
		if i.scene == null:
			if i.type == "":
				assert(false)
