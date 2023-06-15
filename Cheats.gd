extends Node

var explore_all = false

var CHEATS = [
	{
		"hash": "d10ba5f768ac9db04b8419a2590bce54",
		"callback": explore_all_now
	},
	{
		"hash": "eba4a7a2f23a106e01e1380deac5190d",
		"callback": free_resources
	},
	{
		"hash": "8f1120f13067fb18ca2ee5bf7b57f9b8",
		"set_var": "max_craft_level"
	}
]

func explore_all_now(args):
	explore_all = true
	for i in Procgen.systems:
		Client.get_ui().get_node("Map").update_for_explore(i)

func free_resources(args):
	var type = args[0]
	var amount = int(args[1])
	if not (type in Data.items):
		Client.display_message("Unknown item type: " + type)
		return
	Client.player.get_node("Inventory").add(args[0], args[1])

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
	var args = split[1].split(" ") if split.size() > 1 else []
	var hash = hash_code(code)
	
	for cheat in CHEATS:
		if cheat.hash == hash:
			if "set_var" in cheat:
				set(cheat.set_var, not get(cheat.set_var))
			if "callback" in cheat:
				cheat.callback.call(args)
