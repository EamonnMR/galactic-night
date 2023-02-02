extends Control

var target_ship: Spaceship

func _ready():
	hide()
	Client.ship_target_updated.connect(
		func _on_target_changed():
			target_ship = Client.target_ship
			show()
			# TODO: Resize to target size
			# TODO: Recolor for target status
			Client.target_ship.destroyed.connect(_on_target_ship_exited)
	)

func _process(delta):
	if target_ship:
		position = Client.camera.unproject_position(target_ship.global_position)

func _on_target_ship_exited():
	hide()
	target_ship = null
