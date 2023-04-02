extends NinePatchRect

var target_ship: Spaceship

func _ready():
	hide()
	Client.ship_target_updated.connect(
		func _on_target_changed():
			target_ship = Client.target_ship
			var type: ShipData = Data.ships[target_ship.type]
			%TypeName.text = type.name
			%Subtitle.text = type.subtitle
			# TODO
			# image.texture = type.target_graphic
			%Faction.text = Data.factions[target_ship.faction].name
			update() 
			show()
			# TODO: Resize to target size
			target_ship.destroyed.connect(_on_target_ship_exited)
			Client.exited_system.connect(_on_target_ship_exited)
	)

func _process(delta):
	if is_instance_valid(target_ship):
		update()

func _on_target_ship_exited():
	hide()
	target_ship = null

func update():
	var health: Health = target_ship.get_node("Health")
	%Armor.value = (float(health.health) / float(health.max_health)) * %Armor.max_value
	# %Shields.value = (float(health.shields) / float(health.max_shields)) * %Shields.max_value
