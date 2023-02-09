extends GridContainer

var headers = []

var available_items = {}

func assign(Spob):
	available_items = Spob.available_items

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
		var price_factor = available_items[key]
		var item: ItemData = Data.items[key]
		var price = item.price_at(price_factor)
		var money_price = item.get_price(price)
		
		var icon = TextureRect.new()
		icon.texture = item.icon
		
		add_child(icon)
		add_child(_get_label(name))
		add_child(_get_label(price.to_string()))
		add_child(_get_label(ItemData.PRICE_NAMES[price_factor]))
		add_child(_get_button("Buy", 
			func buy_button_pressed():
				if Client.has_money(price):
					Client.deduct_money(price)
					Client.player.get_node("inventory").add(key, 1)
		))
