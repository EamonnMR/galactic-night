extends TradeDialogue

func assign(spob):
	available_items = {}
	for key in spob.available_items:
		if Data.items[key].commodity:
			available_items[key] = spob.available_items[key]
