extends TradeDialogue

func assign(spob):
	available_items = {
		"railgun_ammo": 1,
		"flak_ammo": 1
	}
	for key in spob.available_items:
		if not Data.items[key].commodity:
			available_items[key] = spob.available_items[key]
