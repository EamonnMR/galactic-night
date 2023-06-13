extends Control

var target_ship: Spaceship
var disposition: Util.DISPOSITION = Util.DISPOSITION.ABANDONED

func _ready():
	hide()
	Client.ship_target_updated.connect(
		func _on_target_changed():
			target_ship = Client.target_ship
			show()
			$SelectionBox.set_radius(Util.item_screen_box_side_length(target_ship))
			$SelectionBox.set_disposition(Client.get_disposition(target_ship))
			target_ship.destroyed.connect(_on_target_ship_exited)
			Client.exited_system.connect(_on_target_ship_exited)
	)

func _process(_delta):
	if target_ship:
		position = Client.camera.unproject_position(target_ship.global_position)

func _on_target_ship_exited():
	hide()
	target_ship = null
