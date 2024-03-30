extends GridContainer

class_name TradeDialogue

var headers = []

var available_items = {}

func assign(Spob):
	pass

func _ready():
	for i in get_children():
		headers.push_back(i)

func _get_label(text: String) -> Label:
	var label = Label.new()
	label.text = text
	return label

func _get_button(text: String, callback: Callable) -> Button:
	var button = Button.new()
	button.text = text
	button.pressed.connect(callback)
	return button

func rebuild():
	for i in get_children():
		remove_child(i)
	for i in headers:
		add_child(i)

	for key in available_items:
		var price_factor = ItemData.CommodityPrice.values()[available_items[key]]
		var item: ItemData = Data.items[key]
		var price = item.price_at(price_factor)
		
		var icon = TextureRect.new()
		icon.texture = item.icon
		
		add_child(icon)
		add_child(_get_label(item.name))
		add_child(_get_label(str(price)))
		add_child(_get_label(ItemData.PRICE_NAMES[price_factor]))
		
		# TODO: This probably needs a binding system, otherwise there could be bugs
		var player_inventory = Client.player.get_node("Inventory")
		
		add_child(_get_button("Buy", 
			func buy_button_pressed():
				if Client.has_money(price):
					Client.deduct_money(price)
					Client.player.get_node("Inventory").add(key, 1)
		))
		add_child(_get_button("Sell", 
			func buy_button_pressed():
				if player_inventory.has_ingredients({key: 1}):
					player_inventory.deduct_ingredients({key: 1})
					Client.add_money(price)
		))
