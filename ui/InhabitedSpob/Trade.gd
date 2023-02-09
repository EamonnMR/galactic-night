extends GridContainer

var headers = []

func _ready():
	for i in get_children():
		header.push_back(i)

func rebuild():
	for i in get_children():
		remove_child(i)
	for i in headers:
		add_child(i)

	for key in assigned_trade_properties.available_items:
		price_factor = assigned_trade_properties.available_items
		
		var item: ItemData = Data.items[key]
		var money_price = item.get_price(price)
		
		var icon = TextureRect.new()
		icon.texture = item.icon
		add_child(icon)
		var name = Label.new()
		name.text = icon.
