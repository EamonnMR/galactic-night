extends ScrollContainer

var headers = []

var available_items = {}

func assign(spob):
	available_items = []
	if spob.shipyard:
		var shipyard = spob.shipyard
		for ship_id in Data.ships:
			var ship = Data.ships[ship_id]
			if shipyard.level >= ship.require_level:
				if (not ship.techbase) or (ship.techbase == shipyard.techbase):
					available_items.append(ship_id)

func _ready():
	for i in $Grid.get_children():
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
		$Grid.remove_child(i)
	for i in headers:
		$Grid.add_child(i)

	for ship_id in available_items:
		var ship = Data.ships[ship_id]
		var icon = TextureRect.new()
		icon.texture = ship.icon
		
		$Grid.add_child(icon)
		$Grid.add_child(_get_label(ship.name))
		$Grid.add_child(_get_label(str(ship.price)))
		
		$Grid.add_child(_get_button("Buy", 
			func buy_button_pressed():
				if Client.has_money(ship.price):
					Client.deduct_money(ship.price)
					Client.switch_ship(ship_id)
		))
		
		var codex_path = ship.derive_codex_path()

		if Data.has_codex_entry(codex_path):
			$Grid.add_child(_get_button("Details", 
				func _on_codex_button_pressed():
					Client.get_ui().toggle_codex(codex_path)
			))
		else:
			$Grid.add_child(_get_label("n/a"))
