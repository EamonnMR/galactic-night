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
			show()
			# TODO: Resize to target size
			target_ship.destroyed.connect(_on_target_ship_exited)
			Client.exited_system.connect(_on_target_ship_exited)
	)

func _process(delta):
	pass
	# TODO: Update health

func _on_target_ship_exited():
	hide()
	target_ship = null
