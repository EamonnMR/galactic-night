extends Node

var explore_all = false
var max_craft_level = false
var longjump_enabled = false
var jump_anywhere = false

var CHEATS = {
	"d10ba5f768ac9db04b8419a2590bce54": func explore_all_now(args):
		var valence = toggle("explore_all")
		for i in Procgen.systems:
			Client.get_ui().get_node("Map").update_for_explore(i)
		return valence,
	"eba4a7a2f23a106e01e1380deac5190d": func free_resources(args):
		if not(len(args) == 2):
			Client.display_message("Please enter an item type and quantity")
			return false
		var type = args[0]
		var amount = int(args[1])
		if not (type in Data.items):
			Client.display_message("Unknown item type: " + type)
			return false
		Client.player.get_node("Inventory").add(type, amount)
		return true,
	"8f1120f13067fb18ca2ee5bf7b57f9b8": func(_args): return toggle("max_craft_level"),
	"c7a90079bc623305b3e6382fb65774ad": func(_args): return toggle("jump_anywhere"),
	"8694e6d17345b69e6075b8afb5e8c3ec": func enable_longjumps(_args): 
		var valence = toggle("longjump_enabled")
		for i in Procgen.systems:
			if Procgen.systems[i].explored:
				Client.get_ui().get_node("Map").update_for_explore(i)
		return valence,
	"21a8297be0a2e4a39ec56a65015c0451": func make_player_invincible(args):
		var health = Client.player.get_node("Health")
		health.invulnerable = not health.invulnerable
		return health.invulnerable,
	"1a8422b3ee8414b2f29e91b333a96004": func show_hypergate_lanes(args):
		return Client.get_ui().get_node("Map").toggle_show_all_hypergate_lanes(),
	"8e2c4b2051e48c796c0af883e3d09e62": func force_spawn(args):
		if not(len(args) == 1):
			Client.display_message("Please enter a spawn ID")
			return false
		var spawn_id = args[0]
		if not spawn_id in Data.spawns:
			Client.display_message("Invalid spawn id: " + spawn_id)
			return false
		
		var spawn = Data.spawns[spawn_id]
		
		if spawn.preset:
			Client.display_message("Please pick a dynamic spawn")
			return false
		
		var entities = spawn.do_spawns(RandomNumberGenerator.new())
		for instance in entities:
			Client.get_world().get_node(spawn.destination).add_child(instance)
		
		return true,
	"c78a20092e04039fe42664fdc554ae9a": func switch_ships(args):
		if not(len(args) == 1):
			return false
		if not args[0] in Data.ships:
			return false
		
		Client.switch_ship(args[0])
		return true
}

func toggle(variable_name):
	set(variable_name, not get(variable_name))
	return get(variable_name)


func hash_code(code):
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_MD5)
	ctx.update(code.to_utf8_buffer())
	var res = ctx.finish()
	var encoded = res.hex_encode()
	return encoded

func attempt_cheat(input):
	if input.is_empty():
		return
	
	var split = input.split(":")
	var code = split[0].to_lower()
	var args = split[1].trim_prefix(" ").split(" ") if split.size() > 1 else []
	var hash = hash_code(code)
	
	var valence: bool
	
	if hash in CHEATS:
		valence = CHEATS[hash].call(args)
		if valence:
			Client.display_message("Cheat Enabled")
		else:
			Client.display_message("Cheat Disabled")
		return
	# else:
	#		Client.display_messages("Invalid cheat") I guess
	# But cheats are supposed to be mysterious
