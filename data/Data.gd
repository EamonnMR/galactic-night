extends Node

#var items = {}
#var recipes = {}
#var builds = {}
var spawns = {}
var biomes = {}
var factions = {}
var skins = {}
#var ships = {}

# Game constants:
const PLAY_AREA_RADIUS = 3000
# const JUMP_RADIUS = 2000

var name_generators = {}

func _init():
	for data_class_and_destination in [
#		[ItemData, items],
#		[RecipeData, recipes],
#		[BuildData, builds],
		[SpawnData, spawns],
		[BiomeData, biomes],
		[FactionData, factions],
		[SkinData, skins]
#		[ShipData, ships]
	]:
		var DataClass = data_class_and_destination[0]
		var dest = data_class_and_destination[1]
		var data = DataRow.load_csv(DataClass.get_csv_path())
		for key in data:
			dest[key] = DataClass.new(data[key])

	load_text()
	# Tests
	#assert_ingredients_exist()
	#assert_spawns_exist()	

func load_text():
	print("Crunching markov chains")
	for corpus in [
		["new_england", "res://data/corpus/ne_towns.txt"],
		["beowulf", "res://data/corpus/beowulf_names.txt"],
		["tain", "res://data/corpus/tain_names.txt"],
		["illiad", "res://data/corpus/illiad_names.txt"],
		["gilgamesh", "res://data/corpus/gilgamesh_names.txt"],
		["cornwall", "res://data/corpus/cornwall_places.txt"]
	]:
		name_generators[corpus[0]] = Markov.new(RandomNumberGenerator.new(), load_lines(corpus[1]))
	print("Chains crunched.")
	
func load_lines(file_name):
	var lines = []
	var file = File.new()
	file.open(file_name, File.READ) # iterate through all lines until the end of file is reached
	while not file.eof_reached():
		lines.push_back(file.get_line())
	file.close()
	return lines

	
#func assert_ingredients_exist():
	# Test to prove that no recipes require nonexistent items
#	for craftable_type in [
#		recipes,
#		builds,
#		ships
#	]:
#		for blueprint_id in craftable_type:
#			var blueprint = craftable_type[blueprint_id ]
#			for key in blueprint.ingredients:
#				assert(key in items)

# A good idea
#func assert_spawns_exist():
#	for biome_id in biomes:
#		var biome = biomes[biome_id]
#		for spawn_id in biome.spawns:
#			assert(spawn_id in spawns)
