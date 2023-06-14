extends Node

var explore_all = false

var CHEATS = [
	{
		"hash": "f966dcaf2dc376dbe2ff24e6d584b694",
		"callback": explore_all_now
	},
	{
		"hash": "ec87b985b46059efd0ffeb6cd4e515de",
		"callback": free_resources
	}
]

func explore_all_now(args):
	explore_all = true
	for i in Procgen.systems:
		

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
				cheat.callback(args)
